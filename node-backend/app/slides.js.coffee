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
glob = require "glob"
_ = require "underscore"

class exports.FileSystemSlides

    @complete_slides = null
    @media_root = "/media/usb"

    @find = () ->
        options = {}
        try
            # parse the filesystem tree only once, cache the result
            unless @complete_slides
                images = _.compact _.map glob.sync("#{@media_root}/**/*", options), (file) ->
                    file if file.match /jpg/i

                @complete_slides = _.compact _.map images, (imagefile) ->
                    return null unless imagefile
                    {
                        "slide_html": image_to_slide_html(imagefile),
                        "slide_delay": 15
                    }

            slides = _.shuffle(@complete_slides)[0...20]
            # console.log slides
            return slides

        catch err
            console.log "Error reading images: #{err}"
            return []


    image_to_slide_html = (file) ->
        style = "gold"
        title = file
        """
        <div class="title_container #{style}">\
            <h1 class="title">#{title}</h1>\
        </div>\
        <div class="content">\
            <div class="fullimg"><img src="file://#{file}"></div>\
        </div>'
        """

