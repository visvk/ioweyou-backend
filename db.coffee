knex = require 'knex'
redis = require 'redis'

module.exports =
  postgres: knex.initialize({
    client: 'pg',
    debug: true,
    connection: process.env.DATABASE_URL + '?ssl=true'
  })
  redis: redis.createClient()