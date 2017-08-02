mongoose = require('mongoose')


homeClubAdminSchema = new mongoose.Schema
  name:
    first : String
    last  : String

  user:
    ref   : 'User'
    type  : mongoose.Schema.Types.ObjectId


mongoose.model 'HomeClubAdmin', homeClubAdminSchema