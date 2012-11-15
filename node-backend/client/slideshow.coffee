###
Copyright © 2012 Opinsys Oy
            2012 lamikae

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

window.Iivari = {
    Models: {},
    Collections: {},
    Routers: {},
    Views: {},
    init: () ->
        (new Iivari.Views.Conductor()).start();
}

$(document).ready ->
    Iivari.init();


class Iivari.Views.Conductor

    window.display = null     # backend proxy object for signaling
    Iivari.displayCtrl = null # display logic
    Iivari.onLine = true      # custom window.navigator.onLine replacement

    start: ->
        json_url = "/slides"
        data_update_interval = 15*10000 # slide interval = 15
        preview = false
        ctrl_url = null
        ctrl_update_interval = null
        cache = false
        preview = false
        locale = "fi"

        Iivari.slideshow = new Iivari.Models.Slideshow(json_url, data_update_interval, preview, cache)
        Iivari.slideshow.start()

        if (not @preview) and @json_url
            # DisplayCtrl runs control timers and handles kiosk backend signaling.
            Iivari.displayCtrl = new Iivari.Models.DisplayCtrl(ctrl_url, ctrl_update_interval, locale)


class Iivari.Models.Slideshow

    SCREEN_WIDTH = window.innerWidth
    SCREEN_HEIGHT = window.innerHeight


    constructor: (@json_url, @data_update_interval, @preview, @cache) ->
        @slideData = null
        # hide slide container
        $(".slides-container").hide()
        $(".footer_container").hide()


    start: ->
        $("body").css
            "background-image": "null",
            "background": "black",

        # start superslides after receiving the first slide batch
        promise = @updateSlideData()
        promise.done =>
            @initSlideshow()
        promise.fail ->
            console.log "failed to load slides, try again..."
            setTimeout @start, 5000
        # start slide poll
        if (not @preview) and @json_url and @data_update_interval
            setInterval @updateSlideData, @data_update_interval


    # render slides using Transparency.js
    renderSlides: =>
        # clear current slide abruptly
        $(".slides-container").html()
        # render new slideset
        $(".slides-container").render(
            @slideData,
            {slide: -> html: @slide_html})

        # resize fullscreen image -  maybe make scaling optional?
        title = $($(".title_container")[0]).height()
        footer = $(".footer_container").height()
        $(".fullimg img").css {width: "auto", height: "#{SCREEN_HEIGHT - footer - title}px"}


    initSlideshow: =>
        # FIXME: use @slideData[slideNumber].slide_delay value
        # FIXME: checkSlideTimerAndStatus

        if @preview
            $(".slides-container").show()
            return

        $('#slideshow').superslides
            delay: 10000
            play: true
            slide_speed: 2500
            slide_easing: "swing"
            container_class: "slides-container"

        $("#slideshow").trigger("slides.start")

        $("body").on "slides.initialized", "#slideshow", =>
            console.log 'Superslides initialized!'
            $(".slides-container").fadeIn(5000)


    updateSlideData: =>
        deferred = new $.Deferred()
        if @cache
            # jquery-offline handles transport errors
            # NOTE: if offline (no network), and even if server is localhost, json data is not requested!
            $.retrieveJSON @json_url, (json, status, attributes) =>
                unless json
                    console.log "No slide data received!"
                    deferred.reject()
                    return

                if not @slideData or status != "notmodified"
                    console.log "received #{json.length} slides"
                    @slideData = json
                    @renderSlides()
                    try
                        window.applicationCache.update()
                deferred.resolve()

        else
            console.log "request slides from #{@json_url}"
            $.ajax
                url: @json_url,
                dataType: 'json',
                cache: false,
                timeout: 300000,
                success: (data, textStatus, jqXHR) =>
                    console.log("received #{data.length} slides")
                    @slideData = data
                    @renderSlides()
                    deferred.resolve()

                error: (jqXHR, textStatus, errorThrown) ->
                    console.log "#{textStatus}: #{errorThrown}"
                    deferred.reject()

        return deferred.promise()

