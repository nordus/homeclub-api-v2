mongoose = require('mongoose')


carrierAdminSchema = new mongoose.Schema
  name:
    first : String
    last  : String

  carrier:
    ref   : 'Carrier'
    type  : mongoose.Schema.Types.ObjectId

  user:
    ref   : 'User'
    type  : mongoose.Schema.Types.ObjectId


autoPopulateCarrier = ( next ) ->
  @populate 'carrier'
  next()


carrierAdminSchema.pre 'find', autoPopulateCarrier

carrierAdminSchema.pre 'findOne', autoPopulateCarrier


mongoose.model 'CarrierAdmin', carrierAdminSchema