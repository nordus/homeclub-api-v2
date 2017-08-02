env       = process.env.NODE_ENV || 'development'

config =
  development:
    db        : 'mongodb://easierbycode:5tekapU3@ds047198.mongolab.com:47198/homeclub'


module.exports = config[env]