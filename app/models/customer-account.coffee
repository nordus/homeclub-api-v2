mongoose = require('mongoose')


customerAccountSchema = new mongoose.Schema
  phone: String
  houseName:
    type    : String
    default : 'House 1'
  country:
    type    : String
    default : 'US'
  houseNumber: String
  streetName: String
  city: String
  state: String
  zip: String
  
  name:
    first: String
    last: String
  
  carrier:
    ref: 'Carrier'
    type: mongoose.Schema.Types.ObjectId

  gateways: [
    ref: 'Gateway', type: String
  ]

  user:
    ref: 'User'
    type: mongoose.Schema.Types.ObjectId

  status:
    default : 'New'
    type    : String

  shipDate  : Date


autoPopulateCarrier = ( next ) ->
  @populate 'carrier'
  next()

autoPopulateGateways = ( next ) ->
  @populate 'gateways'
  next()


# TODO: does this need to be on both find and findOne ?
customerAccountSchema.pre 'find', autoPopulateCarrier
customerAccountSchema.pre 'find', autoPopulateGateways

customerAccountSchema.pre 'findOne', autoPopulateCarrier
customerAccountSchema.pre 'findOne', autoPopulateGateways


mongoose.model 'CustomerAccount', customerAccountSchema