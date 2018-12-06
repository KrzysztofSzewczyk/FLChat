
"use strict";

var net = require("net");

let policy = '<?xml version="1.0"?><!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd"><cross-domain-policy><allow-access-from domain="*" to-ports="*"/></cross-domain-policy>\0', usrs = [], lastid = 1;

class AbstractMethod {
	constructor() {
		this.response = new Response();
	}
	
	setRequest(request) {
		this.request = request;
		this.action = this.request.action;
		this.params = this.request.params;
	}
	
	setStream(data) {
		this.stream = data;
		this.response.setStream(this.stream);
	}
	
	error(msg, code, stream) {
		this.response = {
			action: error,
			params: { msg: msg, code: code }
		};
		this.reply(stream);
	}
}

class Auth extends AbstractMethod {
	exec() {
		this.response.action = this.action;
		this.response.params = {
			uid: lastid++,
			users: usrs.length
		};
		this.response.send(this.stream);
	}
}

class Send extends AbstractMethod {
	exec() {
		this.response.action = 'R';
		this.response.params = this.params;
		this.response.send(usrs);
	}
}

class Request {
	constructor(data) {
		this.data = new Object();
		this.params = new Object();
		this.action = '';
		this.setData(data);
	}
	
	setData(data) {
		this.data = JSON.parse(data.substring(0, data.lastIndexOf('\0')));
		this.action = this.data.action;
		this.params = this.data.params;
	}
	
	getMethod() {
		let method;
		
		if(this.action == "AbstractMethod")
			method = new AbstractMethod();
		else if(this.action == "A")
			method = new Auth();
		else if(this.action == "S")
			method = new Send();
		
		method.setRequest(this);
		return method;
	}
}

class Response {
	constructor(action, params) {
		this.action = action;
		this.params = params;
		this.usrs = new Array();
	}
	
	setStream(stream) {
		this.usrs = new Array(stream);
	}
	
	setStreams(usrs) {
		this.usrs = usrs;
	}
	
	send(usrs) {
		let s = 0;
		
		if (usrs != null) {
			if (usrs instanceof Array)
				this.setStreams(usrs);
			else
				this.setStream(usrs);
		}
		
		let data = JSON.stringify({
			action: this.action,
			params: this.params
		}) + "\0";
		
		for (; s < this.usrs.length; s++) {
			this.usrs[s].write(data);
		}
		
		return true;
	}
}

let server = net.createServer(function (stream) {
	stream.setEncoding("utf8");
    stream.write(policy);
	usrs.push(stream);
    
	stream.on('data', function(data) {	
		if (data === '<policy-file-request/>\0') {
			stream.write(policy);
			return;
		}
		
		let method = new Request(data).getMethod();
		method.setStream(stream);
		method.exec();
	});
	

	stream.on("end", function () {
		if (usrs.indexOf(stream) > -1) {
			usrs.splice(usrs.indexOf(stream), 1);
		}
	});
});

server.listen(40020, "0.0.0.0");