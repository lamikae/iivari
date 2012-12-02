render = require("../test_helper").render_hbs_template
cheerio = require "cheerio"
should = require "should"

describe "views/slideshow.hbs", ->

    it 'renders slideshow elements', ->
        html = render("slideshow.hbs", {theme: "default", title: "test"})
        $ = cheerio.load html
        $("#slide_title").should.not.be.empty
        $("#notifications").should.not.be.empty
        $("#help").should.not.be.empty
        $("#slideshow").should.not.be.empty
        $(".footer").should.not.be.empty

