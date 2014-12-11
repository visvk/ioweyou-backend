app = require('../../app.coffee').app
should = require('chai').should()
request = require 'supertest'
config = require '../../config'
serverHelper = require '../helpers/server'

server = null

describe 'api/entry', ->
  url = 'http://127.0.0.1:3000'

#  before (done)->
#    server = serverHelper.createServer(done)
#
#  after (done)->
#    server.close()
#    done()

  it "should return code 401, when GET \"/entries\" route without credentials", (done)->
    request(url)
      .get('/debts')
      .set('Authorization', "")
      #      .expect('Content-Type', /json/)
      .expect(401)
      .end (err,res) ->
#        console.log res.body
        if err then throw err
        done()

  it "should return code 200, when GET \"/entries\" route with token", (done)->
    request(url)
      .get('/debts')
      .set('Authorization', "Bearer llll")
  #      .expect('Content-Type', /json/)
      .expect(200)
      .end (err,res) ->
        console.log res.body
        if err then throw err
        done()
#
#  it "should return code 401, when GET \"/entry/summary\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("GET", "/entry/summary"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when GET \"/entry/count\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("GET", "/entry/count"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when GET \"/entry/:id\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("GET", "/entry/1"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when POST \"/entries\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("POST", "/entries"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when PATCH \"/entry/:id\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("PATCH", "/entry/1"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when POST \"/entry/accept/:id\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("POST", "/entry/accept/1"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when POST \"/entry/reject/:id\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("POST", "/entry/reject/1"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()
#
#  it "should return code 401, when DELETE \"/entry/:id\" route without credentials", (done)->
#    http.get serverHelper.getHeaders("DELETE", "/entry/1"), (res)->
#      res.on 'data', (chunk)->
#        res.statusCode.should.eql(401)
#      res.on 'end', ()->
#        done()