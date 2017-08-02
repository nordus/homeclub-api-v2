async       = require 'async'
mongoose    = require 'mongoose'
envConfig   = require './env-config'
requireDir  = require 'require-directory'


# set Promise provider to native / es6-shim
mongoose.Promise = global.Promise;

# load mongoose models
requireDir module, "#{__dirname}/../app/models"

options =
  server:
    socketOptions:
      keepAlive         : 300000
      connectTimeoutMS  : 30000

db = mongoose.connect( envConfig.db, options )

db.wipe = (cb) ->
  async.parallel (m.remove.bind m for _, m of db.models), cb


# module.exports = db
module.exports = mongoose.connection