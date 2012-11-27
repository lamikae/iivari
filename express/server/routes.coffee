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

http = require "http"
slides = require "./slides"

module.exports = (app, js, css, config) ->

    app.get "/index", (req, res) ->
        console.log "GET /index"
        res.render('index', { title: 'Express greetings!' })


    app.get "/client", (req, res) ->
        console.log "GET /client"
        try
            theme = config.slideshow.theme
        catch e
            theme = "default"
        try
            # FIXME: access package.json version
            res.render 'slideshow', { theme: theme, title: "Iivari-express v0.9.2" }
        catch e
            console.log e


    app.get "/slides", (req, res) ->
        console.log "GET /slides"
        try
            slides.FileSystemSlides.config config.slideshow
            res.json slides.FileSystemSlides.shuffle()
        catch e
            console.log e
