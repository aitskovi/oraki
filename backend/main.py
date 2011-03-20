#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import re
import urllib
import logging
import itertools
from copy import deepcopy
from operator import itemgetter
from collections import defaultdict

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import urlfetch, memcache
from django.utils import simplejson as json

import BeautifulSoup as BS

WIKI_URL = 'http://en.wikipedia.org/w/api.php'
USE_CACHE = False

def mc_get(*args, **kwargs):
    return memcache.get(*args, **kwargs) if USE_CACHE else None

def mc_set(*args, **kwargs):
    return memcache.set(*args, **kwargs) if USE_CACHE else False

def get_json(url, data):
    data_str = urllib.urlencode(data)
    return urlfetch.fetch(url+'?'+data_str, deadline=10)

class SearchHandler(webapp.RequestHandler):
    """given search query, return suggestions"""

    MC_TTL = 60*60*24  # 1 day

    def mc_key(self, query):
        return '%s:%s' % (self.__class__.__name__, query)

    def get(self):
        query = self.request.get('query', None)
        if query is None:
            self.error(400)
            return
        limit_str = self.request.get('limit', '10')
        try:
            limit = int(limit_str)
        except:
            self.error(400)
            return

        search_results = mc_get(self.mc_key(query))
        if search_results is None:
            try:
                result = get_json(WIKI_URL,
                  {'action': 'opensearch',
                   'search': query.encode('utf-8'),
                   'limit': 99,  # doesn't seem to go that high... max 15?
                   'namespace': 0,
                   'format': 'json'
                  })
            except urlfetch.DownloadError:
                logging.info('Timed out downloading.')
                self.error(503)
                return
            if result.status_code != 200:
                self.error(503)
                return
            result_obj = json.loads(result.content)
            search_results = result_obj[1]
            mc_set(self.mc_key(query), search_results, time=self.MC_TTL)
        self.response.out.write(json.dumps(search_results[:limit]))

class ArticleHandler(webapp.RequestHandler):

    MC_TTL = 60*60*24*7  # 1 week

    def mc_key(self, title):
        return '%s:%s' % (self.__class__.__name__, title)

    def get(self):
        """given title, return ... sth"""
        title = self.request.get('title', None)
        if title is None:
            self.error(400)
            return
        cached_val = mc_get(self.mc_key(title))
        if cached_val is not None:
            self.response.out.write(cached_val)
        else:
            # first, get the page id
            page_info_result = get_json(WIKI_URL,
                {'action': 'query',
                 'format': 'json',
                 'titles': title.encode('utf-8'),
                 'redirects': ''})
            if page_info_result.status_code != 200:
                logging.warning('Wikipedia servers down?')
                self.error(503)
                return
            json_obj = json.loads(page_info_result.content)
            pages = json_obj['query']['pages']
            (page_id, page_info) = pages.iteritems().next()
            if page_id == u'-1':
                logging.warning('Couldn\'t find title %s', title)
                self.error(404)
                return

            # then, get the parsed wiki page
            try:
                parsed_page_result = get_json(WIKI_URL,
                    {'action': 'parse',
                     'format': 'json',
                     'prop': 'text|sections',
                     'pageid': page_id})
            except urlfetch.DownloadError:
                logging.info('Timed out downloading.')
                self.error(503)
                return
            if parsed_page_result.status_code != 200:
                logging.warning('Wikipedia servers down?')
                self.error(503)
                return
            page_data = json.loads(parsed_page_result.content)
            sections_info = [section for section in page_data['parse']['sections'] \
                if section['toclevel'] == 1]
            text = page_data['parse']['text']['*']
            text_soup = BS.BeautifulSoup(text)

            related_titles = self.get_related_titles(text_soup)
            sections = [section \
                for section in self.get_sections(text_soup, sections_info) \
                if len(section['paragraphs']) > 0]

            ret_val = json.dumps(
                {'sections': sections,
                 'related_titles': related_titles})

            mc_set(self.mc_key(title), ret_val, time=self.MC_TTL)
            self.response.out.write(ret_val)

    def normalize_title(self, unorm_title):
        """
        supposedly, all I need to do is replace the first character with 
        a capital and all '_' with spaces.
        see http://www.mediawiki.org/wiki/API:Query#Title_normalization
        """
        def transform_char(i, c):
            if c == '_':
                c = ' '
            if i == 0:
                c = c.upper()
            return c
        return ''.join([transform_char(i, c) for (i, c) in enumerate(unorm_title)])


    def get_related_titles(self, text_soup):
        title_counts = defaultdict(int)
        def is_good_title(title):
            """
            false if:
            * is a Category page or Project page
            * is a "list of " page
            """
            return (not title.startswith('List_of')) and (':' not in title)

        for link in text_soup.findAll('a'):
            href = link.get('href', '')
            match = re.search(r'/wiki/(.+?)(#.+)?$', href)
            # second grouping ignores any anchors
            if match is not None:
                title = urllib.unquote_plus(match.group(1))
                title_counts[title] += 1
        top_unorm_titles = [title for (title, count) in \
            sorted(title_counts.items(), key=itemgetter(1), reverse=True)\
            if is_good_title(title)][:10]
        return [self.normalize_title(unorm_title) for unorm_title in top_unorm_titles]

    def get_sections(self, text_soup, section_info):
        """
        given the wikipedia text in HTML format and a dictinoary of section data
        returns a list of sectinos (name, paragraphs)
        """
        sections = []
        curr_section = {'name': 'Abstract', 'paragraphs': []}
        for iter_elmn in text_soup.contents:
            if isinstance(iter_elmn, BS.NavigableString):
                # any strings or comments in the top level can be ignored
                continue
            elif iter_elmn.name == 'p':
                # get all the text in the paragraph
                # exorcise all the citations
                citations = iter_elmn.findAll('sup')
                [citation.extract() for citation in citations]
                # find all the text and join them for a paragraph
                curr_section['paragraphs'].append(''.join(iter_elmn.findAll(text=True)))
            elif re.match(r'^h[1-5]$', iter_elmn.name):
                # it's a potential sectino; check if it's in the section_info
                headline_elmn = iter_elmn.find('span', {'class': 'mw-headline'})
                if any((headline_elmn.get('id', '') == section['anchor'] for section in section_info)):
                    # begin a new section
                    sections.append(deepcopy(curr_section))
                    curr_section['name'] = ''.join(headline_elmn.findAll(text=True))
                    curr_section['paragraphs'] = []
                else:
                    continue
        return sections



def main():
    application = webapp.WSGIApplication(
        [('/search', SearchHandler),
         ('/article_info', ArticleHandler)],
        debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
