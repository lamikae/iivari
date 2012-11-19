###
Copyright © 2012 lamikae

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
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
    # console.log "#{@container.selector} - #{text}"
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

  hide: =>
    @container.fadeOut("fast")
    visible = false
  unhide: =>
    @container.fadeIn("fast")
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
