requireDir  = require 'require-directory'
c           = requireDir module, "#{__dirname}/../app/controllers"
auth        = require('./auth')


module.exports = ( router ) ->

  router.route( '/carriers-by-network-hub' )
    .get( c['carriers-by-network-hub'] )


  # WEB HOOKS
  router.route( '/webhooks/network-hub-event' )
    .post( c.webhooks.networkHubEvent )

  router.route( '/webhooks/sensor-hub-event' )
    .post( c.webhooks.sensorHubEvent )


  # SMS
  # router.route('/sms')
  #   .post(c.sms)


  # CONSUMER
  router.all '*', auth.setUserFromAuthToken

  router.route( '/chartdata' )
    .get( c.chartdata )

  router.route( '/me/customer-account' )
    .get( c['me'].customerAccount )

  router.route( '/me/network-hub' )
    .get( c['me'].networkHub )
    .post( c['me'].updateNetworkHubSubscriptions )

  router.route( '/customer-accounts/:id' )
    .put( c['customer-accounts'].update )

  router.route( '/search' )
    .get( c.search )

  router.route( '/sensor-hubs/:id' )
    .put( c['sensor-hubs'].update )

  router.route( '/sensor-hubs' )
    .get( c[ 'sensor-hubs' ].index )

  # is this needed for User?  should probably be homeclubAdmin only
  # as long as we / homeclubAdmin are only one creating addt'l roles
  router.route( '/users/:id' )
    .put( c.users.update )


  # BOTH (CARRIER ADMIN and HOMECLUB ADMIN)
  router.route( '/aggregates' )
    .get( c.aggregates )

  router.route( '/carrier-admins' )
    .get( c['carrier-admins'].index )
    .post( c['carrier-admins'].create )

  router.route( '/customer-accounts' )
    .get( c['customer-accounts'].index )

  router.route( '/histograms/:carrier?' )
    .get( c.histograms )

  router.route( '/network-hubs/:id' )
    .post( c[ 'network-hubs' ].create )
    .put( c[ 'network-hubs' ].update )
    .delete( c[ 'network-hubs' ].delete )

  router.route( '/users' )
    .get( c.users.index )


  # HOMECLUB ADMIN
  router.route( '/users/:id' )
    .delete( c.users.delete )

  router.route( '/carriers' )
    .get( c.carriers.index )
    .post( c.carriers.create )

  router.route( '/homeclub-admins/:id?' )
    .get( c['homeclub-admins'].show )
    .delete( c['homeclub-admins'].delete )
    .post( c['homeclub-admins'].create )

  router.route( '/network-hubs' )
    .get( c[ 'network-hubs' ].index )

  router.route( '/import-google-doc/preview' )
    .post( c['import-google-doc'].preview )

  router.route('/import-google-doc')
    .post( c['import-google-doc'].create )