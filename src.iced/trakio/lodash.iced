define [
  'sizzle',
  'lodash',
  'trakio/lodash/events'
], (Sizzle,_,events) ->

  _.find = (selector, context=null) ->
    Sizzle(selector, context)

  _.matches = (element, selector) ->
    Sizzle.matchesSelector(element, selector)

  _.attr = (element, attribute, value=false) ->
    if element
      if value
        element.setAttribute(attribute, value );
      else
        element.getAttribute(attribute);

  _.merge _, events

  return _
