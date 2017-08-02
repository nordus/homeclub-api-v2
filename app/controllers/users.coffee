_                 = require 'lodash'
async             = require 'async'
db                = require '../../config/db'
mongoose          = require 'mongoose'

whiteListedAttrs  = '-__v -hashedPassword -salt'
{CustomerAccount, User}  = db.models
    
    
exports.index = (req, res) ->
  if req.query.carrier
    CustomerAccount.where( carrier: req.query.carrier ).select( 'user' ).populate( 'user' ).lean().exec ( e, accts ) ->
      return res.json _.map accts, 'user'
  else
    User.find({}, whiteListedAttrs).exec (err, users) ->
      res.json users


exports.update = (req, res) ->

  # ensure non-admin can only update their own account
  notAdmin = !req.user.roles.homeClubAdmin && !req.user.roles.carrierAdmin

  #if req.user._id != req.body._id && notAdmin
    #req.status 403
    #return res.end()


  if req.body.roles && Object.keys(req.body.roles).length
    (req.body.roles[k] = mongoose.Types.ObjectId(v)) for k,v in req.body.roles

  User.findOne mongoose.Types.ObjectId(req.params.id), (e, user) ->
    if req.body.email
      user.email = req.body.email
    if req.body.roles
      if Object.keys(req.body.roles).length
        user.roles = req.body.roles
      else
        user.roles = undefined
    user.save (e, user) ->
      res.json user


exports.delete = (req, res) -> 
  User.findByIdAndRemove mongoose.Types.ObjectId(req.params.id), (err, user) ->
    return res.json(err)  if err
    res.json user


exports.show = (req, res) ->
  User.findOne mongoose.Types.ObjectId(req.params.id), whiteListedAttrs, (err, user) ->
    res.json user
