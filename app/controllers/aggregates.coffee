db              = require('../../config/db')
mongoose        = require( 'mongoose' )
# CustomerAccount = mongoose.model( 'CustomerAccount' )
# SensorHub       = mongoose.model( 'SensorHub' )
# Gateway         = mongoose.model( 'Gateway' )
# OutboundEmail   = mongoose.model( 'OutboundEmail' )
# OutboundSms     = mongoose.model( 'OutboundSms' )
{CustomerAccount, SensorHub, Gateway, OutboundEmail, OutboundSms} = db.models
async           = require( 'async' )
_               = require( 'lodash' )


module.exports = (req, res) ->

  if carrierId = req.user.roles.carrierAdmin?.carrier._id
    CustomerAccount.where( carrier: mongoose.Types.ObjectId(carrierId) ).select('gateways').populate('gateways', 'sensorHubs').lean().exec (e, customerAccounts) ->
      gateways = _.flatten(_.map(customerAccounts, 'gateways'))
      sensorHubs = _.flatten(_.map(gateways, 'sensorHubs'))
      customerAccountIds = _.map(customerAccounts, '_id')
      async.parallel
        outboundEmailCount  : (cb) -> OutboundEmail.where('customerAccount').in(customerAccountIds).count {}, cb
        outboundSmsCount    : (cb) -> OutboundSms.where('customerAccount').in(customerAccountIds).count {}, cb
      , (e, r) ->
        res.json
          customerAccounts  : customerAccounts.length
          gateways          : gateways.length
          sensorHubs        : sensorHubs.length
          outboundEmails    : r.outboundEmailCount
          outboundSms       : r.outboundSmsCount
  else
    async.parallel
      customerAccounts  : (cb) -> CustomerAccount.count {}, cb
      sensorHubs        : (cb) -> SensorHub.count {}, cb
      gateways          : (cb) -> Gateway.count {}, cb
      outboundEmails    : (cb) -> OutboundEmail.count {}, cb
      outboundSms       : (cb) -> OutboundSms.count {}, cb
    , (e, r) ->
      res.json r
  # async.parallel
  #   customerAccounts  : (cb) -> CustomerAccount.count {}, cb
  #   sensorHubs        : (cb) -> SensorHub.count {}, cb
  #   gateways          : (cb) -> Gateway.count {}, cb
  #   outboundEmails    : (cb) -> OutboundEmail.count {}, cb
  #   outboundSms       : (cb) -> OutboundSms.count {}, cb
  # , ( e, r ) ->
  #   res.json r