async     = require('async')
https     = require('follow-redirects').https
mongoose  = require( 'mongoose' )
db        = require('../../config/db')
{CustomerAccount, User}  = db.models

getSpreadsheet = (spreadsheetKey, cb) ->
  googleScriptUrl = "https://script.google.com/macros/s/AKfycbwviz2BnJ-aZlTUFdc6p1VOmPJ_pBxOfY5GfUjiGtghQk4Po3NE/exec?spreadsheetKey=#{spreadsheetKey}"

  https.get googleScriptUrl, (response) ->
    body = ''
    response.on 'data', (data) -> body += data
    response.on 'end', ->
      accounts = JSON.parse body
      cb(accounts)


exports.preview = (req, res) ->
  spreadsheetKey = req.body.spreadsheetKey

  getSpreadsheet spreadsheetKey, (accounts) ->
    emails = accounts.map (account) ->
      account.email

    User.find
      email:
        $in: emails
    , 'email'
    , (err, duplicateUsers) ->
        if duplicateUsers.length
          duplicateEmails = duplicateUsers.map (user) -> user.email
          duplicateAccounts = accounts.filter (account) ->
            account.email in duplicateEmails
          res.json
            duplicateAccounts: duplicateAccounts
        else
          res.json
            accounts: accounts


exports.create = (req, res) ->

  acct.carrier = mongoose.Types.ObjectId( req.body.carrier )  for acct in req.body.accounts

  async.parallel
    users: (cb) ->
      User.create req.body.accounts, cb
    customerAccounts: (cb) ->
      CustomerAccount.create req.body.accounts, cb
  , (e, r) ->
    r.users.forEach (user, idx) ->
      user.link 'customerAccount', r.customerAccounts[idx]

    res.json 200