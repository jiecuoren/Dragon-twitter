import QtQuick 1.0

Item {
    id: container

    signal keyClicked(string keyStr)
    signal nokiaInputActivated()

    width: keyboardLayout.width
    height: keyboardLayout.height

    property bool _autoShift: false

    function handleTextChanged(text)
    {
        if(text.length === 0 && keyboardLayout.mode === keyboardLayout._abc && !keyboardLayout.shiftIsActive)
        {
            _autoShift = true;
            keyboardLayout.shiftIsActive = true;
        }
        else if(text.length > 0)
        {
            if(_autoShift && text.charAt(text.length - 1) !== " ")
            {
                _autoShift = false;
                keyboardLayout.shiftIsActive = false;
            }

            if(text.charAt(text.length - 1) === " ")
            {
                keyboardLayout.mode = keyboardLayout._abc;
                if(text.length > 1 &&
                   !keyboardLayout.shiftIsActive &&
                  (text.charAt(text.length - 2) === "." ||
                   text.charAt(text.length - 2) === "!" ||
                   text.charAt(text.length - 2) === "?"))
                {
                    _autoShift = true;
                    keyboardLayout.shiftIsActive = true;
                }
            }
        }
    }

    ListModel {
        id: keyArray
        // shift with up case
        ListElement { key: "Q"; popType: "left"; popX: 0; popY: -60 }
        ListElement { key: "W"; popType: "center"; popX: 15; popY: -60 }
        ListElement { key: "E"; popType: "center"; popX: 51; popY: -60 }
        ListElement { key: "R"; popType: "center"; popX: 87; popY: -60 }
        ListElement { key: "T"; popType: "center"; popX: 123; popY: -60 }
        ListElement { key: "Y"; popType: "center"; popX: 159; popY: -60 }
        ListElement { key: "U"; popType: "center"; popX: 195; popY: -60 }
        ListElement { key: "I"; popType: "center"; popX: 231; popY: -60 }
        ListElement { key: "O"; popType: "center"; popX: 267; popY: -60 }
        ListElement { key: "P"; popType: "right"; popX: 291; popY: -60 }
        ListElement { key: "A"; popType: "center"; popX: 3; popY: 5 }
        ListElement { key: "S"; popType: "center"; popX: 39; popY: 5 }
        ListElement { key: "D"; popType: "center"; popX: 75; popY: 5 }
        ListElement { key: "F"; popType: "center"; popX: 111; popY: 5 }
        ListElement { key: "G"; popType: "center"; popX: 147; popY: 5 }
        ListElement { key: "H"; popType: "center"; popX: 183; popY: 5 }
        ListElement { key: "J"; popType: "center"; popX: 219; popY: 5 }
        ListElement { key: "K"; popType: "center"; popX: 255; popY: 5 }
        ListElement { key: "L"; popType: "center"; popX: 291; popY: 5 }
        ListElement { key: "shift"; popType: "hold"; popX: 0; popY: 0 }
        ListElement { key: "Z"; popType: "center"; popX: 33; popY: 70 }
        ListElement { key: "X"; popType: "center"; popX: 69; popY: 70 }
        ListElement { key: "C"; popType: "center"; popX: 105; popY: 70 }
        ListElement { key: "V"; popType: "center"; popX: 141; popY: 70 }
        ListElement { key: "B"; popType: "center"; popX: 177; popY: 70 }
        ListElement { key: "N"; popType: "center"; popX: 213; popY: 70 }
        ListElement { key: "M"; popType: "center"; popX: 249; popY: 70 }
        ListElement { key: "delete"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "sym_press"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: ","; popType: "center"; popX: 33; popY: 135 }
        ListElement { key: "space"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "."; popType: "center"; popX: 249; popY: 135 }
        ListElement { key: "edit"; popType: "press"; popX: 0; popY: 0 }
        // symbol 1
        ListElement { key: "1"; popType: "left"; popX: 0; popY: -60 }
        ListElement { key: "2"; popType: "center"; popX: 15; popY: -60 }
        ListElement { key: "3"; popType: "center"; popX: 51; popY: -60 }
        ListElement { key: "4"; popType: "center"; popX: 87; popY: -60 }
        ListElement { key: "5"; popType: "center"; popX: 123; popY: -60 }
        ListElement { key: "6"; popType: "center"; popX: 159; popY: -60 }
        ListElement { key: "7"; popType: "center"; popX: 195; popY: -60 }
        ListElement { key: "8"; popType: "center"; popX: 231; popY: -60 }
        ListElement { key: "9"; popType: "center"; popX: 267; popY: -60 }
        ListElement { key: "0"; popType: "right"; popX: 291; popY: -60 }
        ListElement { key: "-"; popType: "center"; popX: 3; popY: 5 }
        ListElement { key: "/"; popType: "center"; popX: 39; popY: 5 }
        ListElement { key: ":"; popType: "center"; popX: 75; popY: 5 }
        ListElement { key: ";"; popType: "center"; popX: 111; popY: 5 }
        ListElement { key: "("; popType: "center"; popX: 147; popY: 5 }
        ListElement { key: ")"; popType: "center"; popX: 183; popY: 5 }
        ListElement { key: "$"; popType: "center"; popX: 219; popY: 5 }
        ListElement { key: "€"; popType: "center"; popX: 255; popY: 5 }
        ListElement { key: "&"; popType: "center"; popX: 291; popY: 5 }
        ListElement { key: "1_press"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "@"; popType: "center"; popX: 33; popY: 70 }
        ListElement { key: "\""; popType: "center"; popX: 69; popY: 70 }
        ListElement { key: "\'"; popType: "center"; popX: 105; popY: 70 }
        ListElement { key: "*"; popType: "center"; popX: 141; popY: 70 }
        ListElement { key: "#"; popType: "center"; popX: 177; popY: 70 }
        ListElement { key: "!"; popType: "center"; popX: 213; popY: 70 }
        ListElement { key: "?"; popType: "center"; popX: 249; popY: 70 }
        ListElement { key: "delete"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "abc_press"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: ","; popType: "center"; popX: 33; popY: 135 }
        ListElement { key: "space"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "."; popType: "center"; popX: 249; popY: 135 }
        ListElement { key: "edit"; popType: "press"; popX: 0; popY: 0 }
        // symbol 2
        ListElement { key: "["; popType: "left"; popX: 0; popY: -60 }
        ListElement { key: "]"; popType: "center"; popX: 15; popY: -60 }
        ListElement { key: "{"; popType: "center"; popX: 51; popY: -60 }
        ListElement { key: "}"; popType: "center"; popX: 87; popY: -60 }
        ListElement { key: "%"; popType: "center"; popX: 123; popY: -60 }
        ListElement { key: "^"; popType: "center"; popX: 159; popY: -60 }
        ListElement { key: "+"; popType: "center"; popX: 195; popY: -60 }
        ListElement { key: "="; popType: "center"; popX: 231; popY: -60 }
        ListElement { key: "_"; popType: "center"; popX: 267; popY: -60 }
        ListElement { key: "\\"; popType: "right"; popX: 291; popY: -60 }
        ListElement { key: "|"; popType: "center"; popX: 3; popY: 5 }
        ListElement { key: "~"; popType: "center"; popX: 39; popY: 5 }
        ListElement { key: "<"; popType: "center"; popX: 75; popY: 5 }
        ListElement { key: ">"; popType: "center"; popX: 111; popY: 5 }
        ListElement { key: "·"; popType: "center"; popX: 147; popY: 5 }
        ListElement { key: "$"; popType: "center"; popX: 183; popY: 5 }
        ListElement { key: "€"; popType: "center"; popX: 219; popY: 5 }
        ListElement { key: "£"; popType: "center"; popX: 255; popY: 5 }
        ListElement { key: "¥"; popType: "center"; popX: 291; popY: 5 }
        ListElement { key: "2_press"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "@"; popType: "center"; popX: 33; popY: 70 }
        ListElement { key: "\""; popType: "center"; popX: 69; popY: 70 }
        ListElement { key: "\'"; popType: "center"; popX: 105; popY: 70 }
        ListElement { key: "*"; popType: "center"; popX: 141; popY: 70 }
        ListElement { key: "#"; popType: "center"; popX: 177; popY: 70 }
        ListElement { key: "!"; popType: "center"; popX: 213; popY: 70 }
        ListElement { key: "?"; popType: "center"; popX: 249; popY: 70 }
        ListElement { key: "delete"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "abc_press"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: ","; popType: "center"; popX: 33; popY: 135 }
        ListElement { key: "space"; popType: "press"; popX: 0; popY: 0 }
        ListElement { key: "."; popType: "center"; popX: 249; popY: 135 }
        ListElement { key: "edit"; popType: "press"; popX: 0; popY: 0 }
    }

    Image {
        id: keyboardLayout;
        source: application.getImagePath() + "bg_" + mode + ".png"
        x: 0
        y: 0

        property int mode: _abc;
        property string pressKeyValue;
        property string keyValue;
        property bool shiftIsActive: false;
        property int _abc: 0;
        property int _sym1: 1;
        property int _sym2: 2;

        function hidePressKey()
        {
            shift.visible = false;
            sym1.visible = false;
            sym2.visible = false;
            abc.visible = false;
            symbol.visible = false;
            backspace.visible = false;
            edit.visible = false;
            space.visible = false;
        }

        function checkMousePoint(x, y)
        {
            var val = -1;
            if(y >= 5 && y < 70)
            {
                val = keyboardLayout.mode*33 + x/36;
            }
            else if(y >= 70 && y < 135)
            {
                if(x < 18 || x >= 342)
                {
                    val = -1;
                }
                else
                {
                    val = keyboardLayout.mode*33 + 10 + (x-18)/36;
                }
            }
            else if(y >= 135 && y < 200)
            {
                if(x < 54)
                {
                    val = keyboardLayout.mode*33 + 19;
                }
                else if(x >= 306)
                {
                    val = keyboardLayout.mode*33 + 27;
                }
                else
                {
                    val = keyboardLayout.mode*33 + 20 + (x - 54)/36;
                }
            }
            else if(y >= 200 && y< 265)
            {
                if(x < 54)
                {
                    val = keyboardLayout.mode*33 + 28;
                }
                else if(x >= 54 && x < 90)
                {
                    val = keyboardLayout.mode*33 + 29;
                }
                else if(x >= 90 && x < 270)
                {
                    val = keyboardLayout.mode*33 + 30;
                }
                else if(x >= 270 && x < 306)
                {
                    val = keyboardLayout.mode*33 + 31;
                }
                else
                {
                    val = keyboardLayout.mode*33 + 32;
                }
            }
            return val;
        }

        function pressCharacter(key)
        {
            if(key == "space")
            {
                container.keyClicked(" ");
            }
            else if(key == "delete")
            {
                container.keyClicked("delete");
            }
            else if(key.length == 1 && keyboardLayout.mode > keyboardLayout._abc)
            {
                container.keyClicked(key);
            }
            else if(key.length == 1 && keyboardLayout.mode == keyboardLayout._abc)
            {
                var str = key.toLowerCase();
                if(keyboardLayout.shiftIsActive)
                {
                    str = key.toUpperCase();
                }
                container.keyClicked(str);
            }
        }

        PopupBubble2 {
            id: popupBubble;
        }

        Image {
            id: shifthold
            source: application.getImageSource("shift_hold.png");
            visible: keyboardLayout.shiftIsActive && keyboardLayout.mode == keyboardLayout._abc
            x: 0
            y: 135
        }

        Image {
            id: shift
            source: application.getImageSource("shift_press.png");
            visible: false
            x: 0
            y: 135
        }

        Image {
            id: sym1
            source: application.getImageSource("1_press.png");
            visible: false
            x: 0
            y: 135
        }

        Image {
            id: sym2
            source: application.getImageSource("2_press.png");
            visible: false
            x: 0
            y: 135
        }

        Image {
            id: abc
            source: application.getImageSource("abc_press.png");
            visible: false
            x: 0
            y: 200
        }

        Image {
            id: symbol
            source: application.getImageSource("sym_press.png");
            visible: false
            x: 0
            y: 200
        }

        Image {
            id: backspace
            source: application.getImageSource("back_press.png");
            visible: false
            x: 306
            y: 135
        }

        Image {
            id: edit
            source: application.getImageSource("edit_press.png");
            visible: false
            x: 306
            y: 200
        }

        Image {
            id: space
            source: application.getImageSource("space_press.png");
            visible: false
            x: 90
            y: 200
        }

        MouseArea {
            anchors.fill: parent;
            onPressed: {
                var index = keyboardLayout.checkMousePoint(mouseX, mouseY);
                if(index < 0)
                {
                    keyboardLayout.hidePressKey();
                    return;
                }

                keyboardLayout.pressKeyValue = keyArray.get(index).key;
                if(keyboardLayout.pressKeyValue.length == 1)
                {
                    popupBubble.position = keyArray.get(index).popType;
                    popupBubble.x = keyArray.get(index).popX;
                    popupBubble.y = keyArray.get(index).popY;
                    popupBubble.text = keyboardLayout.pressKeyValue;
                    popupBubble.showPopup = true;
                }
                else
                {
                    if(keyboardLayout.pressKeyValue == "shift")
                    {
                        keyboardLayout.hidePressKey();
                        shift.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "1_press")
                    {
                        keyboardLayout.hidePressKey();
                        sym1.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "2_press")
                    {
                        keyboardLayout.hidePressKey();
                        sym2.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "sym_press")
                    {
                        keyboardLayout.hidePressKey();
                        symbol.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "abc_press")
                    {
                        keyboardLayout.hidePressKey();
                        abc.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "delete")
                    {
                        keyboardLayout.hidePressKey();
                        backspace.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "space")
                    {
                        keyboardLayout.hidePressKey();
                        space.visible = true;
                    }
                    else if(keyboardLayout.pressKeyValue == "edit")
                    {
                        keyboardLayout.hidePressKey();
                        edit.visible = true;
                    }
                }
                timer.start();
            }

            onMousePositionChanged: {
                popupBubble.showPopup = false;
                var index = keyboardLayout.checkMousePoint(mouseX, mouseY);
                if(index < 0)
                {
                    keyboardLayout.hidePressKey();
                    return;
                }
                keyboardLayout.keyValue = keyArray.get(index).key;
                if(keyboardLayout.keyValue.length == 1 && keyboardLayout.pressKeyValue.length == 1)
                {
                    popupBubble.position = keyArray.get(index).popType;
                    popupBubble.x = keyArray.get(index).popX;
                    popupBubble.y = keyArray.get(index).popY;
                    popupBubble.text = keyboardLayout.keyValue;
                    popupBubble.showPopup = true;
                }
                else if(keyboardLayout.keyValue != keyboardLayout.pressKeyValue)
                {
                    keyboardLayout.hidePressKey();
                }
            }

            onReleased: {
                timer.stop();
                if (keyboardLayout.keyValue == keyboardLayout.pressKeyValue)
                {
                    if (keyboardLayout.pressKeyValue == "shift")
                    {
                        keyboardLayout.shiftIsActive = !keyboardLayout.shiftIsActive;
                    }
                    else if (keyboardLayout.pressKeyValue == "sym_press")
                    {
                        keyboardLayout.mode = keyboardLayout._sym1;
                    }
                    else if (keyboardLayout.pressKeyValue == "abc_press")
                    {
                        keyboardLayout.mode = keyboardLayout._abc;
                        keyboardLayout.shiftIsActive = false;
                    }
                    //edit means function key to active nokia input method
                    else if (keyboardLayout.pressKeyValue == "edit")
                    {
                        container.nokiaInputActivated();
                    }
                    else if (keyboardLayout.pressKeyValue == "1_press")
                    {
                        keyboardLayout.mode = keyboardLayout._sym2;
                    }
                    else if (keyboardLayout.pressKeyValue == "2_press")
                    {
                        keyboardLayout.mode = keyboardLayout._sym1;
                    }
                    else
                    {
                        keyboardLayout.pressCharacter(keyboardLayout.pressKeyValue);
                    }
                    keyboardLayout.hidePressKey();
                }
                else if(keyboardLayout.keyValue.length == 1 && keyboardLayout.pressKeyValue.length == 1)
                {
                    keyboardLayout.pressCharacter(keyboardLayout.pressKeyValue);
                }
                keyboardLayout.keyValue = "";
                keyboardLayout.pressKeyValue = "";
                popupBubble.showPopup = false;
            }
        }
        Timer {
            id : timer
            interval: 200
            running: false
            repeat: true
            triggeredOnStart: false
            onTriggered: {
                if (keyboardLayout.pressKeyValue == "delete")
                {
                    keyboardLayout.pressCharacter("delete");
                }
            }
        }
    }
}
