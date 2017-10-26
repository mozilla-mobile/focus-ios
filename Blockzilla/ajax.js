console.log("testing");
var xhrProto = XMLHttpRequest.prototype,
origOpen = xhrProto.open,
origSend = xhrProto.send;

xhrProto.open = function(method, url) {
    this._url = url;
    return origOpen.apply(this, arguments);
};

xhrProto.send = function(body) {
    console.log(this._url);
    return origSend.apply(this, arguments)
};

debugger;