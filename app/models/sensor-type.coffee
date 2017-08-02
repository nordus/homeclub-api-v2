mongoose = require('mongoose')


sensorTypeSchema = new mongoose.Schema

  name: String
  unit: String
  icon: String

mongoose.model 'SensorType', sensorTypeSchema