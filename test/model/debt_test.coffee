app = require('../../app.coffee').app
expect = require('chai').expect
http = require 'http'
config = require '../../config'
clearDatabase = require '../../database/clear'
syncDatabase = require '../../database/schema'
fixturesDatabase = require '../../database/fixtures'
serverHelper = require '../helpers/server'
moment = require "moment"
debtTable = require '../../models/debt'

server = null

describe 'model/debt', ()->
  before (done)->
    server = serverHelper.createServer done

  after (done)->
    server.close()
    done()

  describe 'Debt getById', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/debt_fixtures/getById.json', (error, result)->
            done()

    it "should return debt, if debt exists", (done)->
      debtTable.getById 1, (error, debt)->
        expect(debt).to.have.property 'id', 1
        done()

    it "should return undefined, if debt doesn't exists", (done)->
      debtTable.getById 9999, (error, debt)->
        expect(debt).to.be.undefined
        done()

    it "should return undefined, if debt exists but is deleted", (done)->
      debtTable.getById 5, (error, debt)->
        expect(debt).to.be.undefined
        done()
#
  describe 'getUserDebtById', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/debt_fixtures/getUserDebtById.json', (error, result)->
            done()

    it "should return debt, if user is lender", (done)->
      debtTable.getUserDebtById 1, 1, (error, debt)->
        expect(debt).to.have.property 'id', 1
        done()

    it "should return debt, if user is debtor", (done)->
      debtTable.getUserDebtById 1, 2, (error, debt)->
        expect(debt).to.have.property 'id', 2
        done()

    it "should return undefined, if debt exists but is deleted", (done)->
      debtTable.getUserDebtById 1, 3, (error, debt)->
        expect(debt).to.be.undefined
        done()
#
  describe 'getAll debts', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/debt_fixtures/getAll.json', (error, result)->
            done()

    it "should return 8 debts, if user is lender and there is no filters", (done)->
      debtTable.getAll 1, {}, (error, debts)->
        expect(debts.length).to.eql(8)
        done()

    it "should return 2 debts, if from is equal \"1999-02-02 00:00:00\"", (done)->
      filters =
        from: moment("1999-02-02 00:00:00").valueOf()

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(2)
        done()

    it "should return 1 debt, if to is equal \"1999-01-01 00:00:00\"", (done)->
      filters =
        to: moment("1999-01-01 00:00:00").valueOf()

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(1)
        done()

    it "should return 1 debt, if contractor_name is  \"Peter\"", (done)->
      filters =
        contractor_name: "Peter"

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(1)
        done()

    it "should return 1 debt, if contractor is equal \"3\"", (done)->
      filters =
        contractor: 3

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(1)
        done()

    it "should return no debts, if status is equal \"3\"", (done)->
      filters =
        status: 3

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(0)
        done()

    it "should return 1 debt, if status is equal \"2\"", (done)->
      filters =
        status: 2

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(1)
        done()

    it "should return 8 debts, if name is equal \"debt\"", (done)->
      filters =
        name: "debt"

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(8)
        done()

    it "should return 2 debts, if name is equal \"1\"", (done)->
      filters =
        name: "1"

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(2)
        done()

    it "should return 4 debts, if limit is equal \"4\"", (done)->
      filters =
        limit: 4

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(4)
        done()

    it "should return 2 debts, if limit is equal \"4\" and offset is equal \"6\"", (done)->
      filters =
        limit: 4
        offset: 6

      debtTable.getAll 1, filters, (error, debts)->
        expect(debts.length).to.eql(2)
        done()

    it "should return no debts, if user does not exists", (done)->
      debtTable.getAll 4, {}, (error, debts)->
        expect(debts.length).to.eql(0)
        done()

  describe 'getSummary', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/debt_fixtures/getSummary.json', (error, result)->
            done()

    it "should return no -1.00 for user#1, if there is no filters", (done)->
      debtTable.getSummary 1, {}, (error, summary)->
        expectedValue = -1
        expect(summary).to.eql(expectedValue.toFixed(2))
        done()

    it "should return no 118.00 for user#2, if there is no filters", (done)->
      debtTable.getSummary 2, {}, (error, summary)->
        expectedValue = 118
        expect(summary).to.eql(expectedValue.toFixed(2))
        done()

#  describe 'getNbOfdebtsWaitingForAcceptance', ()->
#
#    beforeEach (done)->
#      clearDatabase.exec (error, result) ->
#        syncDatabase.exec (error, result) ->
#          fixturesDatabase.load '/test/model/debt_fixtures/getNbOfdebtsWaitingForAcceptance.json', (error, result)->
#            done()
#
#    it "should return no 0 for user#1", (done)->
#      debtTable.getNbOfdebtsWaitingForAcceptance 1, (error, nbOfdebts)->
#        expect(nbOfdebts.aggregate).to.eql('0')
#        done()
#
#    it "should return no 3 for user#2", (done)->
#      debtTable.getNbOfdebtsWaitingForAcceptance 2, (error, nbOfdebts)->
#        expect(nbOfdebts.aggregate).to.eql('3')
#        done()