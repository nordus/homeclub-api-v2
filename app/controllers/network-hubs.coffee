mongoose          = require( 'mongoose' )
Gateway           = mongoose.model( 'Gateway' )
whiteListedAttrs  = '-__v'
_                 = require( 'lodash' )


exports.index = (req, res) ->
  Gateway.find {}, (err, gateways) ->
    res.json gateways


exports.create = (req, res) ->
  Gateway.create req.body, (err, gateways) ->
    res.json gateways


exports.show = (req, res) ->
  Gateway.findOne _id:req.params.id, whiteListedAttrs, (err, gateway) ->
    res.json gateway


exports.update = (req, res) ->

  delete req.body._id

  query =
    $set  : req.body

  if req.body.pendingOutboundCommand is null
    delete req.body.pendingOutboundCommand

    query.$unset =
      pendingOutboundCommand  : ''

  if req.body.customerAccount
    req.body.customerAccount = mongoose.Types.ObjectId( req.body.customerAccount )

  Gateway.findOneAndUpdate
    _id: req.params.id
  ,
    query
  ,
    new : true
  , (err, gateway) ->
    if err
      console.log '[Gateway.findOneAndUpdate] ERROR:'
      console.log err
      res.json exploded:true
    else
      res.json gateway


exports.delete = (req, res) ->
  Gateway.findByIdAndRemove req.params.id, (err, gateway) ->
    return res.json(err)  if err
    res.json gateway