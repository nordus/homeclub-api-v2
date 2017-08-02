db        = require('../../config/db')
mongoose  = require( 'mongoose' )
{CarrierAdmin} = db.models
whiteListedAttrs  = '-__v'


exports.index = (req, res) ->

  carrierId = req.user.roles.carrierAdmin?.carrier._id

  params = switch carrierId
    when undefined then {}
    else carrier: mongoose.Types.ObjectId( carrierId )

  CarrierAdmin.find params, (err, carrierAdmins) ->
    res.json carrierAdmins


exports.create = (req, res) ->
  CarrierAdmin.create req.body, (err, carrier) ->
    res.json carrier


exports.show = (req, res) ->
  CarrierAdmin.findOne db.Types.ObjectId(req.params.id), whiteListedAttrs, (err, carrierAdmin) ->
    res.json carrierAdmin


exports.delete = (req, res) ->
  CarrierAdmin.findByIdAndRemove db.Types.ObjectId(req.params.id), (err, admin) ->
    return res.json(err)  if err
    res.json admin