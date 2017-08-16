koa = require 'koa'
serve = require 'koa-static'
new koa()
  .use serve 'www'
  .listen 1337
