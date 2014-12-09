app = require('../../app.coffee').app
should = require('chai').should()
request = require 'supertest'
config = require '../../config'
serverHelper = require '../helpers/server'

server = null

describe 'api/auth', ->
  url = 'http://127.0.0.1:3000'

  before (done)->
    server = serverHelper.createServer(done)

  after (done)->
    server.close()
    done()

  it "should return code 400, when POST \"/login\" route without credentials", (done)->
    request(url)
      .post('/login')
      .set('Authorization', "Basic asdasd456")
#      .expect('Content-Type', /json/)
      .expect(400)
      .end (err,res) ->
        if err then throw err
        done()