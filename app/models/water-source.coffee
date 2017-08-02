mongoose = require('mongoose')


waterSourceSchema = new mongoose.Schema
  name: String


mongoose.model 'WaterSource', waterSourceSchema