mongoose = require('mongoose')


carrierSchema = new mongoose.Schema

  phone       : String
  houseNumber : String
  streetName  : String
  city        : String
  state       : String
  zip         : String
  name        : String
  country:
    type    : String
    default : 'US'


mongoose.model 'Carrier', carrierSchema