
adminApp  = require './firebase-admin-app'
Queue     = require 'firebase-queue'
queueRef  = adminApp.database().ref 'queue'


new Queue queueRef, ( data, progress, resolve, reject ) ->

  {macAddress, msgType, rssi, updateTime}                 = data
  heartbeat         = msgType is 0
  networkHubAlert   = msgType is 2
  sensorHubAlert    = msgType is 4
  sensorHubReading  = msgType is 5
  {gatewayBattery:battery}                                = data  if heartbeat or networkHubAlert
  {gatewayEventCode:powerSource}                          = data  if networkHubAlert
  {sensorEventEnd, sensorEventStart}                      = data  if sensorHubAlert
  {sensorHubType}                                         = data  if sensorHubReading
  {sensorHubBattery, sensorHubMacAddress, sensorHubRssi}  = data  if sensorHubAlert or sensorHubReading

  latestRef         = adminApp.database().ref macAddress


  if heartbeat
    latestRef.child( 'latestPowerStatus' ).update {battery, updateTime}
    latestRef.child( 'latestRssi' ).set {rssi, updateTime}


  if networkHubAlert and powerSource in [1,2]
    latestRef.child( 'latestPowerStatus' ).update {battery, powerSource, powerSourceUpdateTime:updateTime, updateTime}
    latestRef.child( 'latestRssi' ).set {rssi, updateTime}


  if sensorHubAlert
    sensorHubAlertRef = latestRef.child "sensorHubs/#{sensorHubMacAddress}/latestAlert"
    sensorHubAlertRef.update {sensorEventEnd, sensorEventStart, sensorHubBattery, sensorHubRssi, updateTime}
    latestRef.child( 'latestRssi' ).set {rssi, updateTime}


  if sensorHubReading
    sensorHubRef =  latestRef.child "sensorHubs/#{sensorHubMacAddress}/"
    reading  = {sensorHubBattery, sensorHubRssi, sensorHubType, updateTime}
    # convert to Fahrenheit
    reading.sensorHubData1 = ((data.sensorHubData1 * 9) / 5) + 32
    ['sensorHubData2', 'sensorHubData3'].forEach ( k ) ->
      unless data[k] is undefined
        reading[ k ] = data[k]

    sensorHubRef.update reading
    latestRef.child( 'latestRssi' ).set {rssi, updateTime}


  resolve data