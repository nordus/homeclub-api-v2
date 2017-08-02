mongoose = require('mongoose')


gatewayProfileSchema = new mongoose.Schema

  wiFi          : Boolean
  cdma          : Boolean
  ble           : Boolean
  gsm           : Boolean
  daughterCard  : Boolean


mongoose.model 'GatewayProfile', gatewayProfileSchema