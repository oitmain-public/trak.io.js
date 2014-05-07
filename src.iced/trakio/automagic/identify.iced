define [
  'trakio/lodash'
], (_) ->

  class Identify

    initialize: (@automagic, @options)=>
      # Nothing to do here at the moment


    page_ready: ()=>
      # Nothing to do here at the moment


    form_submitted: (event, callback)=>
      try
        event.preventDefault()
        form = event.srcElement || event.target
        callback ||= ()->
          form.submit()
        if _.matches form, @options.form_selector
          properties = @map_properties(form)

          has_any = _.filter(properties,(value,key)=> _.contains(@options.has_any_fields, key)).length > 0
          has_all = _.filter(properties,(value,key)=> _.contains(@options.has_all_fields, key)).length >= @options.has_all_fields.length

          if has_any && has_all
            trak.io.identify(@distinct_id(form), properties, callback)
          else
            callback()
        else
          callback()
        false
      catch
        callback()


    distinct_id: (form)=>
      r = {}
      for property, value of @map_properties(form)
        if (index = _.indexOf(@options.distinct_ids, property)) > -1
          r[index] = value

      for key, value of r
        return value if value && value != ""

      trak.io.distinct_id()


    map_properties: (form)=>
      inputs = _.find("input", form)
      r = {}
      for input in inputs
        unless _.matches(input, @options.excluded_field_selector)
          name = _.attr(input,'name')
          for property, field of @options.property_map
            if typeof field == 'string' && field == name || typeof field.test == 'function' && field.test(name)
              value = input.value
              r[property] = value if value && value != ""
              break
      r
