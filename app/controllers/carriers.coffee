mongoose          = require( 'mongoose' )
Carrier           = mongoose.model( 'Carrier' )
whiteListedAttrs  = '-__v'


exports.index = (req, res) ->
  Carrier.find {}, (err, carriers) ->
    res.json carriers


exports.create = (req, res) ->
  Carrier.create req.body, (err, carrier) ->
    res.json carrier


exports.show = (req, res) ->
  Carrier.findOne db.Types.ObjectId(req.params.id), whiteListedAttrs, (err, carrier) ->
    res.json carrier