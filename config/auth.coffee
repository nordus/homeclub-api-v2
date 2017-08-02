firebaseConfig  = require( '../app/lib/firebase-service-account-key.json' )
jwt = require 'jsonwebtoken'


# exports.requiresRole = (role) ->
#   (req, res, next) ->
#     if req.isAuthenticated() and req.user.roles[role]
#       next()
#     else
#       res.status 403
#       res.end()

# exports.requiresApiLogin = (req, res, next) ->
#   if req.isAuthenticated()
#     next()
#   else
#     res.status 403
#     res.end()

exports.setUserFromAuthToken = ( req, res, next ) ->
  if !req.user && req.headers.authorization
    token     = req.headers.authorization.split(' ')[1]
    req.user  = jwt.decode( token, firebaseConfig.private_key ).claims

  next()