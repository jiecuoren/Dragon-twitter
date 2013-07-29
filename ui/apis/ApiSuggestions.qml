import QtQuick 1.0
import TwitterEngine 1.0
import "../models"

Item {
    id : container

    property string _suggestions: "https://api.twitter.com/1/users/suggestions.json"
    property string _suggestionsBySlug: "https://api.twitter.com/1/users/suggestions/"

    property string _slug: ''

    signal dataReceived()
    signal errorOccured()
    signal lastPageReached()

    function setSlug( slug )
    {
        _slug = slug;
        console.log("slug="+slug);
    }

    function getSuggestions()
    {
        console.log("api getSuggestions");
        var params = new Array();
        params.push(["lang", "en"]);
        application.getOAuth().webRequest(suggestionsRequest, false, _suggestions, params,
                                                      suggestionsReceived, errorCallback);

    }

    function getSuggestionsBySlug(  )
    {
        console.log("api getSuggestionsBySlug");
        var suggestionsBySlug = _suggestionsBySlug + _slug + ".json";
        var params = new Array();
        params.push(["lang", "en"]);
        application.getOAuth().webRequest(suggestionsBySlugRequest, false, suggestionsBySlug,params,
                                                      suggestionsBySlugReceived, errorCallback);

    }

    function errorCallback(data)
    {
        console.log("error in getSuggestions" + data);
        errorOccured();
    }

    function suggestionsReceived( aReturnStr )
    {
        console.log("data is received in suggestionsReceived" );
        suggestionsModel.clear();
        suggestionsModel.parseReturnData(aReturnStr);
        container.dataReceived();
    }

    function suggestionsBySlugReceived( aReturnStr )
    {
        console.log("data is received in suggestionsBySlugReceived");
        userListModel.clear();
        var canGetMoreData = userListModel.parseReturnData( aReturnStr );
        container.dataReceived();
        if ( !canGetMoreData )
        {
            container.lastPageReached();
        }
    }

    HttpRequest {
        id: suggestionsRequest
    }

    HttpRequest {
        id: suggestionsBySlugRequest
    }

}

