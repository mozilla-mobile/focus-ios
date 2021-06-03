var isFullScreenEnabled = document.fullscreenEnabled ||
                                    document.webkitFullscreenEnabled ||
                                    document.mozFullScreenEnabled ||
                                    document.msFullscreenEnabled ? true : false;

var isFullscreenVideosSupported = HTMLVideoElement.prototype.webkitEnterFullscreen !== undefined;

if (!isFullScreenEnabled && isFullscreenVideosSupported && !/mobile/i.test(navigator.userAgent)) {
    
    HTMLElement.prototype.requestFullscreen = function() {
        if (this.webkitRequestFullscreen !== undefined) {
            this.webkitRequestFullscreen();
            return true;
        }
        
        if (this.webkitEnterFullscreen !== undefined) {
            this.webkitEnterFullscreen();
            return true;
        }
        
        var video = this.querySelector("video")
        if (video !== undefined) {
            video.webkitEnterFullscreen();
            return true;
        }
        return false;
    };
    
    Object.defineProperty(document, 'fullscreenEnabled', {
        get: function() {
            return true;
        }
    });
    
    Object.defineProperty(document.documentElement, 'fullscreenEnabled', {
        get: function() {
            return true;
        }
    });
}
