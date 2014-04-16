class Automagic

  initialize: (options = {}) ->

    elem = document.createElement('div')
    elem.setAttribute('id', 'trakio-automagic')

    document.body.appendChild(elem)

    this

window.Automagic = Automagic
