import QtQuick 1.0

import "../apis"
import "../models"
import "../components"

Item {
    id: container
    anchors.fill: parent

    function handleActivition()
    {
        trendingNowApi.getTrendingNow();
    }

    function positionViewAtBeginning()
    {
        flickable.contentY = 0;
    }

    Component.onCompleted: {
        console.log(" search tab onCompleted");
        if (application.user_id !== "")
        {
            trendingNowApi.getTrendingNow();
        }
    }

    ApiTrendingNow {
        id : trendingNowApi
        onDataReceived: {
            console.log("trendingNowModel count="+trendingNowModel.count);
            checkNewTrendingNowTimer.running = true;
        }
        onErrorOccured: {
            console.log("trendingNowModel onErrorOccured");
            checkNewTrendingNowTimer.running = true;
        }
    }

    ModelTrendingNow {
        id : trendingNowModel
    }

    Flickable {
        id : flickable
        anchors {
            top : parent.top
            bottom: parent.bottom
        }
        clip : true
        width: parent.width
        contentWidth: parent.width
        contentHeight: lastPart.y + lastPart.height + 20

        Image {
            id :searchBarBg
            source: application.getImageSource("searchbar_01.png");

            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: searchText
                anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 50}
                font {pixelSize: 21; family: "Catriel";}
                color: "gray"
                text: "Search for topic or name"
            }

            MouseArea {
                id : mouseArea
                anchors.fill: parent
                onClicked: {
                    console.log("search text mouse area is clicked");
                    var view = viewmanager.getView( application.kSearchTweetsView, true);
                    viewmanager.activateView(view, viewmanager.slideLeft);
                }
            }

        }

        Text {
            id : trendingNowText
            anchors {
                top: searchBarBg.bottom
                topMargin: 10
                left: parent.left
                leftMargin: 30
            }
            font {
                pixelSize: 21;
                family: "Catriel";
            }
            color: "gray"
            text: "Trending Now"
        }

        ButtonList {
            id: listPanel
            anchors {
                top : trendingNowText.bottom
                topMargin : 10
                left: parent.left
                leftMargin: 20
            }
            textWidth: 280
            model: trendingNowModel

            onItemSelected:{
                console.log(index)
                var view = viewmanager.getView( application.kSearchResultView, true);
                view.title = listPanel.model.get( index ).full_name;
                view.queryText = decodeURIComponent( listPanel.model.get(index).query );
                viewmanager.activateView( view, viewmanager.slideLeft );
            }
        }

        Column {
            id : lastPart
            width: parent.width
            x: 20
            y: listPanel.y + listPanel.height - 41
            spacing: 1

            SimpleButton {
                id: suggestedBtn
                pressIcon: application.getImageSource("button_single_press.png");
                normalIcon: application.getImageSource("button_single_normal.png");
                text: "Suggested Users"
                textColor: "black"
                textX: 10
                onClicked: {
                    console.log("suggestedBtn clicked");
                    var view = viewmanager.getView( application.kSuggestedCategoryView, true);
                    viewmanager.activateView( view, viewmanager.slideLeft );
                }

                Image {
                    id: lineArrow
                    source: application.getImageSource("button_arrow_right.png")
                    anchors {right: suggestedBtn.right; rightMargin: 5; verticalCenter: parent.verticalCenter}
                }
            }
        }

    }

    Timer {
        id: checkNewTrendingNowTimer
        running: false
        repeat: true
        interval: 10 * 60 * 1000 //10 mins
        onTriggered: {
            trendingNowApi.getTrendingNow();
        }
    }
}

