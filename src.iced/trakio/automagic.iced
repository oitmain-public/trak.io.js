define [
  'trakio/lodash',
  'trakio/automagic/identify'
], (_,Identify) ->
  class Automagic

    default_options:
      test_hooks: []
      bind_events: true
      form_selector: 'form'
      identify:
        form_selector: 'form'
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


    initialize: (options = {}) ->
      try
        @options = _.cloneDeep(@default_options)
        _.merge @options, options, @merge_options
        @identify = new Identify()
        @identify.initialize(@,@options.identify)
        @page_ready() if trak.io.page_ready_event_fired
        @
      catch


    merge_options: (a,b) =>
      if _.isArray(a) then b else undefined


    page_body: ()=>
      _.find('body')[0]


    page_ready: ()=>
      _.attr(@page_body(),'data-trakio-automagic', '1')
      @identify.page_ready()
      @bind_events() if @options.bind_events


    submit_bubbles: () =>
      'onsubmit' in window


    bind_events: ()=>
      try
        body = document.body or document.getElementsByTagName('body')[0]

        if @submit_bubbles()
          _.addEvent(body, 'submit', @form_submitted)
        else
          # below is a hacky way of picking up submits when the submit event does not bubble.
          _.addEvent(body, 'click', @emulated_form_submitted)
          _.addEvent(body, 'keypress', @emulated_form_submitted)

      catch

    emulated_form_submitted: (event, callback) =>
      # this is for IE7 and IE8 only
      target = event.srcElement || event.target

      if target.nodeName.toLowerCase == 'input' || target.nodeName.toLowerCase == 'button'
        if target.form
          form = target.form
        else # if form isn't set try and find it by ascending the DOM
          parent = target.parentNode

          while parent && parent.nodeName.toLowerCase != 'form'
            parent = target.parentNode

          if parent.nodeName.toLowercase == 'form'
            form = parent

      unless form && event.type
        return

      # now we need to see if it's real
      if event.type == 'click' && target.type == 'submit'
        # we have a submit
        @form_submitted(event, callback)

      else if event.type == 'keypress'
        # check we're an enter press
        keycode = event.keyCode || event.which
        @form_submitted(event, callback) if keycode == 13

      # end

    form_submitted: (event, callback) =>
      target = event.srcElement || event.target

      _matches = (target.matches || target.matchesSelector || target.msMatchesSelector || target.mozMatchesSelector || target.webkitMatchesSelector || target.oMatchesSelector)
      if _matches # if matchesSelector is built into browser
        matches = _matches.call(target, @options.form_selector)
      else # slower alternative
        matches = target in document.querySelectorAll(@options.form_selector)

      unless matches
        return # return early if the element does not match the selector

      try
        event.preventDefault()
        @identify.form_submitted(event, callback)
        false
      catch
        callback()


  Trak.Automagic = Automagic
  Trak.Automagic.Identify = Identify

  for instance in Trak.instances
    instance.loaded_automagic()
