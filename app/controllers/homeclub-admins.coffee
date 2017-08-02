
db                = require( '../../config/db' )
mongoose          = require( 'mongoose' )
{HomeClubAdmin}   = db.models
whiteListedAttrs  = '-__v'


exports.create = ( req, res ) ->
  HomeClubAdmin.create req.body, ( err, admin ) ->
    res.json admin


exports.show = (req, res) ->
  HomeClubAdmin.findOne mongoose.Types.ObjectId( req.params.id ), whiteListedAttrs, ( err, homeClubAdmin ) ->
    res.json homeClubAdmin


exports.delete = (req, res) ->
  HomeClubAdmin.findByIdAndRemove mongoose.Types.ObjectId( req.params.id ), ( err, homeClubAdmin ) ->
    return res.json( err )  if err
    res.json homeClubAdmin