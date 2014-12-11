app = require('../../app.coffee').app
should = require('chai').should()
request = require 'supertest'
config = require '../../config'
serverHelper = require '../helpers/server'

server = null

describe 'api/debt', ->
  url = 'http://127.0.0.1:3000'

  before (done)->
    server = serverHelper.createServer(done)

  after (done)->
    server.close()
    done()

  beforeEach (done)->

  it "should return code 401, when GET \"/debts\" route without credentials", (done)->
    request(url)
      .get('/debts')
      .set('Authorization', "")
      .expect('Content-Type', /json/)
      .expect(401)
      .end (err,res) ->
#        console.log res.body
        if err then throw err
        done()

  it "should return code 200, when GET \"/debts\" route with token", (done)->
    request(url)
      .get('/debts')
      .set('Authorization', "Bearer llll")
  #      .expect('Content-Type', /json/)
      .expect(200)
      .end (err,res) ->
        console.log res.body
        if err then throw err
        done()

  it "should return code 401, when GET \"/debts/summary\" route without credentials", (done)->
    http.get serverHelper.getHeaders("GET", "/debts/summary"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when GET \"/debts/count\" route without credentials", (done)->
    http.get serverHelper.getHeaders("GET", "/debts/count"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when GET \"/debts/:id\" route without credentials", (done)->
    http.get serverHelper.getHeaders("GET", "/debts/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when POST \"/debts\" route without credentials", (done)->
    http.get serverHelper.getHeaders("POST", "/debts"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when PATCH \"/debts/:id\" route without credentials", (done)->
    http.get serverHelper.getHeaders("PATCH", "/debts/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when POST \"/debts/accept/:id\" route without credentials", (done)->
    http.get serverHelper.getHeaders("POST", "/debts/accept/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when POST \"/debts/reject/:id\" route without credentials", (done)->
    http.get serverHelper.getHeaders("POST", "/debts/reject/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when DELETE \"/debts/:id\" route without credentials", (done)->
    http.get serverHelper.getHeaders("DELETE", "/debts/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()