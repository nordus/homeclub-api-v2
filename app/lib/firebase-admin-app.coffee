
admin           = require 'firebase-admin'
serviceAccount  = require './firebase-service-account-key.json'

module.exports  = admin.initializeApp
  credential: admin.credential.cert( serviceAccount )
  databaseURL: 'https://homeclub-api.firebaseio.com'