var verifyCode = "";
var authorizeCallback = null;

function errorCallback(data)
{
    console.log(data);
}

function requestToken(errorHandler)
{
    console.log("requestToken");
    var params = new Array();
    params.push(["oauth_callback", "http://dragonsightforce.com"]);
    application.getOAuth().webRequest(authorizeRequest, true,
                                      "https://api.twitter.com/oauth/request_token",
                                      params, requestTokenCallback, errorHandler);
}

function requestTokenCallback(data)
{
    //example data is: oauth_token=AKrHrorx6j0y0LWZzEJIVTvUwQk9wXt9g4wOoOjg4pE&oauth_token_secret=tFAXm3nklpjeQzlC6kpttRA8K8EKzrmtr6flIEhSWOU&oauth_callback_confirmed=true
    console.log(data);
    var stringList = data.split("&");

    var oauth_token = stringList[0].split("=")[1];
    var oauth_token_secret = stringList[1].split("=")[1];
    console.log("oauth_token is " + oauth_token);
    console.log("oauth_token_secret is " + oauth_token_secret);

    application.getOAuth().setTokenAndSecret(oauth_token, oauth_token_secret);

    //next step: send the user to authorization
    var url = "https://api.twitter.com/oauth/authorize" + "?oauth_token=" + oauth_token;
    application.sendUserToAuthorization(url);
}

function requestAccessToken(callback)
{
    console.log("request access token");
    var params = new Array();
    params.push(["oauth_verifier", verifyCode]);
    application.getOAuth().webRequest(authorizeRequest, true,
                                      "https://api.twitter.com/oauth/access_token",
                                      params, requestAccessTokenCallback,
                                      errorCallback);
    authorizeCallback = callback;
}

function requestAccessTokenCallback(data)
{
    //example data is :
    //oauth_token=376058754-actJzpCGbiXQu8ZJS8cJErQiTvfk6FZBew5qTkeE&
    //oauth_token_secret=2WrzhA0UcoFoInqWGlQxXx7rr92u8ZT2BaJxPVBic&
    //user_id=376058754&screen_name=wsgxw
    console.log(data);
    var stringList = data.split("&");
    var oauth_token = stringList[0].split("=")[1];
    var oauth_token_secret = stringList[1].split("=")[1];
    var user_id = stringList[2].split("=")[1];
    var screen_name = stringList[3].split("=")[1];

    console.log("oauth_token is " + oauth_token);
    console.log("oauth_token_secret is " + oauth_token_secret);
    application.getOAuth().setTokenAndSecret(oauth_token, oauth_token_secret);

    application.getStorage().setKeyValue("oauth_token", oauth_token);
    application.getStorage().setKeyValue("oauth_token_secret", oauth_token_secret);
    application.getStorage().setKeyValue("user_id", user_id);
    application.getStorage().setKeyValue("screen_name", screen_name);

    application.user_id = user_id;
    application.screen_name = screen_name;

    authorizeCallback();
}
