mongoose = require('mongoose')

outboundCommandSchema = new mongoose.Schema

  gateway:
    ref   : 'Gateway'
    type  : String

  sensorHub:
    ref   : 'SensorHub'
    type  : String

  customerAccount:
    ref   : 'CustomerAccount'
    type  : mongoose.Schema.Types.ObjectId

  carrier:
    ref   : 'Carrier'
    type  : mongoose.Schema.Types.ObjectId

  phoneNumber           : String

  command               : String

  deliveredAt           : Date

  sentAt                : Date

  resolvedAt            : Date

  smsTransactionDetails : {}

  params                : {}

  msgType               : String

  deviceThresholds:
    ref   : 'DeviceThresholds'
    type  : mongoose.Schema.Types.ObjectId


#outboundCommandSchema.virtual('created').get ->
#  @created = @_id.getTimestamp()
#
#outboundCommandSchema.set 'toJSON', virtuals:true


mongoose.model 'OutboundCommand', outboundCommandSchema