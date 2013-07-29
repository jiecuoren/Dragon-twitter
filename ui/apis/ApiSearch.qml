import TwitterEngine 1.0

ApiTimelineBase {

    property string _searchText: ""
    property string _searchGeoCode: ""
    property string _search: "http://search.twitter.com/search.json"

    function setSearchText( aText )
    {
        console.log("ApiSearch setSearchText");
        _searchText = aText;
    }

    function setGeoCode( aText )
    {
        console.log("ApiSearch setGeoCode");
        _searchGeoCode = aText;
    }

    function getNewTweets()
    {
        console.log("ApiSearch::getNewTweets");

        if(_searchText === "")
        {
            return;
        }

        var since_id = "";

        if ( targetModel.count > 0 )
        {
            since_id = targetModel.get(0).id;
        }

        var params = new Array();

        if (since_id !== "")
        {
            params.push(["since_id", since_id]);
        }

        if (_searchGeoCode !== "")
        {
            params.push(["geocode", _searchGeoCode]);
        }

        params.push(["q", _searchText]);
        params.push(["rpp", "20"]);
        params.push(["include_entities", "true"]);
        application.getOAuth().webRequest(searchRequest, false, _search,
                                          params, newTweetsReceived, errorCallback);
    }

    function getOldTweets()
    {
        console.log("ApiSearch::getOldTweets");
        if (_isLastPage)
        {
            return;
        }

        var max_id = targetModel.get(targetModel.count - 1).id;
        var params = new Array();

        params.push(["q", _searchText]);

        if (_searchGeoCode !== "")
        {
            params.push(["geocode", _searchGeoCode]);
        }

        params.push(["max_id", max_id]);
        params.push(["rpp", "20"]);
        params.push(["include_entities", "true"]);
        application.getOAuth().webRequest(searchRequest, false, _search,
                                          params, oldTweetsReceived, errorCallback);
    }

    HttpRequest {
        id: searchRequest
    }
}
