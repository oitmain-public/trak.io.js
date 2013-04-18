define ->

  class Exception extends Error

    constructor: (@message, @code, @details, @data) ->
