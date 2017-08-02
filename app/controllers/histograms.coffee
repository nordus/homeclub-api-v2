async           = require( 'async' )
request         = require( 'request' )
mongoose        = require( 'mongoose' )
CustomerAccount = mongoose.model( 'CustomerAccount' )


buildRequestOptions = (macAddressObj, start, interval) ->
  query = switch macAddressObj.hubType
    when 'sensorHub' then "sensorHubMacAddress:#{macAddressObj.macAddress}"
    else "macAddress:#{macAddressObj.macAddress} AND msgType:0"

  {
    url: 'http://graylog-server.homeclub.us:9000/api/search/universal/keyword/histogram'
    json: true
    headers:
      Authorization: 'Basic YXBpdXNlcjphcGl1c2Vy'
    method: 'GET'
    qs:
      query: query
      interval: interval
      keyword: "#{start} +0000 to midnight tomorrow +0000"
  }

formatResponse = (resp, sensorHubMacAddress) ->
  formattedChartData = []
  if resp.results
    formattedChartData = for k,v of resp.results
      x:parseInt(k), y:v
  hasAllDataPoints = formattedChartData.length >= 12
  color = if hasAllDataPoints then '#53b2da' else '#f2dede'
  [
    data: formattedChartData
    name: sensorHubMacAddress
    color: color
  ]


module.exports = (req, res) ->
  start                 = req.query.start or '12 hours ago'
  interval              = req.query.interval or 'hour'

  carrierId             = req.user.roles.carrierAdmin?.carrier._id

  params = switch carrierId
    when undefined then {}
    else carrier: mongoose.Types.ObjectId( carrierId )

  CustomerAccount.find( params ).populate('gateways').exec (err, accounts) ->

    allMacAddresses  = []
    nameBySensorHubMacAddress = {}

    accounts.forEach (account) ->
      g = account.gateways[0]
      # return if account has no gateways assigned
      return unless g
      customerName = "#{account.name.first} #{account.name.last}"
      # name contains network hub ID, firstName lastName, customer ID as a
      # pipe ('|') delimited string
      # i.e. '000780677246|John Doe|53a8ad2ed7babc9210c6c7ce'
      networkHubMacAddress = g._id
      name = [
        networkHubMacAddress
        customerName
        account._id
      ].join '|'
      nameBySensorHubMacAddress[networkHubMacAddress] = name
      allMacAddresses.push { hubType:'networkHub', macAddress:g._id }
      # g.sensorHubs.forEach (sensorHubMacAddress) ->
      g.sensorHubs.forEach (sensorHub) ->
        # sensorHubs on the same gateway have the same name
        nameBySensorHubMacAddress[sensorHub._id] = name
        allMacAddresses.push { hubType:'sensorHub', macAddress:sensorHub._id }


    out = {}

    async.each allMacAddresses, (macAddressObj, done) ->
      sensorHubMacAddress = macAddressObj.macAddress
      name                = nameBySensorHubMacAddress[sensorHubMacAddress]

      unless out[name]
        out[name] = { networkHubs:{}, sensorHubs:{} }

      requestOptions = buildRequestOptions(macAddressObj, start, interval)

      request requestOptions, (err, incomingMessage, resp) ->
        formattedResponse = formatResponse(resp, sensorHubMacAddress)
        out[name]["#{macAddressObj.hubType}s"][sensorHubMacAddress] = formattedResponse
        done()
    , (err) ->
      res.json out