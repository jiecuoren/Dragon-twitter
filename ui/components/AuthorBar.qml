import QtQuick 1.0

Item {
     id: container

     property alias authorBarName: displayname.text
     property alias authorBarScreenName: screenname.text
     property alias source: avatar.profileSource

     signal clicked()

     width: parent.width

     ProfileImg {
         id: avatar
         anchors {
             verticalCenter: parent.verticalCenter
             left: parent.left
             leftMargin: 19
         }
     }

     Text {
         id: displayname
         width: parent.width - avatar.width - avatar.anchors.leftMargin - goto_arrow.width
                - displayname.anchors.leftMargin - goto_arrow.anchors.rightMargin
         elide: Text.ElideRight
         anchors {
             top: parent.top
             topMargin: 18
             left: avatar.right
             leftMargin: 10
         }
         font { pixelSize: 24; family: "Catriel"; bold:true }
         color:"#403F41"

     }

     Text {
         id: screenname
         width: displayname.width
         elide: Text.ElideRight
         anchors {
             top: displayname.bottom
             left: avatar.right
             leftMargin: 10
         }
         font { pixelSize: 24; family: "Catriel"; bold:true }
         color:"#403F41"

     }

     Image {
         id: goto_arrow
         anchors {
             verticalCenter: parent.verticalCenter
             right: parent.right
             rightMargin: 10
         }
         source: application.getImageSource("read_button_goto_normal.png")
     }

     MouseArea {
         id: gotoArrowMouseArea
         anchors.fill: parent
         onClicked: {
             console.log("goto arrow mouse area is clicked");
             container.clicked();
         }
     }

}
