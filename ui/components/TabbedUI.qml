import QtQuick 1.0

Item {
    id: container
    // height of the tab bar
    property int tabsHeight : 71

    // index of the active tab
    property int tabIndex : 0

    // the model used to build the tabs
    property VisualItemModel tabsModel
    signal previousTabClicked;

    // will contain the tab views
    Item {
	id: tabViewContainer
	width: parent.width

        anchors.top: parent.top
        anchors.bottom: tabBar.top
        anchors.bottomMargin: -10

	// build all the tab views
	Repeater {
	    model: tabsModel
        }
    }

    Component.onCompleted:
    {
	// hide all the tab views
	for(var i = 0; i < tabsModel.children.length; i++)
	{
            tabsModel.children[i].visible = false;
            tabs.children[i].icon = tabsModel.children[i].inactiveIcon;
	}
	// select the default tab index
	tabClicked(tabIndex);
    }

    function tabClicked(index)
    {
        if(tabIndex === index)
        {
            previousTabClicked();
        }

	// unselect the currently selected tab
        tabs.children[tabIndex].icon = tabsModel.children[tabIndex].inactiveIcon

	// hide the currently selected tab view
        //item visible and opactiy property must be set up simultaneously,
        // or else there is an display issue on phone
        tabsModel.children[tabIndex].visible = false;
        tabsModel.children[tabIndex].opacity = 0.0;

	// change the current tab index
	tabIndex = index;

	// highlight the new tab
        tabs.children[tabIndex].icon = tabsModel.children[tabIndex].activeIcon;

	// show the new tab view
        tabsModel.children[tabIndex].visible = true;
        tabsModel.children[tabIndex].opacity = 1.0;

        //tabsModel.children[tabIndex].startAnimation();
    }

    Component {
	id: tabBarItem

        Item {
	    height: tabs.height
	    width: tabs.width / tabsModel.count
            property url icon

	    Image {
                id: tabImage
                source: icon
                x: (parent.width - width) / 2
                y: 23
	    }

            Image {
                id: newDataImage
                source: application.getImageSource("home_shine.png")
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                visible: tabsModel.children[index].hasNewData
            }

	    MouseArea {
		anchors.fill: parent
                enabled: tabsModel.children[index].clickedAble
		onClicked: {
		    tabClicked(index);
		}
	    }
	}
    }

    //small arrow
    Image {
        id: smallArrow
        source: application.getImageSource("home_smallarrow.png")
        anchors { top: tabBar.top }
        x: (tabs.width / tabsModel.count - width) / 2 + tabIndex * (tabs.width / tabsModel.count)

        Behavior on x {
            NumberAnimation{ duration: 200; easing.type: Easing.InOutQuad }
        }
    }

    // the tab bar
    Image {
        id: tabBar

	height: tabsHeight
	width: parent.width
        anchors.bottom: parent.bottom
        source: application.getImageSource("home_bottombar.png")

	// place all the tabs in a row
	Row {
            id: tabs
            anchors.fill: parent

	    Repeater {
		model: tabsModel.count
		delegate: tabBarItem
	    }
        }
    }
}
