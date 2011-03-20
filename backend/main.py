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
from google.appengine.api import urlfetch
from django.utils import simplejson as json

import BeautifulSoup as BS

WIKI_URL = 'http://en.wikipedia.org/w/api.php'

def get_json(url, data):
    data_str = urllib.urlencode(data)
    return urlfetch.fetch(url+'?'+data_str, deadline=10)

class SearchHandler(webapp.RequestHandler):
    """given search query, return suggestions"""
    def get(self):
        query = self.request.get('query', None)
        if query is None:
            self.error(400)
            return
        limit = self.request.get('limit', 10)

        result = get_json(WIKI_URL,
          {'action': 'opensearch',
           'search': query,
           'limit': limit,
           'namespace': 0,
           'format': 'json'
          })
        if result.status_code != 200:
            self.error(503)
            return
        json_obj = json.loads(result.content)
        suggestions = json_obj[1]
        self.response.out.write(json.dumps(suggestions))

class ArticleHandler(webapp.RequestHandler):

    def get(self):
        """given title, return ... sth"""
        title = self.request.get('title', None)
        if title is None:
            self.error(400)
            return

        # first, get the page id
        page_info_result = get_json(WIKI_URL,
            {'action': 'query',
             'format': 'json',
             'titles': title,
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
        parsed_page_result = get_json(WIKI_URL,
            {'action': 'parse',
             'format': 'json',
             'prop': 'text|sections',
             'pageid': page_id})
        if parsed_page_result.status_code != 200:
            logging.warning('Wikipedia servers down?')
            self.error(503)
            return
        page_data = json.loads(parsed_page_result.content)
        sections_info = [section for section in page_data['parse']['sections'] \
            if section['toclevel'] == 1]
        text = page_data['parse']['text']['*']
        self.response.out.write(json.dumps(
            [section for section in self.parse_text(text, sections_info) \
                 if len(section['paragraphs']) > 0]))

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
