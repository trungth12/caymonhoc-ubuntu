var express = require("express"),
    app     = express(),
    redis   = require('redis'),
    client  = redis.createClient(6382),
    rest    = require('restler'),
    port    = parseInt(process.env.PORT, 10) || 8282,
	  day 	= 24 * 3600;
    bodyParser = require('body-parser'),
    serveStatic = require('serve-static'),
    errorHandler = require('errorhandler');

//app.configure(function(){
  //app.use(express.methodOverride());
  app.use(bodyParser.json());
  app.use(serveStatic(__dirname + '/public'));
  app.engine('html', require('ejs').renderFile);
  app.use(errorHandler({
    dumpExceptions: true,
    showStack: true
  }));

//});

app.get("/get/:id", function(req, res){
  var id = req.params.id;
  var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.headers.host;
console.log('request: ' + id);
client.get(id, function(err, rid){
	if (!rid) {
     rest.get('http://localhost:3001/' + ip + '/'+ id).on('complete', function(data) {
        if (data.error) {
		      client.set(id, JSON.stringify(data));
				client.expire(id, day);
        	  res.end(JSON.stringify(data));

        } else {

      		client.set(id, JSON.stringify(data));
      		client.expire(id, day);
      		res.end(JSON.stringify(data));
		}
    });
   }
   else {
		client.expire(id, day);
		res.end(JSON.stringify(JSON.parse(rid)));
   }
});
});
app.get("/checkltn/:id", function(req, res){
  var id = req.params.id;
  var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.headers.host;
  var ckey = 'checkltn:' + id;
  console.log('checkltn: ' + id);
  client.get(ckey, function(err, cid){
    if (!cid) {
    rest.get('http://localhost:3001/checkltn/' + ip + '/'+ id).on('complete', function(data) {
        if (data.error) {
      client.set(ckey, JSON.stringify(data));
      client.expire(ckey, day);
          res.end(JSON.stringify(data));
        } else {
          client.set(ckey, JSON.stringify(data));
      client.expire(ckey, day);
          res.end(JSON.stringify(data));
        }

    });
  } else {
    client.expire(ckey, day);
    res.end(JSON.stringify(JSON.parse(cid)));
  }
  });

});
app.get("/checktn/:id", function(req, res){
  var id = req.params.id;
  var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.headers.host;
  var ckey = 'checktn:' + id;
  console.log('checktn: ' + id);
  client.get(ckey, function(err, cid){
    if (!cid) {
    rest.get('http://localhost:3001/checktn/' + ip + '/'+ id).on('complete', function(data) {
        if (data.error) {
      client.set(ckey, JSON.stringify(data));
      client.expire(ckey, day);
          res.end(JSON.stringify(data));
        } else {
          client.set(ckey, JSON.stringify(data));
      client.expire(ckey, day);
          res.end(JSON.stringify(data));
        }

    });
  } else {
    client.expire(ckey, day);
    res.end(JSON.stringify(JSON.parse(cid)));
  }
  });

});

app.get("/check/:id", function(req, res){
	var id = req.params.id;
	var ckey = 'check:' + id;
	client.get(ckey, function(err, cid){
		if (!cid) {
		rest.get('http://localhost:3001/check/' + id).on('complete', function(data) {
	      if (data.error) {
			client.set(ckey, JSON.stringify(data));
			client.expire(ckey, day);
        	res.end(JSON.stringify(data));
	      } else {
        	client.set(ckey, JSON.stringify(data));
			client.expire(ckey, day);
	      	res.end(JSON.stringify(data));
	      }

		});
	} else {
		client.expire(ckey, day);
		res.end(JSON.stringify(JSON.parse(cid)));
	}
	});

});
app.get("/", function(req, res) {
	process.send({ cmd: 'notify', src: process.pid });
  res.redirect("/index.html");
});

console.log("running");
app.listen(port);
