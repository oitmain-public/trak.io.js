define [
  'trakio/lodash',
  'trakio/automagic/identify',
  'trakio/automagic/track'
], (_,Identify, Track) ->
  class Automagic

    default_options:
      test_hooks: []
      bind_events: true
      selector: 'form'
      # events: ['submit'] # Hardcoded for now

      identify:
        selector: 'form'
        # events: ['submit'] # Hardcoded for now
        excluded_field_selector: '[type=password]'
        property_map:
          username:     /.*username.*/
          name:         /^(?!(.*first.*|.*last.*|.*user|.*f.?|.*l.?)name).*name.*/
          first_name:   /.*(first.*|f.?)name.*/
          last_name:    /.*(last.*|l.?)name.*/
          email:        /.*email.*/
          position:     /.*position.*/
          company:      /.*company.*/
          organization: /.*organi(z|s)ation.*/
          industry:     /.*industry.*/
          location:     /.*location.*/
          latlng:       /.*latl(ng|on).*/
          birthday:     /.*(birthday|dob|date.*of.*birth).*/
        has_any_fields: ['username','name','first_name','last_name','email']
        has_all_fields: []
        distinct_ids: ['username','email']
        should_identify: (element, event)->
          @identify.should_identify(element, event)

      track:
        selector: 'form'
        # events: ['submit'] # Hardcoded for now
        should_track: (element, event)->
          @track.should_track(element, event)
        should_track_events:
          signed_in: (element, event)->
            @track.should_track_events.signed_in.call(@track, element, event)
          signed_up: (element, event)->
            @track.should_track_events.signed_up.call(@track, element, event)
          subscribed_with_email: (element, event)->
            @track.should_track_events.subscribed_with_email.call(@track, element, event)
          submitted_form: (element, event)->
            @track.should_track_events.submitted_form.call(@track, element, event)



    initialize: (options = {}) ->
      try
        @options = _.cloneDeep(@default_options)
        _.merge @options, options, @merge_options
        @identify = new Identify()
        @identify.initialize(@,@options.identify)
        @track = new Track()
        @track.initialize(@,@options.track)
        @page_ready() if trak.io.page_ready_event_fired
        @
      catch e
        trak.io.debug_error e

    merge_options: (a,b) =>
      if _.isArray(a) then b else undefined


    page_body: ()=>
      _.find('body')[0]


    page_ready: ()=>
      _.attr(@page_body(),'data-trakio-automagic', '1')
      @identify.page_ready()
      @track.page_ready()
      @bind_events() if @options.bind_events


    bind_events: ()=>
      try
        body = document.body or document.getElementsByTagName('body')[0]

        # Need to bind directly to form submit as it doesn't bubble (for other elements we'll bind to the document)
        for element in _.find(@options.selector)
          if _.matches(element, 'form')
            @bind_event(element, 'submit')
      catch e
        trak.io.debug_error e


    bind_event: (element, event) =>
      me = @
      _.addEvent(element, event, @event_fired)


    event_fired: (event, provided_callback) =>
      try
        element = event.srcElement || event.target
        event.preventDefault()
        automagic_ready =
          identify: false
          track: false

        timeout = setTimeout ()->
          if provided_callback
            provided_callback()
          else
            element.submit() # @todo this will need to be much cleverer when we do more than forms
        , 1000

        callback = ()->
          clearTimeout(timeout);
          if automagic_ready.identify && automagic_ready.track
            if provided_callback
              provided_callback()
            else
              element.submit() # @todo this will need to be much cleverer when we do more than forms
            true

        @identify.event_fired element, event, callback, automagic_ready
        @track.event_fired element, event, callback, automagic_ready

        false
      catch e
        trak.io.debug_error e
        event.automagic_ready =
          identify: true
          track: true
        event.callback()
        true


  Trak.Automagic = Automagic
  Trak.Automagic.Identify = Identify
  Trak.Automagic.Track = Track

  for instance in Trak.instances
    instance.loaded_automagic()
