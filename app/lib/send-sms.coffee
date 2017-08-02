
module.exports = ( phoneNumber, body, cb ) ->

  #require the Twilio module and create a REST client
  client = require( 'twilio' )( 'ACcba29af48a22aa11fcc4890f9ca046ac', '7a4b1fbcbf536501d5429d01963f7ec3' )
  
  #Send an SMS text message
  client.sendMessage
    to    : phoneNumber
    from  : '+14803512304'
    body  : body
  , cb