knex = require 'knex'

module.exports =
  postgres: if process.env.DATABASE_URL then knex.initialize({
    client: 'pg',
    debug: true,
    connection: process.env.DATABASE_URL
    ssl: true
  }) else knex.initialize({
    client: 'pg',
    connection:
      host: '127.0.0.1',
      user: 'root',
      password: 'root',
      database: 'ioweyou',
      charset: 'utf8'
  })