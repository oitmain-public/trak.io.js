define ['exception'], (Exception) ->

  class Unknown

    constructor: (@message, @code, @details, @data) ->

