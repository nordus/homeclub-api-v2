request     = require( 'request' )
mongoose    = require( 'mongoose' )
SensorHub   = mongoose.model( 'SensorHub' )
_           = require( 'lodash' )


ensureArray = ( item ) ->
  if Array.isArray( item ) then item else [ item ]

getEventTypeIds = ( eventType ) ->
  return [1] if eventType is "water"
  return [2] if eventType is "motion"
  return [3,4] if eventType is "temperature"
  return [5,6] if eventType is "humidity"
  return [7,8] if eventType is "light"
  return [9] if eventType is "movement"

getGatewayEventTypeIds = ( eventType ) ->
  return [1, 2] if eventType is "power"


module.exports = (req, res) ->

  fields = switch req.query.msgType
    when '0' then ['timestamp', 'macAddress', 'gatewayBattery', 'rssi']
    when '2' then ['updateTime', 'timestamp', 'macAddress', 'gatewayBattery', 'gatewayEventCode', 'rssi']
    when '4' then ['updateTime', 'timestamp', 'macAddress', 'sensorEventStart', 'sensorEventEnd', 'rssi', 'sensorHubBattery', 'sensorHubMacAddress', 'sensorHubRssi']
    when '5' then ['timestamp', 'macAddress', 'rssi', 'numberOfSensors', 'sensorHubBattery', 'sensorHubData1', 'sensorHubData2', 'sensorHubData3', 'sensorHubMacAddress', 'sensorHubRssi', 'sensorHubType']

  queryParams =
    query   : "msgType:#{req.query.msgType}"
    keyword : "#{req.query.start} to #{req.query.end || 'midnight tomorrow'}"
    sort    : 'timestamp:asc'
    fields  : fields.join()

  if req.query.limit
    queryParams.limit = req.query.limit

  # HACK: move back up once req.user is in place
  if req.user.roles.customerAccount?.carrier.name
    queryParams.query += " AND carrier:#{req.user.roles.customerAccount.carrier.name.toLowerCase()}"

  if req.query.eventTypes && req.query.msgType != '2'
    eventTypes    = ensureArray( req.query.eventTypes )

    eventTypeIds  = _.flatten eventTypes.map ( eventType ) ->
      getEventTypeIds( eventType )
    .join ' '

    console.log eventTypeIds

    queryParams.query += " AND (sensorEventEnd:(#{eventTypeIds}) OR sensorEventStart:(#{eventTypeIds}))"

  if req.query.gatewayEventTypes
    eventTypes    = ensureArray( req.query.gatewayEventTypes )

    eventTypeIds  = _.flatten eventTypes.map ( eventType ) ->
      getGatewayEventTypeIds( eventType )
    .join ' '

    console.log eventTypeIds

    queryParams.query += " AND gatewayEventCode:(#{eventTypeIds})"

  if req.query.sensorHubMacAddress
    queryParams.query += " AND sensorHubMacAddress:#{req.query.sensorHubMacAddress}"

  if req.query.sensorHubMacAddresses && req.query.msgType != '2'
    queryParams.query += " AND sensorHubMacAddress:(#{ ensureArray( req.query.sensorHubMacAddresses ).join( ' ' ) })"

  if req.query.sensorHubType
    queryParams.query += " AND sensorHubType:#{req.query.sensorHubType}"

  if req.query.macAddress
    queryParams.query += " AND macAddress:#{req.query.macAddress}"

  if req.query.gatewayEventCode
    queryParams.query += " AND gatewayEventCode:#{req.query.gatewayEventCode.replace /\+/g, ' '}"

  if req.query.offset
    queryParams.offset = req.query.offset

  console.log queryParams.query

  requestOptions =
    url: "http://graylog-server.homeclub.us:9000/api/search/universal/keyword"
    qs: queryParams
    headers:
      Authorization: 'Basic YXBpdXNlcjphcGl1c2Vy'

    method: 'GET'


  if req.query.download
    requestOptions.headers.Accept = 'text/csv'
    res.attachment "raw_data_msg_type_#{req.query.msgType}.csv"
    request(requestOptions).pipe res
  else
    requestOptions.json = true
    request requestOptions, (err, incomingMessage, resp) ->
        res.json _.map(resp.messages, 'message')