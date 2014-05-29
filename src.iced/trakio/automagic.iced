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


    submit_bubbles: ()=>
      # this is surrounded by backticks so its interpreted as JS
      # 'onsubmit' in window compiles to an index of in CoffeeScript
      `'onsubmit' in window`



    bind_events: ()=>
      try
        body = document.body or document.getElementsByTagName('body')[0]

        if @submit_bubbles()
          _.addEvent(body, 'submit', @event_fired)
        else
          # below is a hacky way of picking up submits when the submit event does not bubble.
          _.addEvent(body, 'click', @emulated_event_fired)
          _.addEvent(body, 'keypress', @emulated_event_fired)
      catch e
        trak.io.debug_error e


    emulated_event_fired: (event, callback)=>
      try
        target = event.srcElement || event.target

        if target.nodeName == 'INPUT' || target.nodeName == 'BUTTON'
          if target.form
            form = target.form
          else # if form isn't set try and find it by ascending the DOM
            parent = target.parentNode

            while parent && parent.nodeName != 'FORM'
              parent = target.parentNode

            if parent.nodeName == 'FORM'
              form = parent
            # if form isn't set now target clearly doesn't belong to a form

        unless form && event.type
          return

        target.form = form unless target.form
        # now we need to see if it's real
        if event.type == 'click' && target.type == 'submit'
          # we have a submit
          @event_fired(event, callback)

        else if event.type == 'keypress'
          # check we're an enter press
          keycode = event.keyCode || event.which
          @event_fired(event, callback) if keycode == 13
      catch e
        trak.io.debug_error e


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
              if element.submit
                element.submit()
              else
                element.form.submit() # this is for when emulated form submit is used
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
