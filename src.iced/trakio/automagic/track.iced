define [
  'trakio/lodash'
], (_) ->

  class Track

    initialize: (@automagic, @options)=>
      # Nothing to do here at the moment


    page_ready: ()=>
      # Nothing to do here at the moment


    event_fired: (element, event, callback, automagic_ready)=>
      try
        if _.matches(element, @options.selector) && @options.should_track.call(@automagic, element, event)

          events = @events(element, event)
          track_completed = 0

          if events.length > 0
            for event in events
              trak.io.track event, @track_properties(element), ()->
                track_completed += 1
                if track_completed >= events.length
                  automagic_ready.track = true
                  callback()
            return

      catch e
        trak.io.debug_error e

      automagic_ready.track = true
      callback()


    should_track: (element, event)=>
      true

    should_track_events:
      signed_in: (element, event)->
        properties = @map_properties(element)
        inputs = @map_form_inputs(element)
        fields_count = fields_count_less_one_checkbox = _.find('input:not([type=submit]), select', element).length
        fields_count_less_one_checkbox = fields_count - 1 if _.find('input[type=checkbox]', element).length > 0
        submit = _.find('[type=submit]', element)[0]

        (properties['username'] || properties['email']) &&
        _.find('[type=password]', element).length == 1 &&
        (!submit || !submit.value.match(/(sign.?up)|register|create/i)) &&
        fields_count_less_one_checkbox == 2

      signed_up: (element, event)->
        properties = @map_properties(element)
        inputs = @map_form_inputs(element)
        fields_count = fields_count_less_one_checkbox = _.find('input:not([type=submit]), select', element).length
        fields_count_less_one_checkbox = fields_count - 1 if _.find('input[type=checkbox]', element).length > 0

        !this.should_track_events.signed_in.call(this, element,event) &&
        (properties['username'] || properties['email']) &&
        fields_count_less_one_checkbox >= 2

      subscribed_with_email: (element, event)->
        properties = @map_properties(element)

        _.find('input:not([type=submit])').length == 1 &&
        properties['email']

      submitted_form: (element, event)->
        _.matches(element, 'form')

    events: (element)=>
      r = []
      for event, condition of @options.should_track_events
        r.push event if condition.call(@automagic, element)
      r

    track_properties: (element)=>
      r = {}
      r.id = id if (id = element.id).length > 0
      r.class = c.split(' ') if (c = _.attr(element, 'class')) && c.length > 0
      r.action = action if (action = _.attr(element, 'action')) && action.length > 0
      r.referrer = referrer if (referrer = window.location.href).length > 0
      r

    map_properties: (element)=>
      @automagic.identify.map_properties(element)

    map_form_inputs: (element)=>
      r = {}
      for input in _.find('input:not([type=submit])', element)
        r[_.attr(input, 'name')] = _.attr(input, 'type')
      for select in _.find('select', element)
        r[_.attr(input, 'name')] = 'select'
      r

