class Automagic

  initialize: (options = identify:
    form_selector: 'form',  # CSS selector for the form elements
    property_map:
      username: /.*username.*/,
      name: /.*name.*/,
      first_name: /.*first.*name.*/,
      last_name: /.*last.*name.*/,
      email: /.*email.*/,
      position: /.*position.*/,
      company: /.*company.*/,
      organization: /.*organi(z|s)ation.*/,
      industry: /.*industry.*/,
      location: /.*location.*/,
      latlng: /.*latl(ng|on).*/,
      birthday: /.*(birthday|dob|date.*of.*birth).*/
    has_any_fields: ['username','name','first_name','last_name','email'],
    has_all_fields: []
  ) ->

    this.form_selector = options.identify.form_selector
    this.property_map = options.identify.property_map
    this.has_any_fields = options.identify.has_any_fields
    this.has_all_fields = options.identify.has_all_fields

    this.create_hooks()

  create_hooks: () ->
    body = document.body or document.getElementByTagName('body')[0]
    body.setAttribute('data-automagic', '')

    for form in document.querySelectorAll(this.form_selector)
      this.hook(form)

    this

  hook: (form) ->
    old_handler = form.onsubmit
    form.onsubmit = null if old_handler

    callback = (event) ->
      element = event.target
      data = extract_data(element)

      all_fields = (field for field in this.has_all_fields when field in data).size == this.has_all_fields.size
      any_fields = (field for field in this.has_any_fields when field in data).size >= 1

      if all_fields and any_fields
        trak.io.identify(data) if trak and trak.io

        old_handler() if old_handler

    if window.addEventListener
      form.addEventListener('submit', callback, false) # modern browsers
    else if window.attachEvent
      form.attachEvent('onsubmit', callback) # older IE

  extract_data: (element) ->
    data = {}

    for elem in element.querySelectorAll('input, textarea')
      name = elem.name
      value = elem.value

      for key, regex of this.property_map when regex.test name
        data[key] = value

    data

window.Automagic = Automagic
