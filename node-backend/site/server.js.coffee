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
homeDir = "#{__dirname}/.."

app = module.exports = express.createServer()

css = piler.createCSSManager()
js = piler.createJSManager()
css.bind app
js.bind app


defaults =
    port: 8080
    sessionSecret: "Very secret string. (override me)"

try
    config = JSON.parse fs.readFileSync rootDir + "config.json"
catch e
    config = {}
    console.error "Could no load config.json. Using defaults."

for k, v of defaults
    config[k] ?= v


if process.env.NODE_ENV == "production"
    app.settings.env == "production"


app.configure ->
    # use handlebars template engine
    app.set "views", "#{homeDir}/app/views"
    app.set "view engine", "hbs"

    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router

    # Connect Handlebars to Piler Asset Manager
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

    # assets
    js.addFile "#{homeDir}/assets/javascripts/jquery.js"
    js.addFile "#{homeDir}/assets/javascripts/jquery-ui.js"
    js.addFile "#{homeDir}/assets/javascripts/underscore.js"
    js.addFile "#{homeDir}/assets/javascripts/jquery.superslides.js"
    js.addFile "#{homeDir}/assets/javascripts/transparency.js"
    js.addFile "#{homeDir}/assets/javascripts/moment.js"
    js.addFile "#{homeDir}/assets/javascripts/moment-fi.js"
    css.addFile "#{homeDir}/assets/stylesheets/jquery-ui.css"

    # app
    js.addFile "#{homeDir}/app/client.js.coffee"
    css.addFile "#{homeDir}/app/styles/main.styl"
    css.addFile "#{homeDir}/app/styles/reset.styl"
    css.addFile "#{homeDir}/app/styles/client.css"


app.configure "development", ->
    js.liveUpdate css
    app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure "production", ->
    app.use express.errorHandler()

# Add routes and real application logic
require("#{homeDir}/app/routes.js") app, js, css, config

# start the server
port = process.env.PORT || 8080
app.listen port, ->
    console.log(
        "Express server listening on port %d in %s mode",
        app.address().port, app.settings.env)
