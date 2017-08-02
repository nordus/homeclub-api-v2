mongoose = require('mongoose')


sensorHubSchema = new mongoose.Schema

  _id         : String  # bluetooth MAC address
  batteryPct  : Number
  name        : String
  rssi        : Number

  waterSource:
    ref   : 'WaterSource'
    type  : mongoose.Schema.Types.ObjectId
  
  roomType:
    ref   : 'RoomType'
    type  : mongoose.Schema.Types.ObjectId
    
  sensorHubType:
    ref   : 'SensorHubType'
    type  : Number

  emailSubscriptions:
    default : ['water']
    type    : [String]

  smsSubscriptions:
    default : ['water', 'motion']
    type    : [String]

#  customThresholds  : {}

#  latestOutboundCommand:
#    ref: 'OutboundCommand'
#    type: mongoose.Schema.Types.ObjectId

  deviceThresholds:
    ref     : 'DeviceThresholds'
    type    : mongoose.Schema.Types.ObjectId

  pendingDeviceThresholds:
    ref     : 'DeviceThresholds'
    type    : mongoose.Schema.Types.ObjectId

mongoose.model 'SensorHub', sensorHubSchema