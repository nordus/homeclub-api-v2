async           = require( 'async' )
mongoose        = require( 'mongoose' )
request         = require( 'request' )
CustomerAccount = mongoose.model( 'CustomerAccount' )
SensorHub       = mongoose.model( 'SensorHub' )


buildRequestOptions = (sensorHubMacAddress, field, start, msgType, interval) -> {
url: 'http://graylog-server.homeclub.us:9000/api/search/universal/keyword/fieldhistogram'
json: true
headers:
  Authorization: 'Basic YXBpdXNlcjphcGl1c2Vy'
method: 'GET'
qs:
  field: field
  interval: interval
  query: "msgType:#{msgType} AND sensorHubMacAddress:#{sensorHubMacAddress}"
  keyword: "#{start} to midnight tomorrow"
}

makeSingleRequest = (requestOptions, cb) ->
  request requestOptions, (err, incomingMessage, resp) ->
    cb(null, resp.results)

formatAveragesAndRanges = (resp, formatAsFahrenheit) ->
  out = averages:[], ranges:[]

  toFahrenheit = (n) -> ((n * 9) / 5) + 32

  for epoch,hourlyStats of resp
    ms = epoch * 1000
    if hourlyStats.min is "Infinity"
      hourlyStats.min = 0
    if hourlyStats.max is "-Infinity"
      hourlyStats.max = 0
    if formatAsFahrenheit
      out.averages.push [ms, toFahrenheit(hourlyStats.mean)]
      out.ranges.push [ms, toFahrenheit(hourlyStats.min), toFahrenheit(hourlyStats.max)]
    else
      out.averages.push [ms, hourlyStats.mean]
      out.ranges.push [ms, hourlyStats.min, hourlyStats.max]
  out

ensureArray = (item) ->
  if Array.isArray(item) then item else [item]

getSensorHubs = (sensorHubIds) ->
  SensorHub.where('_id').in(sensorHubIds).populate('roomType sensorHubType').exec()

getFieldsBySensorHubType = (sensorHub) ->
  fields = ['sensorHubData1']
  if sensorHub.sensorHubType?._id is 2
    fields = fields.concat ['sensorHubData2', 'sensorHubData3']
  fields


module.exports = (req, res) ->
  sensorHubMacAddresses = ensureArray(req.query.sensorHubMacAddresses)
  start                 = req.query.start
  interval              = req.query.interval
  msgType               = req.query.msgType or 5

  sensorHubs            = []

  requestOptionsArr = []

  getSensorHubs(sensorHubMacAddresses).then (resp) ->

    sensorHubs = resp

    sensorHubs.forEach (sensorHub) ->
      fields = getFieldsBySensorHubType(sensorHub)

      fields.forEach (field) ->
        requestOptionsArr.push buildRequestOptions(sensorHub._id, field, start, msgType, interval)

    async.map requestOptionsArr, makeSingleRequest, groupResponsesByFieldAndMacAddress

  groupResponsesByFieldAndMacAddress = (err, responses) ->
    out = {}

    sensorHubs.forEach (sensorHub) ->
      sensorHubNameOrMac = sensorHub.roomType?.name or sensorHub.sensorHubType?.friendlyName
      if sensorHubNameOrMac
        sensorHubNameOrMac += " (#{sensorHub._id})"
      else
        sensorHubNameOrMac = sensorHub._id
      @[sensorHubNameOrMac] = []
      fields = getFieldsBySensorHubType(sensorHub)
      fields.forEach (field) ->
        formatAsFahrenheit = field is 'sensorHubData1'
        formatted = formatAveragesAndRanges(responses.splice(0,1)[0], formatAsFahrenheit)
        color = '#7cb5ec'
        [suffix, unit] = switch field
          when 'sensorHubData1' then ['°F', 'Average Temp']
          when 'sensorHubData2' then [' lux', 'Light']
          when 'sensorHubData3' then ['%', 'Humidity']
        out[sensorHubNameOrMac].push {
          title:
            text: null
          xAxis:
            type: 'datetime'
          yAxis:
            title:
              text: null
          tooltip:
            crosshairs: true
            shared: true
            valueSuffix: suffix
          credits:
            enabled: false
          series: [
            name: unit
            data: formatted.averages
            zIndex: 1
            marker:
              fillColor: 'white'
              lineWidth: 2
              lineColor: color
          ,
            name: 'Range'
            data: formatted.ranges
            type: 'arearange'
            lineWidth: 0
            linkedTo: ':previous'
            color: color
            fillOpacity: 0.3
            zIndex: 0
          ]
        }
    , out

    res.json out