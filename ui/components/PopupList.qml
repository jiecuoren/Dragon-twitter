import QtQuick 1.0
import "../javascript/localdata.js" as LocalDB

// for new tweet view pop up list only currently
Rectangle {
    id: container
    height: parent.height
    width: parent.width
    visible: listType > 0

    signal stringAppended(string content)

    property int listType: _noList

    property int _noList: 0
    property int _atMe: 1
    property int _topic: 2

    function loadTopic(filter)
    {
        console.log("loadTopic ", topicModel.count);
        listModel.clear();
        var index = 0;
        if(filter.length === 0)
        {
            for(index = 0; index < topicModel.count; index++)
            {
                listModel.append({ "line1Text": topicModel.get(index).topic,
                                   "line2Text": "",
                                   "icon_url" : "" })
            }
        }
        else
        {
            var patt = new RegExp(filter, "i");
            for(index = 0; index < topicModel.count; index++)
            {
                if(topicModel.get(index).topic.search(patt) === 0)
                {
                    listModel.append({ "line1Text": topicModel.get(index).topic,
                                       "line2Text": "",
                                       "icon_url" : "" })
                }
            }
        }
        console.log("loadTopic end ", listModel.count);
    }

    function loadAtMe(filter)
    {
        console.log("loadAtMe ", atMeModel.count);
        listModel.clear();
        var index = 0;
        if(filter.length === 0)
        {
            for(index = 0; index < atMeModel.count; index++)
            {
                listModel.append({ "line1Text": atMeModel.get(index).screenName,
                                   "line2Text": atMeModel.get(index).name,
                                   "icon_url": atMeModel.get(index).profileImg })
            }
        }
        else
        {
            var patt = new RegExp(filter, "i");
            for(index = 0; index < atMeModel.count; index++)
            {
                if(atMeModel.get(index).screenName.search(patt) === 0)
                {
                    listModel.append({ "line1Text": atMeModel.get(index).screenName,
                                       "line2Text": atMeModel.get(index).name,
                                       "icon_url": atMeModel.get(index).profileImg })
                }
            }
        }
        console.log("loadAtMe end ", listModel.count);
    }

    function setListType(type)
    {
        if(listModel.count > 0 && type > 0)
        {
            listType = type;
        }
        else
        {
            listType = _noList;
        }
    }

    gradient: Gradient {
             GradientStop { position: 0.0; color: "gray" }
             GradientStop { position: 0.05; color: "#d2d2d2" }
             GradientStop { position: 1.0; color: "#e5e5e5" }
    }

    ListModel {
        id: topicModel
    }

    ListModel {
        id: atMeModel
    }

    ListModel {
        id: listModel
    }

    SimpleList {
        id: list
        anchors.fill: parent
        singleLine: container.listType != container._atMe
        hasIcon: container.listType == container._atMe
        model: listModel
        onItemSelected: {
            var str = listModel.get(index).line1Text + " ";
            container.stringAppended(str);
        }
    }
    ScrollBar { scrollArea: list.listView; height: list.height; width: 8; anchors.right: list.right }

    Component.onCompleted: {
        LocalDB.loadAtMeInfo(atMeModel);
        LocalDB.loadTopic(topicModel);
    }
}
