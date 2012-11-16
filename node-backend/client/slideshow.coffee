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

    notifier_ui = null
    title_ui = null
    playing = true

    # animate is an option to use request animation frame
    # instead of interval-based motionless slide change
    animate = true

    constructor: (@json_url, @data_update_interval, @preview, @cache) ->
        @slideData = null
        # hide slide container
        $(".slides").hide()

        notifier_ui = $("#notifications").uimessage
            container_class: "notifications"
            css:
                bottom: 0

        title_ui = $("#slide_title").uimessage
            container_class: "title"
            css:
                top: 0


    start: ->
        $("body").css
            "background-image": "null",
            "background": "black",

        # start superslides after receiving the first slide batch
        promise = @updateSlideData()
        promise.done =>
            @initSlideshow()
        promise.fail (err) =>
            console.log "failed to load slides, try again..."
            setTimeout @start, 5000

        # start slide poll
        if (not @preview) and @json_url and @data_update_interval
            setInterval @updateSlideData, @data_update_interval


        document.onkeydown = (event) =>
            # do not intercept Ctrl^ commands
            ctrlDown = event.ctrlKey || event.metaKey # Mac support
            if ctrlDown
                # execute default
                return

            c = event.keyCode
            # console.log c
            switch c
                #
                # 32, space -> toggle pause
                when 32
                    @togglePause()
                    event.preventDefault()
                #
                # 37, left arrow -> prev
                when 37
                    $("#slideshow").superslides("prev")
                    @togglePause() if playing
                    event.preventDefault()
                #
                # 39, right arrow -> next
                when 39
                    $("#slideshow").superslides("next")
                    @togglePause() if playing
                    event.preventDefault()
                #
                # 70, f -> toggle fullscreen
                when 70
                    title_ui.toggle()
                    event.preventDefault()
                #
                # 82, r -> load new slides
                when 82
                    # FIXME: to set playing=true is hackish, see togglePause
                    playing = true
                    @updateSlideData()
                    event.preventDefault()


    togglePause: =>
        if playing
            playing = false
            @abortNextSlide()
            $("#state").text("||").addClass("paused")
            console.log "Slideshow paused"
        else
            playing = true
            # use request animation frame or timeout?
            if animate
                @nextSlideDeferred = @slideDelayAnimate (Date.now() - @current_dt), @current_delay
            else
                @nextSlideTimeout = @slideDelay()
            $("#state").text("").removeClass("paused")
            console.log "Slideshow playing"


    abortNextSlide: =>
        if @nextSlideTimeout
            clearTimeout @nextSlideTimeout
        if @nextSlideDeferred
            @nextSlideDeferred.reject()


    # render slides using Transparency.js
    renderSlides: =>
        # stop any other active slide animation deffereds
        @abortNextSlide()
        # clear current slide abruptly
        $(".slides").html()
        # render new slideset
        $(".slides").render(
            @slideData,
            {slide: -> html: @slide_html})
        $(".fullimg img").css
            width: "auto",
            height: "#{SCREEN_HEIGHT}px"
        $(".slides").trigger("slides.animated")


    renderCurrent: =>
        try
            slide_nr = $('#slideshow').superslides("current")
            # console.log "Slide nr #{slide_nr}"
            # console.log @slideData[slide_nr]

            # trust dom slide indexing
            title_el = $(".title_container")[slide_nr]
            title_text = $(title_el).text().trim()
            # ..or use original?
            # console.log @slideData[slide_nr].slide_html
            title_ui.show title_text, false

            @abortNextSlide()

            delay = @slideData[slide_nr].slide_delay
            if delay
                # this delay is in seconds, convert to ms
                @current_delay = delay * 1000
                # console.log "slide delay: #{@current_delay}"
            else
                # default, 10 sec
                @current_delay = 10000

            progress_text = "#{slide_nr+1} / #{_.size @slideData}"
            if animate
                wrapper = $("#next-slide-delay")
                knob = '<input type="text" value="0" class="dial">'
                $(wrapper)
                    .html("")
                    .append(knob)
                $("#next-slide-delay .dial").knob
                    readonly: true
                    skin: "tron"
                    fgColor: "#efefef"
                    bgColor: "#222222"
                    thickness: ".2"
                    displayPrevious: true
                    width: 180
                    max: @current_delay
                    dialText: progress_text
                    val: 0
                @current_dt = 0
                $("#next-slide-delay .dial")
                    .val(@current_dt)
                    .trigger("change")
            else
                wrapper = $("#next-slide-delay")
                wrapper
                    .text(progress_text)
                    .css
                        "font-size": "3em"

                $("#state").css
                    bottom: "2em"

            if playing
                # use request animation frame or timeout?
                if animate
                    @nextSlideDeferred = @slideDelayAnimate(Date.now(), @current_delay)
                else
                    @nextSlideTimeout = @slideDelay()
                $("#state").text("").removeClass("paused")

        catch err
            console.log "Failed to lookup slide from index #{slide_nr}"
            console.log err


    initSlideshow: =>
        $('#slideshow').superslides
            play: false
            container_class: "slides"

        $("body").on "slides.initialized", "#slideshow", =>
            console.log 'Superslides initialized!'
            $(".slides").bind(
                "slides.animated", @renderCurrent
            ).fadeIn(5000)


    # Change slide after a timeout.
    slideDelay: (delay) =>
        return unless playing
        delay ?= 10000
        return setTimeout =>
            $("#slideshow").superslides("next")
        , delay


    # Change slide within animation frame, the delay is shown on jQuery.Knob dial.
    slideDelayAnimate: (t0, delay, deferred) =>
        # Deferred acts as "clearTimeout" to this RequestAnimationFrame
        # when its state is either resolved or rejected.
        deferred ?= new $.Deferred()
        return deferred if deferred.state() != "pending"
        delay ?= 30000
        t0 ?= Date.now()
        t1 = Date.now()
        @current_dt = t1 - t0
        @current_delay = delay
        if (@current_dt) < delay
            # continue
            $("#next-slide-delay .dial")
                .val(@current_dt)
                .trigger("change")
            unless playing
                deferred.reject()
                return deferred
            requestAnimationFrame => @slideDelayAnimate(t0, delay, deferred)
        else
            # timeout
            $("#next-slide-delay .dial")
                .val(delay)
                .trigger("change")
            $("#slideshow").superslides("next")
            deferred.resolve()
        return deferred


    updateSlideData: =>
        # this return is a hack; see togglePause()
        return unless playing
        notifier_ui.show "Arvotaan uusia kuvia.."

        deferred = new $.Deferred()
        promise = deferred.promise()
        promise.done =>
            notifier_ui.clear()
        promise.fail (err) =>
            console.log err
            notifier_ui.show "Taustaprosessiin ei saada yhteyttä", false

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
            console.log "GET #{@json_url}"
            $.ajax
                url: @json_url,
                dataType: 'json',
                cache: false,
                timeout: 300000,
                success: (data, textStatus, jqXHR) =>
                    console.log("Info: received #{data.length} images from #{@json_url}")
                    @slideData = data
                    @renderSlides()
                    deferred.resolve()

                error: (jqXHR, textStatus, errorThrown) ->
                    deferred.reject("#{textStatus}: #{errorThrown}")

        return promise

