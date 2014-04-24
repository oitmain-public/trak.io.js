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

    this.form_selector = options.form_selector
    this.property_map = options.property_map
    this.has_any_fields = options.has_any_fields
    this.has_all_fields = options.has_all_fields

    this.create_hooks()

  create_hooks: () ->
    body = document.body or document.getElementByTagName('body')[0]
    body.setAttribute('data-automagic', '')

    this

window.Automagic = Automagic
