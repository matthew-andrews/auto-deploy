var express = require('express');
var app = express();

app.get('/', function(req, res) {
	res.send('OK');
});

app.use('/', express.static(__dirname + '/public'));

var port = Number(process.env.PORT || 5000);
app.listen(port, function() {
	console.log("Listening on " + port);
});
