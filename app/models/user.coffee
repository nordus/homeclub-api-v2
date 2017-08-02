async     = require('async')
crypto    = require('crypto')
mongoose  = require('mongoose')


userSchema = new mongoose.Schema
  createdAt:
    default: Date.now
    type: Date

  email:
    type: String
    unique: true

  roles:
    carrierAdmin:
      ref   : 'CarrierAdmin'
      type  : mongoose.Schema.Types.ObjectId
    customerAccount:
      ref   : 'CustomerAccount'
      type  : mongoose.Schema.Types.ObjectId
    homeClubAdmin:
      ref   : 'HomeClubAdmin'
      type  : mongoose.Schema.Types.ObjectId

  isActive        : Boolean
  hashedPassword  : String
  salt            : String
  tos             : Boolean
  isDebugTester:
    default : false
    type    : Boolean


capitalize = (str) ->
  str.charAt(0).toUpperCase() + str.slice(1)

# removing a user removes all his roles
userSchema.pre 'remove', (next) ->
  for modelName, modelId of @roles.toObject()
    @model(capitalize(modelName)).findByIdAndRemove(modelId).exec()
  next()


userSchema.virtual('password').set (password) ->
  @salt = @makeSalt()
  @hashedPassword = @encryptPassword(password)

noop = ->
userSchema.methods =
  
  link: (role, document, cb = noop) ->
    r             = {}
    @roles[role]  = r[role]   = document
    document.user = r['user'] = @
    async.parallel [
      (cb) => @save cb
      (cb) -> document.save cb
    ], (err) ->
      return cb(err)  if err      
      cb(null, r)

  authenticate: (plainText) ->
    @encryptPassword(plainText) is @hashedPassword

  makeSalt: ->
    crypto.randomBytes(16).toString 'base64'

  encryptPassword: (password) ->
    salt = new Buffer(@salt, 'base64')
    crypto.pbkdf2Sync(password, salt, 10000, 64).toString 'base64'

  defaultReturnUrl: ->
    return '/admin/carrier' if @roles.carrierAdmin
    return '/admin/homeclub' if @roles.homeClubAdmin
    '/consumer'


mongoose.model 'User', userSchema