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

express = require "express"
fs = require "fs"
hbs = require "hbs"
piler = require "piler"

exports.start = ->
    # Create Express-2 server
    app = module.exports = express.createServer()
    # use Piler asset manager
    css = piler.createCSSManager()
    js = piler.createJSManager()
    css.bind app
    js.bind app

    rootDir = "#{__dirname}/.."

    # Locate and read /etc/iivari-express.conf.
    # Extends config from rootDir config.json.
    defaults =
        port: 8080
        sessionSecret: "Very secret string. (override me)"
        slideshow: { url: "file:///media/usb" }
    try
        conf_file = "/etc/iivari-express.conf"
        config = JSON.parse fs.readFileSync conf_file
    catch e
        config = {}
        console.error "Could not load #{conf_file}."
    try
        for k, v of JSON.parse(fs.readFileSync rootDir + "/config.json")
            config[k] ?= v
    for k, v of defaults
        config[k] ?= v
    console.log "Info: slideshow url: #{config.slideshow.url}, theme: #{config.slideshow.theme}"

    if process.env.NODE_ENV == "production"
        app.settings.env == "production"


    app.configure ->
        app.use express.bodyParser()
        app.use express.methodOverride()
        app.use app.router

        # Use and connect Handlebars to Piler
        app.set "views", "#{rootDir}/client/views"
        app.set "view engine", "hbs"

        hbs.registerHelper "renderScriptTags", (pile) ->
            js.renderTags pile
        hbs.registerHelper "renderStyleTags", (pile) ->
            css.renderTags pile

        # We want use same templating engine for the client and the server. We have
        # to workarount bit so that we can get uncompiled Handlebars templates
        # through Handlebars
        hbs.registerHelper "clientTemplate", (name) ->
            source = templateCache[name + ".hbs"]
            if not source
                # Synchronous file reading is bad, but it doesn't really matter here since
                # we can cache it in production
                source = fs.readFileSync rootDir + "/views/client/#{ name }.hbs"

        # Add vendor assets to Piler
        css.addFile "#{rootDir}/vendor/stylesheets/jquery-ui.css"
        js.addFile "#{rootDir}/vendor/javascripts/jquery.js"
        js.addFile "#{rootDir}/vendor/javascripts/jquery-ui.js"
        js.addFile "#{rootDir}/vendor/javascripts/jquery.knob.js"
        js.addFile "#{rootDir}/vendor/javascripts/underscore.js"
        js.addFile "#{rootDir}/vendor/javascripts/transparency.js"
        js.addFile "#{rootDir}/vendor/javascripts/moment.js"
        js.addFile "#{rootDir}/vendor/javascripts/moment-fi.js"
        js.addFile "#{rootDir}/vendor/javascripts/RequestAnimationFrame.js"

        # Add application assets to Piler
        css.addFile "#{rootDir}/client/styles/reset.styl"
        css.addFile "#{rootDir}/client/styles/main.styl"
        js.addFile "#{rootDir}/client/slideshow.coffee"
        js.addFile "#{rootDir}/client/jquery.superslides.coffee"
        js.addFile "#{rootDir}/client/uimessage.coffee"


    app.configure "development", ->
        js.liveUpdate css
        app.use express.errorHandler { dumpExceptions: true, showStack: true }

    app.configure "production", ->
        app.use express.errorHandler()

    # Add routes and application logic
    require("./routes") app, js, css, config

    # Start the server
    port = process.env.PORT || config.port
    app.listen port, ->
        console.log(
            "Iivari-Express listening on port %d in %s mode",
            app.address().port, app.settings.env)
