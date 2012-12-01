request = require "supertest"
express = require "express"
path = require "path"
app = require(path.join __dirname, "..", "..", "server", "index").start()

describe "Iivari Express", ->

  describe "server index", ->
    describe 'GET /client', ->
      it 'renders client html', (done) ->
        request(app)
          .get('/client')
          .expect('Content-Type', /html/)
          .expect(200, done)

    describe 'GET /slides', ->
      it 'respond with slides json', (done) ->
        request(app)
          .get('/slides')
          .expect('Content-Type', /json/)
          .expect(200, done)
