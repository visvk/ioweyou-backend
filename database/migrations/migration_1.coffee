db = require '../../db'
Q = require 'q'


module.exports =
  version: 1
  description: "Initial migration, remove old unused tables. New naming convention."
  exec: () ->
    exec()


exec = () ->

  done = Q () ->

  return done