exports.sensorHubEvent = (sensorHubEvent, eventResolved) ->
  alertText = switch sensorHubEvent
    when 1 then 'Water detect'
    when 2 then 'Motion detect'
    when 3 then 'Low temperature'
    when 4 then 'High temperature'
    when 5 then 'Low humidity'
    when 6 then 'High humidity'
    when 7 then 'Low light'
    when 8 then 'High light'
    when 9 then 'Movement'
  if eventResolved
    alertText += ' resolved'
  alertText


exports.gatewayEvent = (gatewayEventCode) ->
  switch gatewayEventCode
    when 1 then 'Going from line power to backup battery'
    when 2 then 'Going from backup battery to line power'
    when 3 then 'Transition from high to low battery voltage'
    when 4 then 'Transition from low to critical low battery voltage'
    when 5 then 'Welcome to HomeClub.  Your system is now operational.'
    when 6 then 'Restart'