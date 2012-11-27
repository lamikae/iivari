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

should = require "should"
fs = require "fs"
path = require "path"
_ = require "underscore"
{FileSystemSlides} = require "#{__dirname}/../server/slides"

describe "FileSystemSlides", ->

    beforeEach ->
        @fixture_root = "#{__dirname}/fixtures/root1"
        FileSystemSlides.media_root = @fixture_root
        @indexfile = @fixture_root+"/"+FileSystemSlides.index_filename
        # remove image index file
        if path.existsSync @indexfile
            fs.unlinkSync @indexfile

    afterEach ->
        if path.existsSync @indexfile
            fs.unlinkSync @indexfile


    describe "shuffle", ->

        it "finds images from the filesystem", ->
            images = FileSystemSlides.images "#{__dirname}/fixtures/root1"
            _.size(images).should.eql 8
            # files are in alphabetical order
            images[0].should.eql @fixture_root+"/A/B/C/five.jpg"
            images[1].should.eql @fixture_root+"/A/B/C/four.jpg"
            images[2].should.eql @fixture_root+"/A/B/C/one.jpg"
            images[3].should.eql @fixture_root+"/A/B/C/three.jpg"
            images[4].should.eql @fixture_root+"/A/B/C/two.JPG"
            images[5].should.eql @fixture_root+"/E/F/seven.jpg"
            images[6].should.eql @fixture_root+"/E/F/six.jpg"
            images[7].should.eql @fixture_root+"/G/eight.jpeg"


        it "writes image file index", ->
            images = FileSystemSlides.images "#{__dirname}/fixtures/root1"
            _.size(images).should.eql 8
            # verify index
            path.existsSync(@indexfile).should.eql true
            images_from_index = FileSystemSlides.images "#{__dirname}/fixtures/root1"
            _.size(images_from_index).should.eql 8
            images_from_index.should.eql images


        it "randomises slides", ->
            slideset1 = FileSystemSlides.shuffle()
            _.size(slideset1).should.eql 8
            slideset2 = FileSystemSlides.shuffle()
            _.size(slideset2).should.eql 8
            slideset1.should.not.eql slideset2
