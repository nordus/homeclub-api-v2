mongoose  = require( 'mongoose' )
db        = require( '../../config/db' )
{CarrierAdmin, CustomerAccount, Gateway, HomeClubAdmin} = db.models


exports.customerAccount = (req, res) ->
  CustomerAccount.findOne( mongoose.Types.ObjectId( req.user.roles.customerAccount._id ) ).populate( 'user gateways carrier' ).exec ( e, account ) ->
    res.json account


exports.networkHub      = ( req, res ) ->
  gatewayId = req.user.roles.customerAccount.gateways[0]._id
  Gateway.findOne( _id: gatewayId ).exec ( e, nh ) ->
    res.json nh

exports.updateNetworkHubSubscriptions = (req, res) ->
  Gateway.findById req.body._id, ( err, gateway ) ->

    if req.body.emailSubscriptions.length > 0
      gateway.emailSubscriptions.splice 0, gateway.emailSubscriptions.length, req.body.emailSubscriptions...
    else
      gateway.emailSubscriptions.splice 0, gateway.emailSubscriptions.length

    if req.body.smsSubscriptions.length > 0
      gateway.smsSubscriptions.splice 0, gateway.smsSubscriptions.length, req.body.smsSubscriptions...
    else
      gateway.smsSubscriptions.splice 0, gateway.smsSubscriptions.length
    
    gateway.save ( err ) ->
      res.json gateway