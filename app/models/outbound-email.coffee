mongoose = require('mongoose')

outboundEmailSchema = new mongoose.Schema

  gateway:
    ref   : 'Gateway'
    type  : String
    
  customerAccount:
    ref   : 'CustomerAccount'
    type  : mongoose.Schema.Types.ObjectId
    
  email: String

  reading: {}


mongoose.model 'OutboundEmail', outboundEmailSchema