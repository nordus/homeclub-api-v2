async             = require 'async'
mongoose          = require( 'mongoose' )
CustomerAccount   = mongoose.model( 'CustomerAccount' )
User              = mongoose.model( 'User' )
whiteListedAttrs  = '-__v'


exports.create = (req, res) ->
  async.parallel
    user: (cb) ->
      User.create req.body, cb
    customerAccount: (cb) ->
      CustomerAccount.create req.body, cb
  , (e, r) ->
    r.user.link 'customerAccount', r.customerAccount, (e, r) ->
      return res.json(500, { error:e })  if e
      res.json r


exports.index = (req, res) ->
  carrierId             = req.user.roles.carrierAdmin?.carrier._id

  params = switch carrierId
    when undefined then {}
    else carrier: mongoose.Types.ObjectId( carrierId )

  # select all attributes by default
  attrsToSelect = req.query.select || ''

  CustomerAccount.find params, attrsToSelect, ( e, accounts ) ->
    res.json accounts


exports.update = (req, res) ->
  delete req.body._id
  delete req.body.__v
  if req.body.user && req.body.user._id
    req.body.user = mongoose.Types.ObjectId(req.body.user._id)

  CustomerAccount.findOneAndUpdate _id: mongoose.Types.ObjectId(req.params.id),
    $set: req.body
  , (err, account) ->
    CustomerAccount.findById account._id, ( e, updatedAccount ) ->
      res.json updatedAccount


exports.show = (req, res) ->
  CustomerAccount.findOne mongoose.Types.ObjectId(req.params.id), whiteListedAttrs, (err, customerAccount) ->
    res.json customerAccount


exports.delete = (req, res) ->
  CustomerAccount.findByIdAndRemove mongoose.Types.ObjectId(req.params.id), (err, account) ->
    return res.json(err)  if err
    res.json account