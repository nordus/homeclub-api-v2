
path              = require( 'path' )
_                 = require 'lodash'
db                = require('../../config/db')
{CustomerAccount, SensorHub, DeviceThresholds} = db.models
mongoose          = require( 'mongoose' )
whiteListedAttrs  = '-__v'


setSensorHubMacAddressesOfCarrier = ( req, res, next ) ->
  if req.user.roles.homeClubAdmin
    CustomerAccount.find().select( 'gateways' ).populate( 'gateways' ).lean().exec ( e, customerAccounts ) ->
      gateways = _.flatten( _.map( customerAccounts, 'gateways' ) )
      req.sensorHubMacAddressesOfCarrier = _.flatten( _.map( gateways, 'sensorHubs' ) )
      next()
  else if carrierId = req.user.roles.carrierAdmin?.carrier._id
    CustomerAccount.where( carrier: mongoose.Types.ObjectId( carrierId ) ).select( 'gateways' ).populate( 'gateways' ).lean().exec ( e, customerAccounts ) ->
      gateways = _.flatten( _.map( customerAccounts, 'gateways' ) )
      req.sensorHubMacAddressesOfCarrier = _.flatten( _.map( gateways, 'sensorHubs' ) )
      next()
  else
    next()

index = ( req, res, next ) ->
  sensorHubMacAddresses = req.sensorHubMacAddressesOfCarrier || req.user.roles.customerAccount.gateways[0].sensorHubs

  params = switch sensorHubMacAddresses
    when undefined then {}
    else _id:
      $in:sensorHubMacAddresses

  SensorHub.find params, ( e, sensorHubs ) ->
    res.json sensorHubs

exports.index = [setSensorHubMacAddressesOfCarrier, index]


exports.update = (req, res) ->
  delete req.body._id

  SensorHub.findOneAndUpdate
    _id: req.params.id
  ,
    $set: req.body
  , (err, sensorHub) ->
    res.json sensorHub


# exports.show = (req, res) ->
#   SensorHub.findOne req.params.id, whiteListedAttrs, (err, sensorHub) ->
#     res.json sensorHub


# exports.create = (req, res) ->
#   # create / link DeviceThresholds record
#   DeviceThresholds.create {}, (err, deviceThresholds) ->
#     res.json err  if err
#     req.body.deviceThresholds = deviceThresholds._id
#     SensorHub.create req.body, (err, sensorHub) ->
#       res.json err || sensorHub