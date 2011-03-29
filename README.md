# Oraki

Bringing wikipedia to the hearing world

# Summary

Oraki is an implementation of a mobile talking wikipedia. We download wikipedia and then turn the text into speech.

# Parts

## Backend

The oraki backend consists of the wikipeda parser. We use beautiful soup
to take the raw knowledge of wikipedia and convert it into manageable
chunks.

### Endpoints

* /search
  * GET
    * request
      * query - your search term (e.g. "Lebron")
      * limit - (optional; default 10) number of results to return
    * response
      * list of titles (e.g. ["Lebron James", "Lebron (Author)", "etc."])
* /article_info
  * GET
    * request
      * title - the title of the article requested
    * response
      * sections
        * list of sections where each section constains
          * name - the name of the section
          * paragrapahs - list of paragraphs
    * errors
      * 404 -> title not found

## Client

iOS application which downloads the text for the backend and converts it
into wav files using text to speech. These wav files are later played
back.

### Components
1. SearchViewController - controls article searching
2. ArticleViewController - controls presenting and playing articles
3. FliteManager - manages Flite's text to speech computations

# Resources
Flite CMU for text to speech
Beautiful soup for html parsing
