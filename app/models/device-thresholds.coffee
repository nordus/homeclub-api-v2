mongoose = require('mongoose')

deviceThresholdsSchema = new mongoose.Schema

  temperatureMin:
    type    : Number
    min     : 32
    max     : 999
    default : 32

  temperatureMax:
    type    : Number
    min     : 32
    max     : 999
    default : 90

  humidityMin:
    type    : Number
    min     : 0
    max     : 100
    default : 11

  humidityMax:
    type    : Number
    min     : 0
    max     : 100
    default : 90

  lightMin:
    type    : Number
    min     : 0
    max     : 999
    default : 1

  lightMax:
    type    : Number
    min     : 0
    max     : 999
    default : 900

  movementSensitivity:
    type    : String
    default : '2'


mongoose.model 'DeviceThresholds', deviceThresholdsSchema