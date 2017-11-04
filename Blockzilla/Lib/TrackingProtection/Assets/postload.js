var messageHandler = window.webkit.messageHandlers.focusTrackingProtectionPostLoad

var sendMessage = function(url) { messageHandler.postMessage({ url: url }) }

Array.prototype.map.call(document.scripts, function(t) { return t.src }).forEach(sendMessage)
Array.prototype.map.call(document.images, function(t) { return t.src }).forEach(sendMessage)
