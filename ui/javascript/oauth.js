Qt.include("sha1.js")

var normalizedUrl = "";
var normalizedRequestParameters = "";

var OAUTH_CONSUMER_TOKEN = "QfRIUDtJJROlZlhfXLCS2w";
var OAUTH_CONSUMER_SECRET = "U1nWwbXOh8vEbia3Vem5BxNfBsp8nR6cVBPFvKEEA";
var HMACSHA1SignatureType = "HMAC-SHA1";

var OAuthVersion = "1.0";

var OAuthConsumerKeyKey = "oauth_consumer_key";
var OAuthVersionKey = "oauth_version";
var OAuthSignatureMethodKey = "oauth_signature_method";
var OAuthSignatureKey = "oauth_signature";
var OAuthTimestampKey = "oauth_timestamp";
var OAuthNonceKey = "oauth_nonce";
var OAuthTokenKey = "oauth_token";

var token = "";
var tokenSecret = "";

function setTokenAndSecret(newToken, newTokenSecret) {
    console.log("oauth::setTokenAndSecret");
    token = newToken;
    tokenSecret = newTokenSecret;
}

function getQueryParameters(url) {
    var questionMarkIndex = url.indexOf("?");
    if(questionMarkIndex<0) {
        return new Array();
    }
    var parameters = url.substring(questionMarkIndex+1);
    var params = new Array();
    var para = parameters.split("&");
    for(var i=0; i<para.length; i++) {
        var nameValue = para[i].split("=");
        var q = [nameValue[0], nameValue[1]];
        params.push(q);
    }
    return params;
}

function generateSignatureBase(url,consumerKey,token,tokenSecret,httpMethod,timeStamp,nonce,signatureType) {
    if (typeof(token)=="undefined")
    {
        token = "";
    }
    if (typeof(tokenSecret)=="undefined")
    {
        tokenSecret = "";
    }

    var parameters = this.getQueryParameters(url);
    parameters.push( [OAuthVersionKey, OAuthVersion] );
    parameters.push( [OAuthNonceKey, nonce] );
    parameters.push( [OAuthTimestampKey, timeStamp] );
    parameters.push( [OAuthSignatureMethodKey, signatureType] );
    parameters.push( [OAuthConsumerKeyKey, consumerKey] );

    if (typeof(token)!="undefined" && token != "")
    {
        parameters.push( [OAuthTokenKey, token] );
    }

    this.sortParameters( parameters );

    normalizedUrl = this.getSchemeAndHost(url);
    normalizedUrl += this.getAbsolutePath(url);
    normalizedRequestParameters = this.normalizeRequestParameters(parameters);

    var signatureBase = "";
    signatureBase += httpMethod + "&";
    signatureBase += this.encode(normalizedUrl) + "&";
    signatureBase += this.encode(normalizedRequestParameters);

    return signatureBase;
}

function getSchemeAndHost(url) {
    var startIndex = url.indexOf("//")+2;
    var endIndex = url.indexOf("/", startIndex);
    return url.substring(0,endIndex);
}

function getAbsolutePath(url) {
    var startIndex = url.indexOf("//")+2;
    var endIndex = url.indexOf("/", startIndex);
    var questionMark = url.indexOf("?");
    if(questionMark>0) {
        return url.substring(endIndex, questionMark);
    } else {
        return url.substring(endIndex);
    }
}

function sortParameters(items) {
    items.sort();
}

function generateSignature(url, consumerKey, consumerSecret,token,tokenSecret,httpMethod,timeStamp,nonce) {
    var signatureBase = this.generateSignatureBase(
            url,
            consumerKey,
            token,
            tokenSecret,
            httpMethod,
            timeStamp,
            nonce,
            HMACSHA1SignatureType);
    var tokenSec = "";
    if(typeof(tokenSecret)!="undefined") {
        tokenSec = tokenSecret;
    }
    var key = this.encode(consumerSecret) + "&" + this.encode(tokenSec);
    var signature = this.getSignature(signatureBase, key);
    return signature;
}

function getSignature(message, key)  {
    var signature = b64_hmac_sha1(key, message);
    return signature;
}

function normalizeRequestParameters( parameters ) {
    var sb = "";
    for(var i in parameters) {
        var par = parameters[i];
        sb += par[0] + "=" + par[1] + "&";
    }
    return sb.substring(0, sb.length-1);
}

function generateTimeStamp() {
    var p = (new Date()).getTime() + 0;
    return Math.floor(p / 1000);
}

var nonceChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";

function generateNonce(length) {
    var chars = nonceChars;
    var result = "";
    for (var i = 0; i < length; ++i) {
        var rnum = Math.floor(Math.random() * chars.length);
        result += chars.substring(rnum, rnum+1);
    }
    return result;
}

function webRequest(request, isPost, url, parameters, callback, errorCallback) {
    request.disconnectAllConnections();
    request.loadingFinished.connect(callback);
    request.loadingError.connect(errorCallback);

    var method = "GET"
    //Setup postData for signing.
    //Add the postData to the querystring.
    var postData = "";
    if (isPost)
    {
        //$("#tweets").append("Handling POST params<br/>");
        method = "POST";
    }
    if (typeof(parameters) !== undefined && parameters !== null && parameters.length>0)
    {
        //Decode the parameters and re-encode using the oAuth UrlEncode method.
        for(var i in parameters) {
            var q = parameters[i];
            if(postData.length>0) {
                postData += "&";
            }
            postData += q[0] + "=" + this.encode(q[1]);
        }
        if (url.indexOf("?") > 0)
        {
            url += "&";
        }
        else
        {
            url += "?";
        }
        url += postData;
    }
    //$("#tweets").append("URL processed<br/>");
    //}
    var nonce = this.generateNonce(16);
    var timeStamp = this.generateTimeStamp();

    //Generate Signature
    //$("#tweets").append("Generating signature<br/>");
    var sig = this.generateSignature(
            url,
            OAUTH_CONSUMER_TOKEN,
            OAUTH_CONSUMER_SECRET,
            token,
            tokenSecret,
            method,
            timeStamp,
            nonce);
    //$("#tweets").append("Signature created<br/>");

    var outUrl = normalizedUrl;
    var querystring = normalizedRequestParameters;
    if(querystring.length>0) {
        querystring += "&";
    }
    //$("#tweets").append("Adding signature to query string<br/>");
    querystring += "oauth_signature=" + this.encode(sig);
    if (querystring.length > 0)
    {
        outUrl += "?";
    }

    if (isPost)
    {
        request.post(outUrl + querystring);
    }
    else
    {
        request.get(outUrl + querystring);
    }
}

function upload(request, url, parameters, content, filepath, callback, errorCallback) {
    request.disconnectAllConnections();
    request.loadingFinished.connect(callback);
    request.loadingError.connect(errorCallback);

    var method = "POST";
    var postData = "";
    if (typeof(parameters) !== undefined && parameters !== null && parameters.length>0)
    {
        //Decode the parameters and re-encode using the oAuth UrlEncode method.
        for(var i in parameters) {
            var q = parameters[i];
            if(postData.length>0) {
                postData += "&";
            }
            postData += q[0] + "=" + this.encode(q[1]);
        }
        if (url.indexOf("?") > 0)
        {
            url += "&";
        }
        else
        {
            url += "?";
        }
        url += postData;
    }
    //$("#tweets").append("URL processed<br/>");
    //}
    var nonce = this.generateNonce(16);
    var timeStamp = this.generateTimeStamp();

    //Generate Signature
    //$("#tweets").append("Generating signature<br/>");
    var sig = this.generateSignature(
            url,
            OAUTH_CONSUMER_TOKEN,
            OAUTH_CONSUMER_SECRET,
            token,
            tokenSecret,
            method,
            timeStamp,
            nonce);
    //$("#tweets").append("Signature created<br/>");

    var outUrl = normalizedUrl;
    var querystring = normalizedRequestParameters;
    if(querystring.length>0) {
        querystring += "&";
    }
    //$("#tweets").append("Adding signature to query string<br/>");
    querystring += "oauth_signature=" + this.encode(sig);
    if (querystring.length > 0)
    {
        outUrl += "?";
    }
    request.upload(outUrl + querystring, content, filepath);
}

function encode(s) {
    if (typeof(s)=="undefined" || s=== "") {
        return "";
    }

    s = encodeURIComponent(s);
    // Now replace the values which encodeURIComponent doesn't do
    // encodeURIComponent ignores: - _ . ! ~ * ' ( )
    // OAuth dictates the only ones you can ignore are: - _ . ~
    // Source: http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Global_Functions:encodeURIComponent
    s = s.replace(/\!/g, "%21");
    s = s.replace(/\*/g, "%2A");
    s = s.replace(/\(/g, "%28");
    s = s.replace(/\)/g, "%29");
    s = s.replace(/\'/g, "%27");

    return s;
}

