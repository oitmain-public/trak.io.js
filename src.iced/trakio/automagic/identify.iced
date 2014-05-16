define [
  'trakio/lodash'
], (_) ->

  class Identify

    initialize: (@automagic, @options)=>
      # Nothing to do here at the moment


    page_ready: ()=>
      # Nothing to do here at the moment


    event_fired: (element, event, callback, automagic_ready)=>
      try
        if _.matches(element, @options.selector) && @options.should_identify.call(@automagic, element, event)
          trak.io.identify(@distinct_id(element), @map_properties(element), ()->
            automagic_ready.identify = true
            callback()
          )

      catch e
        trak.io.debug_error e

      automagic_ready.identify = true
      callback()


    should_identify: (element, event)=>
      properties = @map_properties(element)

      has_any = _.filter(properties,(value,key)=> _.contains(@options.has_any_fields, key)).length > 0
      has_all = _.filter(properties,(value,key)=> _.contains(@options.has_all_fields, key)).length >= @options.has_all_fields.length

      has_any && has_all


    distinct_id: (element)=>
      r = {}
      for property, value of @map_properties(element)
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
