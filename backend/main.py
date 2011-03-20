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
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import urlfetch, memcache
from django.utils import simplejson as json

import BeautifulSoup as BS

WIKI_URL = 'http://en.wikipedia.org/w/api.php'

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

        search_results = memcache.get(self.mc_key(query))
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
            memcache.set(self.mc_key(query), search_results, time=self.MC_TTL)
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
        cached_val = memcache.get(self.mc_key(title))
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
            except DownloadError:
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

            ret_val = json.dumps(
                [section for section in self.parse_text(text, sections_info) \
                     if len(section['paragraphs']) > 0])
            memcache.set(self.mc_key(title), ret_val, time=self.MC_TTL)
            self.response.out.write(ret_val)

    def parse_text(self, text, section_info):
        """
        given the wikipedia text in HTML format and a dictinoary of section data
        returns a list of sectinos (name, paragraphs)
        """
        soup = BS.BeautifulSoup(text)
        sections = []
        curr_section = {'name': 'Abstract', 'paragraphs': []}
        for iter_elmn in soup.contents:
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
         ('/article', ArticleHandler)],
        debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
