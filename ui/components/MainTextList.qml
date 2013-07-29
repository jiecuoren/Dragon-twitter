import QtQuick 1.0
import "../javascript/commonFunction.js" as CommonFunction

ListView {
    id: mainTextList

    signal activeProfileView( string userid, bool fromMentions )
    signal activeRetweetUserProfileView( string screenname )
    signal activeSearchView( string hashtags )
    signal activeUrlWebView( string url )
    signal activeOriginalImageView( string image )
    signal activePreviousView()

    width: parent.width
    height: parent.height
    clip: true
    focus: true
    interactive:false
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 300
    anchors { verticalCenter: parent.verticalCenter }
    delegate: mainTextListDelegate

    Component {
        id : mainTextListDelegate

        Item {

            id: container

            property string displayText: ''

            property variant usermodel: mainTextList.model.get( mainTextList.currentIndex ).user_mentions
            property variant hashtagsmodel : mainTextList.model.get( mainTextList.currentIndex ).hashtags
            property variant urlsmodel : mainTextList.model.get( mainTextList.currentIndex ).urls
            property variant mediamodel : mainTextList.model.get( mainTextList.currentIndex ).media

            //location info
            property variant _geo: mainTextList.model.get( mainTextList.currentIndex ).geo
            property variant _place: mainTextList.model.get( mainTextList.currentIndex ).place
            property double _latitude : 0
            property double _longitude : 0
            property url _locationImage: ''
            property string _locationText: ''

            property string _original_pic_url: ''
            property string _small_pic_url: ''

            function doLink( )
            {
                var str = ( mini_blog_content );
                var i = 0;
                var ch ='';
                var patt = '';

                var count = usermodel.count;
                for ( i = 0; i < count; i++ )
                {
                    ch =  usermodel.get(i).screen_name ;
                    ch = "@"+ ch;
                    var user_id_str =  usermodel.get(i).id_str ;
                    patt = new RegExp(ch,"gi");
                    str = str.replace( patt, ch.link( ["mentions",user_id_str] ) );
                }

                count = hashtagsmodel.count;
                for ( i = 0; i < count; i++ )
                {
                    ch = ( hashtagsmodel.get(i).text );
                    ch = "#"+ ch;
                    patt = new RegExp(ch,"gi");
                    str = str.replace( patt, ch.link( ["hashtags",i] ) );
                }

                count = urlsmodel.count;
                for ( i = 0; i < count; i++ )
                {
                    ch = urlsmodel.get(i).url;
                    if ( typeof ( urlsmodel.get(i).display_url ) === "undefined"  )
                    {
                        if ( typeof ( urlsmodel.get(i).expanded_url ) === "undefined" )
                        {
                            str = str.replace( ch, ch.link(  ["urls",""] ) );
                        }
                        else
                        {
                            str = str.replace( ch, ch.link(  ["urls",urlsmodel.get(i).expanded_url] ) );
                        }
                    }
                    else
                    {
                        if ( typeof ( urlsmodel.get(i).expanded_url ) === "undefined" )
                        {
                            str = str.replace( ch, urlsmodel.get(i).display_url.link( ["urls",urlsmodel.get(i).url] ) );
                        }
                        else
                        {
                            str = str.replace( ch, urlsmodel.get(i).display_url.link( ["urls",urlsmodel.get(i).expanded_url] ) );
                        }
                    }

                }

                count = mediamodel.count;
                for ( i = 0; i < count; i++ )
                {
                    ch = mediamodel.get(i).url;
                    if ( typeof ( mediamodel.get(i).display_url ) === "undefined"  )
                    {
                        if ( typeof ( mediamodel.get(i).expanded_url ) === "undefined" )
                        {
                            str = str.replace( ch, ch.link(  ["media",""] ) );
                        }
                        else
                        {
                            str = str.replace( ch, ch.link(  ["media",mediamodel.get(i).media_url] ) );
                        }
                    }
                    else
                    {
                        if ( typeof ( mediamodel.get(i).expanded_url ) === "undefined" )
                        {
                            str = str.replace( ch, mediamodel.get(i).display_url.link( ["media",""] ) );
                        }
                        else
                        {
                            str = str.replace( ch, mediamodel.get(i).display_url.link( ["media",mediamodel.get(i).media_url] ) );
                        }
                    }

                }
                return str;
            }

            function getFirstOriginalImage(  )
            {
                var originalpicurl ='';
                var count = mediamodel.count;
                if ( count > 0 )
                {
                    if ( typeof ( mediamodel.get(0).media_url ) !== "undefined"  )
                    {
                        originalpicurl = mediamodel.get(0).media_url;
                    }
                }
                return originalpicurl;
            }

            function getFirstSmallImage(  )
            {
                var smallpicurl = '';
                var count = mediamodel.count;
                if ( count > 0 )
                {
                    if ( typeof ( mediamodel.get(0).media_url_https ) !== "undefined"  )
                    {
                        smallpicurl = mediamodel.get(0).media_url_https+ ":" +"small";
                    }
                }
                return smallpicurl;
            }

            function getLocationImageByCoordinate( lat,longi )
            {
                var locUrl = "http://maps.googleapis.com/maps/api/staticmap?center=";
                locUrl = locUrl + lat + "," + longi + "&zoom=15&size=320x150&sensor=false";
                return locUrl;
            }

            function getLocationImageUrlByName( placefullname )
            {
                var locUrl = "http://maps.googleapis.com/maps/api/staticmap?center=";
                locUrl = locUrl + placefullname + "&zoom=10&size=320x150&sensor=false";
                return locUrl;
            }

            function getLocationInfo()
            {
                if ( typeof ( _geo ) === "object" )
                {
                    _longitude = _geo.coordinates[1];
                    _latitude = _geo.coordinates[0];
                    _locationImage = getLocationImageByCoordinate( _latitude,_longitude );
                }
                else if ( typeof ( _place ) === "object" )
                {
                    _locationText = _place.full_name;
                    _locationImage = getLocationImageUrlByName( _locationText );
                }

            }

            width: ListView.view.width
            height: ListView.view.height


            Image {
                id: itemBorder
                anchors.fill: parent
                source: application.getImageSource("bg_categorybar_read.png")
            }

            AuthorBar {
                id : authorbar
                height: 100
                anchors.top: parent.top
                source: ( true === default_profile_image ) ? application.getImageSource("avatar_default.png") : profile_image_url
                authorBarName: name === ''? screen_name : name
                authorBarScreenName: "@" + screen_name
                onClicked:{
                    mainTextList.activeProfileView( user_id, false );
                }
            }

            Flickable {
                id : flick
                anchors.top: authorbar.bottom
                width: parent.width
                height: parent.height - authorbar.height
                contentWidth: parent.width
                contentHeight:blogContent.height
                flickableDirection: Flickable.VerticalFlick

                BorderImage {
                    id: borderflick
                    property int mouseStartX: 0
                    property bool sendSignal: false
                    source: application.getImageSource("bg_head_read.png")
                    width: parent.width
                    height: flick.height + flick.contentY + 20
                    anchors {
                        top:parent.top
                        topMargin:-20
                    }
                    border { left: 0; top: 30; right: 0; bottom: 30 }
                    horizontalTileMode: BorderImage.Stretch

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent

                        onPressed: {
                            borderflick.sendSignal = false;
                            borderflick.mouseStartX = mouseX;
                        }

                        onMouseXChanged: {
                            var xMove = mouseX - borderflick.mouseStartX;
                            if ( xMove > 15  &&  borderflick.sendSignal === false )
                            {
                                mainTextList.activePreviousView();
                                borderflick.sendSignal = true;
                            }
                        }
                    }

                }

                Column {
                    id : blogContent
                    function getColumnHeight()
                    {
                        var columnHeight = blogText.height + label.height
                            + retweetbysomeone.height + 2*blogContent.spacing + 20;
                        if ( blogimage.visible )
                        {
                            columnHeight += blogimage.height + blogContent.spacing;
                        }

                        if ( locImage.visible )
                        {
                            columnHeight += locImage.height + blogContent.spacing
                                    + locText.height + blogContent.spacing;
                        }

                        if ( replyButton.visible )
                        {
                            columnHeight += replyButton.height + blogContent.spacing;
                        }

                        return columnHeight;
                    }

                    function parserLink( parserData )
                    {
                        var para = parserData.split(",");
                        switch ( para[0] )
                        {
                        case "mentions":
                            console.log("para[1]",para[1]);
                            //active user profile view
                            mainTextList.activeProfileView( para[1], true);
                            break;
                        case "urls":
                            console.log("para[1]",para[1]);
                            //active web view
                            mainTextList.activeUrlWebView( para[1] );
                            break;
                        case "hashtags":
                            console.log("para[1]",para[1]);
                            //active search view
                            var ch = '';
                            var count = container.hashtagsmodel.count;
                            for (var i = 0; i < count; i++ )
                            {
                                if ( para[1] == i )
                                {
                                    ch = ( hashtagsmodel.get(i).text );
                                    ch = "#"+ ch;
                                    break;
                                }
                            }
                            //active search view
                            console.log("hash tags model ",ch);
                            mainTextList.activeSearchView( ch );
                            break;
                        case "media":
                            console.log("para[1]",para[1]);
                            //active show large image view
                            mainTextList.activeOriginalImageView( para[1] );
                            break;
                        default:
                            console.log("para[1]",para[1]);
                            break;
                        }

                    }

                    y: 20
                    spacing: 10
                    width: parent.width
                    height: getColumnHeight()

                    Text {
                        id: blogText
                        width: parent.width - 2*blogText.x
                        x:20
                        font { pixelSize: 24; family: "Catriel"; bold:true }
                        color:"#403F41"
                        wrapMode: Text.Wrap
                        textFormat: Text.RichText
                        text: "<style type='text/css'>a:link {color:#0000FF} a:visited {color:#0000FF}</style>"
                                + container.displayText
                        onLinkActivated: {
                            console.log("onLinkActivated", link );
                            blogContent.parserLink( link );
                        }
                    }

                    BlogImage {
                        id : blogimage
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: container._small_pic_url
                        visible: blogimage.source !==''? true: false
                        onDownloadingStarted: {
                            console.log("show downloading progress...")
                            mainTextList.activeOriginalImageView( container._original_pic_url );
                        }
                    }

                    BlogImage {
                        id : locImage
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: container._locationImage
                        visible: locImage.source !==''? true: false
                    }

                    Text {
                        id : locText
                        x:20
                        font { pixelSize: 18; family: "Catriel"; }
                        color:"#403F41"
                        textFormat: Text.RichText
                        visible: container._locationText !== ''
                        text: "from " + container._locationText
                    }

                    Row {
                        id : label
                        x: 20
                        spacing: 5
                        Text {
                            id : fromLabel
                            font { pixelSize: 18; family: "Catriel"; }
                            color:"#403F41"
                            textFormat: Text.RichText
                            text: "<style type='text/css'>a:link {color:#403F41;text-decoration:none;} a:visited {color:#0000FF}</style>"
                                  + user_from
                        }

                        Image {
                            id :dotImage
                            width: 5
                            height: 5
                            anchors.verticalCenter: parent.verticalCenter
                            source: application.getImageSource("dot.png")
                        }

                        Text {
                            id : createdAtLabel
                            font { pixelSize: 18; family: "Catriel"; }
                            color:"#403F41"
                            textFormat: Text.RichText
                            text: CommonFunction.formatDatetime(created_at)
                        }
                    }

                    Text {
                        id : retweetbysomeone
                        x:20
                        font { pixelSize: 18; family: "Catriel"; }
                        color:"#403F41"
                        textFormat: Text.RichText
                        text:  retweeted_by === "" ? "" :
                        "<style type='text/css'>a:link {color:#0000FF;text-decoration:none;} a:visited {color:#0000FF}</style>"
                        + "Retweeted by "  + retweeted_by.link(retweeted_by)
                        visible: retweeted_by !== ""
                        onLinkActivated: {
                            console.log("retweetbysomeone onLinkActivated", link );
                            mainTextList.activeRetweetUserProfileView( retweeted_by );
                        }
                    }

                    Button {
                        id: replyButton
                        normalIcon: application.getImageSource("button_other_normal.png")
                        pressIcon: application.getImageSource("button_other_press.png")
                        text: "in reply to..."
                        x: parent.width - replyButton.width - 20
                        visible: false
                        onClicked: {
                                console.log("replyButton mouse area is clicked")
                        }
                    }

                }

            }

            Component.onCompleted: {
                container.displayText = container.doLink();
                container._small_pic_url = container.getFirstSmallImage();
                container._original_pic_url = container.getFirstOriginalImage();
                container.getLocationInfo();
            }

        }

    }// component end

}
