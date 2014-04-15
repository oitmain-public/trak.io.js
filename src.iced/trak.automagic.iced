define ['trak'], (Trak) ->

  class Automagic

    initialize: (options = {}) ->

      elem = document.createElement('div')
      elem.setAttribute('id', 'trakio-automagic')

      document.body.appendChild(elem)

      this
