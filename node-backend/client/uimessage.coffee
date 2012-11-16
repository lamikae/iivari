###
###

class UIMessage

  container = null
  visible = true

  constructor: (options) ->
    @container = $(".#{options.container_class}")
    unless @container
      console.log "No container_class"
      return false

    @container.css
      width: "auto"
      height: "auto"

    if options.css
      @css options.css

    visible = options.visible
    visible ?= true
    unless visible
      @container.hide()

    if options.html
      @container.html(options.html)

  css: (params) =>
    @container.css params
    return this

  show: (text, delay) =>
    @container.text(text)
    return unless visible
    console.log "#{@container.selector} - #{text}"
    @container.fadeIn("fast")
    if delay
      setTimeout @clear, delay

  clear: =>
    @container.fadeOut("slow", => @container.text(""))

  toggle: =>
    if visible
      @container.fadeOut()
      visible = false
    else
      @container.fadeIn()
      visible = true


# Plugin
$.fn.uimessage = (options) ->
  if typeof options == "string"
    api = $.fn.uimessage.api
    method = options

    # Convert arguments to real array
    args = Array.prototype.slice.call(arguments)
    args.splice(0, 1)

    api[method].apply(this, args)
  else
    # Defaults
    options = $.fn.uimessage.options = $.extend $.fn.uimessage.options, options

    return new UIMessage(options)


# Options
$.fn.uimessage.options = {}
