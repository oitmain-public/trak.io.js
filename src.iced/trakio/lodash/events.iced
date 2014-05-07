define [], () ->

  events = {
    # written by Dean Edwards, 2005
    # with input from Tino Zijdel, Matthias Miller, Diego Perini

    # http://dean.edwards.name/weblog/2005/10/add-event/
    addEvent: (element, type, handler) ->
      if element.addEventListener
        element.addEventListener type, handler, false
      else

        # assign each event handler a unique ID
        handler.$$guid = @addEvent.guid++  unless handler.$$guid

        # create a hash table of event types for the element
        element.events = {}  unless element.events

        # create a hash table of event handlers for each element/event pair
        handlers = element.events[type]
        unless handlers
          handlers = element.events[type] = {}

          # store the existing event handler (if there is one)
          handlers[0] = element["on" + type]  if element["on" + type]

        # store the event handler in the hash table
        handlers[handler.$$guid] = handler

        # assign a global event handler to do all the work
        element["on" + type] = @handleEvent
      return


    removeEvent: (element, type, handler) ->
      if element.removeEventListener
        element.removeEventListener type, handler, false
      else

        # delete the event handler from the hash table
        delete element.events[type][handler.$$guid]  if element.events and element.events[type]
      return


    handleEvent: (event) ->
      returnValue = true

      # grab the event object (IE uses a global event object)
      event = event or fixEvent(((@ownerDocument or @document or this).parentWindow or window).event)

      # get a reference to the hash table of event handlers
      handlers = @events[event.type]

      # execute each event handler
      for i of handlers
        @$$handleEvent = handlers[i]
        returnValue = false  if @$$handleEvent(event) is false
      returnValue


    fixEvent: (event) ->

      # add W3C standard event methods
      event.preventDefault = @fixEvent.preventDefault
      event.stopPropagation = @fixEvent.stopPropagation
      event

  }


  events.fixEvent.preventDefault = ->
    @returnValue = false
    return

  events.fixEvent.stopPropagation = ->
    @cancelBubble = true
    return

  events.addEvent.guid = 1

  events
