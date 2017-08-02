mongoose = require('mongoose')


sensorHubTypeSchema = new mongoose.Schema

  _id: type:Number, unique:true
  friendlyName: String
  description: String
  sensorTypes: [
    ref: 'SensorType'
    type: mongoose.Schema.Types.ObjectId
  ]

mongoose.model 'SensorHubType', sensorHubTypeSchema