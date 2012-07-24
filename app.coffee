express = require 'express'
fs = require 'fs'
forever = require 'forever'

log_path = "/tmp/forever_webui.log"
time = new Date()

process.on "uncaughtException", (err) ->
  console.log "Caught exception: " + err

app = express.createServer()

app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.set('views', __dirname + '/views')
  app.use express.methodOverride()
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler({ dump: true, stack: true })
  app.use express.static(__dirname + "/public")

app.configure "production", ->
  app.use express.errorHandler()
  app.use(express.static(__dirname + '/public'))

  
app.get('/', (req, res) ->
  forever.list("", (err, results) ->
    res.send('/list/ , /stop/:id , /restart/:id , /info/:id', {process: results})
  )
)

app.get('/list/', (req, res) ->
  forever.list("", (err, results) ->
    if err
      res.send JSON.stringify(err)
      message = "***ERR*** #{err} - on #{time}.\n"
      log = fs.createWriteStream(log_path, {'flags': 'a'})
      log.write(message)    
    else
      res.send JSON.stringify(results)
  )
)

app.get('/stop/:id', (req, res) ->
  forever.stop req.params.id, (err, results) ->
    if err
      res.send JSON.stringify(err)
      message = "***ERR*** #{err} - on #{time}.\n"
      log = fs.createWriteStream(log_path, {'flags': 'a'})
      log.write(message)    
    else
      res.send JSON.stringify(results)
)

app.get('/restart/:id', (req, res) ->
  forever.restart req.params.id, (err, result) ->
    if err
      res.send JSON.stringify(err)
      message = "***ERR*** #{err} - on #{time}.\n"
      log = fs.createWriteStream(log_path, {'flags': 'a'})
      log.write(message)
    else
      res.send JSON.stringify(results)
)

app.get('/info/:id', (req, res) ->
  forever.info req.params.uid, (err, result) ->
    if err
      res.send JSON.stringify(err)
      message = "***ERR*** #{err} - on #{time}.\n"
      log = fs.createWriteStream(log_path, {'flags': 'a'})
      log.write(message)
    else
      res.send JSON.stringify(results)
)

app.listen 1999
console.log "Listening on localhost:1999"
