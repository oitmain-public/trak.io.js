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


    bind_events: ()=>
      try
        body = document.body or document.getElementsByTagName('body')[0]
        for form in _.find(@options.form_selector)
          @bind_to_form_submit(form)
      catch


    bind_to_form_submit: (form) =>
      me = @
      form.setAttribute('style','backgound:red')
      _.addEvent(form, 'submit', @form_submitted)


    form_submitted: (event, callback) =>
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
