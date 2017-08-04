
require('es6-shim');

var ngrok           = require( 'ngrok' );

var HTTPS_PORT      = 3030;

var HC_WEB_PORT     = 3031;

var trans = require( 'coffee-script' );
if ( trans.register )  trans.register();

// start Firebase queue
require( './app/lib/firebase-queue-workers' );

var express         = require( 'express' ),
    cors            = require( 'cors' ),
    bodyParser      = require( 'body-parser' ),
    // connect to our database
    db              = require( './config/db' ),
    fs              = require( 'fs' ),
    firebaseConfig  = require( './app/lib/firebase-service-account-key.json' ),
    meta            = require( './app/lib/meta.json' ),
    User            = db.models.User,
    adminApp        = require( './app/lib/firebase-admin-app' ),
    app             = express(),

    // demo.homeclub.us - HOMECLUB STATIC WEB (HTTPS)
    hcWebApp        = express(),
    https           = require( 'https' );

sslOptions = {
  key   : fs.readFileSync(__dirname + '/api_homeclub_us.key'),
  cert  : fs.readFileSync(__dirname + '/api_homeclub_us.crt')
};

function createAdditionalClaims( user ) {
  
  var sensorHubNames  = {};
  
  if ( user.roles.customerAccount ) {
    user.roles.customerAccount.gateways[0].sensorHubs.forEach(function( sh ) {
      this[ sh._id ]  = sh.roomType && meta.roomTypes[ sh.roomType ] || sh.sensorHubType && meta.sensorHubTypes[ String( sh.sensorHubType ) ];
    }, sensorHubNames);
  }
  
  return {
    createdAt       : user.createdAt,
    email           : user.email,
    isDebugTester   : user.isDebugTester,
    roles           : user.roles,
    sensorHubNames  : sensorHubNames
  };
}


app.use( cors() );
app.use( express.static(__dirname + '/public') );
app.use( bodyParser.json() );

app.post('/login', authenticate, function ( req, res ) {
  var additionalClaims  = createAdditionalClaims( req.user ),
      uid               = req.user._id.toString();

  adminApp.auth().createCustomToken( uid, additionalClaims )
    .then(function( customToken ) {
      // send token to client
      res.send({ token: customToken });
    })
    .catch(function( error ) {
      console.log( 'Error creating custom token:', error );
    });
});


// load our routes
var router  = express.Router();
require( './config/routes' )( router );
app.use( router );

// once database is connected start the app
db.once('open', function() {
  
  // ngrok
  ngrok.connect({
      proto: 'tls', // http|tcp|tls 
      addr: 3030, // port or network address 
      // auth: 'user:pwd', // http basic authentication for tunnel 
      // subdomain: 'alex', // reserved tunnel name https://alex.ngrok.io 
      authtoken: '3TkVnXuTWQ9HBxhjRs3KB_3cmajzCT2KsNEnbF2eEea', // your authtoken from ngrok.com 
      // region: 'us', // one of ngrok regions (us, eu, au, ap), defaults to us, 
      // configPath: '~/git/project/ngrok.yml' // custom path for ngrok config file 
      hostname: 'api.homeclub.us',
      key: __dirname + '/api_homeclub_us.key',
      crt: __dirname + '/api_homeclub_us.crt'
      // key: sslOptions.key,
      // crt: sslOptions.cert
  }, function (err, url) {
    console.log( err || url );
  });
  
  // HTTP
  app.listen(3030, function () {
    console.log( 'HomeClub API listening on localhost:3030' );
  });

  // demo.homeclub.us - HOMECLUB STATIC WEB (HTTPS)
  hcWebApp.use( express.static( './homeclub-web-gh-pages' ) );

  https.createServer( sslOptions, hcWebApp ).listen( HC_WEB_PORT, function() {
    console.log( 'HomeClub STATIC WEB (HTTPS) listening on port ' + HC_WEB_PORT );

    hcWebApp.get('*', function(req, res) {
        res.sendFile(__dirname + '/homeclub-web-gh-pages/index.html'); // load the single view file (angular will handle the page changes on the front-end)
    });
  });
});


// UTIL FUNCTIONS

function authenticate( req, res, next ) {
  var body = req.body;

  if ( !body.username || !body.password ) {
    res.status( 400 ).end( 'Must provide username or password' );
  }
  
  User.findOne(
    { email: body.username.toLowerCase() },
    function( err, user ) {
      if ( user === null || err ) {
        res.status( 401 ).end( 'Username or password incorrect' );

      } else {
        if ( user.authenticate( body.password ) ) {        
          
          // keysToPopulate => [ 'roles.customerAccount', 'roles.carrierAdmin', 'roles.homeClubAdmin' ]
          var keysToPopulate = Object.keys( user.roles.toObject() ).map(function( role ) { return 'roles.' + role } );
          
          User.findOne( user ).populate( keysToPopulate ).exec(function( err, user ) {
            req.user  = user;
            next();
          })

        } else {
          res.status( 401 ).end( 'Username or password incorrect' );
        }
      }
    }
  )
}