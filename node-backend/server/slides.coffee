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
fs = require "fs"
path = require "path"
_ = require "underscore"

class exports.FileSystemSlides

    @index_filename = "iivari.cache.db"
    @slides = null

    # Configurable options
    # @media_root can be served using file:// urls
    # or http:// for serving the directory remotely.
    @urlloc = ""
    @media_root = "/media/usb"
    @config = (options) =>
        @urlloc = options.url
        try
            @media_root = @urlloc.match(/file:\/\/(.*)/)[1]
            console.log "Files from local media root #{@media_root}"
            # if the filesystem is remote, @media_root should mirror it


    # Finds images from filesystem at @media_root,
    # generates slides json of 20 random images for iivari-client.
    # All found images will be rendered to slides upon first request,
    # and cached to memory.
    @shuffle = () ->
        try
            @slides = _.map @images(), (image) =>
                title = image.replace "#{@media_root}/", ""
                @slide_json image, title
            return _.shuffle(@slides)[0...20]

        catch err
            console.log "Error reading images: #{err}"
            return []


    # List of image files on @media_root.
    # A simple index is kept in @media_root/iivari.cache.db.
    # When index file contents is read and the filesystem is not traversed.
    @images = () ->
        # media root needs to be something remotely sensible
        unless @media_root.match('^/...')
            console.log "Refuse to read from #{@media_root} - minimum directory name length 3"
            return []

        # index file exists, return its contents
        indexfile = @media_root + "/" + @index_filename
        if path.existsSync indexfile
            images = JSON.parse fs.readFileSync indexfile, "utf8"
            if _.size(images) > 0
                console.log "#{_.size images} images already indexed in #{indexfile}"
                return images

        # glob filesystem and write index file
        images = find_images @media_root
        data = JSON.stringify(images)

        # Async file write, problematic with tests
        # stream = fs.createWriteStream indexfile, {
        #     flags: "a",
        #     encoding: "utf8",
        #     mode: "640",
        # }
        # stream.write data
        # stream.end()

        # Synchronous file write
        fs.writeFileSync(indexfile, data, "utf8")
        return images


    # Synchronous glob of all jpg files
    find_images = (path) ->
        console.log "Index images from #{path}"
        t0 = Date.now()

        glob_options = {}
        images = _.select glob.sync("#{path}/**/*", glob_options), (file) ->
            file.match(/jpg/i)

        t1 = Date.now()
        dt = (t1-t0)/1000
        console.log "Indexed #{_.size images} images in #{Math.floor(dt / 60)} min #{(dt % 60).toPrecision(2)} sec"
        return images


    # Slide fullscreen image template for client
    @slide_json = (image_file, title) ->
        img_path = image_file.replace @media_root, ""
        image_src = "#{@urlloc}#{img_path}"
        html = """
        <div class="title_container">\
            <h1 class="title">#{title}</h1>\
        </div>\
        <div class="content">\
            <div class="fullimg"><img src="#{image_src}"></div>\
        </div>
        """
        return {
            "slide_html": html,
            "slide_delay": 15
        }
