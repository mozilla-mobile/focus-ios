(function(){
  var messageHandler = window.webkit.messageHandlers.focusTrackingProtection

  var xhrProto = XMLHttpRequest.prototype,
  originalOpen = xhrProto.open,
  originalSend = xhrProto.send;

  xhrProto.open = function(method, url) {
      this._url = url;
      return originalOpen.apply(this, arguments);
  };

  xhrProto.send = function(body) {
      messageHandler.postMessage({ url: this._url })
      return originalSend.apply(this, arguments)
  };

  var originalImageSrc = Object.getOwnPropertyDescriptor(Image.prototype, 'src');
  delete Image.prototype.src;
  Object.defineProperty(Image.prototype, 'src', {
    get: function() {
      return originalImageSrc.get.call(this);
    },
    set: function(value) {
      messageHandler.postMessage({ url: value })
      originalImageSrc.set.call(this, value);
    }
  });

  var originalElementSrc = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
  delete HTMLScriptElement.prototype.src;
  Object.defineProperty(HTMLScriptElement.prototype, 'src', {
    get: function() {
      return originalElementSrc.get.call(this);
    },
    set: function(value) {
      messageHandler.postMessage({ url: value })
      originalElementSrc.set.call(this, value);
    }
  });



})();