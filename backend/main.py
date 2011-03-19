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
import urllib
import logging
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import urlfetch
from django.utils import simplejson as json

WIKI_URL = 'http://en.wikipedia.org/w/api.php'

def get_json(url, data):
    data_str = urllib.urlencode(data)
    return urlfetch.fetch(url+'?'+data_str)

class SearchHandler(webapp.RequestHandler):
    """given search query, return suggestions"""
    def get(self):
        query = self.request.get('query', None)
        if query is None: self.error(400)
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
        json_obj = json.loads(result.content)
        suggestions = json_obj[1]
        self.response.out.write(json.dumps(suggestions))

class ContentHandler(webapp.RequestHandler):
    def parse_section(self, section_json):
        anchor = section_json['anchor']
        name = section_json['line']
        return {'name': name}


    def get(self):
        """given title, return ... sth"""
        title = self.request.get('title', None)
        if title is None: self.error(400)
        page_info_result = get_json(WIKI_URL,
            {'action': 'query',
             'format': 'json',
             'titles': title})
        if page_info_result.status_code != 200:
            self.error(503)
        json_obj = json.loads(page_info_result.content)
        pages = json_obj['query']['pages']
        (page_id, page_info) = pages.iteritems().next()
        # TODO what if no pages returned?
        parsed_page_result = get_json(WIKI_URL,
            {'action': 'parse',
             'format': 'json',
             'prop': 'text|sections',
             'pageid': page_id})
        if parsed_page_result.status_code != 200:
            self.error(503)
        json_obj = json.loads(parsed_page_result.content)
        sections_json = json_obj['parse']['sections']
        sections = [self.parse_section(section_json) \
            for section_json in sections_json \
            if section_json['toclevel'] == 1]
        text = json_obj['parse']['text']['*']
        self.response.out.write(json.dumps(sections))

def main():
    application = webapp.WSGIApplication(
        [('/search', SearchHandler),
         ('/content', ContentHandler)],
        debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
