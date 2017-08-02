
_     = require 'lodash'
async = require 'async'
db    = require '../../config/db'
{Carrier, CustomerAccount} = db.models


module.exports  = ( req, res ) ->
  carriersByNetworkHub  = {}

  getCarriers = Carrier.find( {} ).select( '_id name' ).exec()

  getCarriers.then ( carriers ) ->
    async.each carriers, ( carrier, done ) ->
      CustomerAccount.where( carrier:carrier ).select( 'gateways' ).exec ( err, accounts ) ->
        done( err )  if err
        networkHubs = _.flatten(_.map(accounts, 'gateways'))
        networkHubs.forEach ( networkHub ) ->
          carriersByNetworkHub[networkHub._id] = carrier.name.toLowerCase()
        done()
    , ( err ) ->
      res.json err || carriersByNetworkHub
