mongoose = require('mongoose')

outboundSmsSchema = new mongoose.Schema

  gateway:
    ref   : 'Gateway'
    type  : String
    
  customerAccount:
    ref   : 'CustomerAccount'
    type  : mongoose.Schema.Types.ObjectId
    
  phoneNumber: String

  reading: {}


outboundSmsSchema.virtual('created').get ->
  @created = @_id.getTimestamp()

outboundSmsSchema.set 'toJSON', virtuals:true


mongoose.model 'OutboundSms', outboundSmsSchema