import QtQuick 1.0
import TwitterEngine 1.0

// item element, must have a parent of rectangle or image
Item {
    id : container
    width: parent.width

    property alias editorText : editor.text
    property alias textFontSize : editor.font.pixelSize
    property alias textColor : editor.color
    property alias textWrapMode : editor.wrapMode
    property alias editorX: editor.x
    property alias editorY: editor.y
    property alias paintedHeight: editor.paintedHeight
    property alias editorVAlignment: editor.verticalAlignment
    property alias editorCurseVisible: editor.cursorVisible
    property bool enableKeyboard: true //if false, both in default state and
                                       //hideKeyboard state, keyboard is out of sight
    property int maxInputTextLength: 140
    property int cursorPos: editorText.length
    property int keyboardHeight: keyboard.height
    property int absoluteY: 0
    property bool _inputString : true

    signal textValueChanged(string text)
    signal keyboardActived()

    function showKeyboard()
    {
        state = "";
        if(enableKeyboard)
        {
            deactiveNokiaInputMethod();
            keyboardActived();
        }
        else
        {
            activeNokiaInputMethod();
        }
    }

    function hideKeyboard()
    {
        state = "hideKeyboard";
        if(enableKeyboard)
        {
            activeMouseArea();
        }
    }

    function activeMouseArea()
    {
        editor.activeMouseRegion();
    }

    function activeNokiaInputMethod()
    {
        editor.openNokiaInputMethod();
    }

    function deactiveNokiaInputMethod()
    {
        editor.closeNokiaInputMethod();
    }

    function reset()
    {
        cursorPos = 0;
        editorText = '';
    }

    function handleKeyEvent( keyStr )
    {
        if (editor.selectedText !== "")
        {
            if(keyStr == "delete")
            {
                editor.text = container.removeSelectedString(editor.text, editor.selectedText,editor.selectionStart, editor.selectionEnd);
            }
            else if(editor.text.length + keyStr.length - editor.selectedText.length <= container.maxInputTextLength)
            {
                editor.text = container.replaceSelectedString(editor.text, editor.selectedText,editor.selectionStart, editor.selectionEnd, keyStr);
            }
            else
            {
                console.log("has reached max input number");
            }
        }
        else
        {
            if(keyStr == "delete")
            {
                editor.text = container.removeString(editor.text, container.cursorPos);
            }
            else if( editor.text.length + keyStr.length <= container.maxInputTextLength )
            {
                editor.text = container.mergeString(editor.text, keyStr, container.cursorPos);
            }
            else if( keyStr.length > container.maxInputTextLength )
            {
                var tempStr = editor.text + keyStr;
                container.updateCursorPos( tempStr.length );
                editor.text = tempStr;
            }
            else
            {
                console.log("has reached max input number");
            }
        }
    }

    function mergeString(originStr, newStr, pos)
    {
        var str;
        var curPos = 0;
        var length = originStr.length;
        if (pos === length)
        {
            str = originStr + newStr;
            curPos = str.length;
        }
        else if (pos === 0)
        {
            str = newStr + originStr;
            curPos = newStr.length;
        }
        else
        {
            str = originStr.substring(0, pos) + newStr + originStr.substring(pos, length);
            curPos = (originStr.substring(0, pos) + newStr).length;
        }
        container.updateCursorPos(curPos);
        return str;
    }

    function updateCursorPos(pos)
    {
        container.cursorPos = pos;
        _inputString = true;
    }

    function removeString(originStr, pos)
    {
        var str;
        var curPos = 0;
        var length = originStr.length;
        if (pos === length)
        {
            str = originStr.substring(0, pos-1);
            curPos = str.length;
        }
        else if (pos === 0)
        {
            str = originStr;
            curPos = str.length;
        }
        else
        {
            str = originStr.substring(0, pos-1) + originStr.substring(pos, length);
            curPos = (originStr.substring(0, pos-1)).length;
        }
        container.updateCursorPos(curPos);
        return str;
    }

    function removeSelectedString(originStr, selectedStr, start, end)
    {
        var str;
        var curPos = 0;
        var length = originStr.length;
        if (selectedStr.length === length)
        {
            str = "";
            curPos = str.length;
        }
        else if (selectedStr.length < length)
        {
            str = originStr.substring( 0, start ) + originStr.substring(end, length);
            curPos = (originStr.substring(0, start )).length;
        }
        else
        {

        }
        container.updateCursorPos(curPos);
        return str;
    }

    function replaceSelectedString(originStr, selectedStr, start, end, inputStr)
    {
        var text;
        text = removeSelectedString(originStr, selectedStr, start, end);
        return mergeString(text, inputStr, container.cursorPos);
    }

    TextEdit {
        id : editor
        width: parent.width
        height: parent.height
        font.pixelSize: 24
        font.family: "Catriel"
        color: "#403F41"
        activeFocusOnPress : false
        cursorVisible: true
        wrapMode: TextEdit.Wrap
        selectByMouse: true
        clip: true

        function activeMouseRegion()
        {
            editormousearea.enabled = true;
        }

        function openNokiaInputMethod()
        {
            activeFocusOnPress = true;
            forceActiveFocus();
            openSoftwareInputPanel();
        }

        function closeNokiaInputMethod()
        {
            activeFocusOnPress = false;
            closeSoftwareInputPanel();
        }

        MouseArea {
            id: editormousearea
            anchors.fill: parent
            enabled: ((editor.activeFocusOnPress || container.state == "hideKeyboard") && container.enableKeyboard)
            onClicked: {
                container.showKeyboard();
                editor.cursorVisible = true;
                editormousearea.enabled = ((editor.activeFocusOnPress || container.state == "hideKeyboard") && container.enableKeyboard);
            }
        }

        onCursorPositionChanged: {
            editormousearea.enabled = ((editor.activeFocusOnPress || container.state == "hideKeyboard") && container.enableKeyboard);
            container.cursorPos = editor.cursorPosition;
            if(!editormousearea.enabled && !editor.activeFocusOnPress)
            {
                container.showKeyboard();
            }
        }

        onTextChanged: {
            editormousearea.enabled = ((editor.activeFocusOnPress || container.state == "hideKeyboard") && container.enableKeyboard);
            // edit by keyboard
	    if (!editormousearea.enabled && !editor.activeFocusOnPress)
            {
                editor.cursorPosition = container.cursorPos;
            }
            // nokia input has been activated
            else if(editormousearea.enabled && editor.activeFocusOnPress)
            {
                // close nokia input and input by keyboard
                // a bug here, open nokia input, user can not set curse to 0
                if(editor.cursorPosition == 0)
                {
                    editor.cursorPosition = container.cursorPos;
                }
                // change curse in nokia input
                else
                {
                    container.cursorPos = editor.cursorPosition;
                }
            }

            else if(container._inputString && !container.enableKeyboard)
            {
                editor.cursorPosition = container.cursorPos;
            }

            container._inputString = false;
            container.textValueChanged(editor.text);
            if(container.enableKeyboard)
            {
                keyboard.handleTextChanged(text);
            }
        }
    }

    Keyboard2 {
        id: keyboard
        y: container.enableKeyboard? application.height - container.absoluteY - keyboard.height : application.height - container.absoluteY
        z: 2

        onKeyClicked:
        {
            container.handleKeyEvent(keyStr);
        }

        onNokiaInputActivated:
        {
            container.activeNokiaInputMethod();
        }
    }

    states: State {
            name: "hideKeyboard"
            PropertyChanges { target: keyboard; y: application.height - container.absoluteY }
        }

    transitions: Transition {
            NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
    }

    Component.onCompleted: {
        editor.forceActiveFocus();
        container.enableKeyboard = languageIsEn;
        editor.activeFocusOnPress = !container.enableKeyboard;
        var posInBox = container.mapToItem(application, 0, 0);
        container.absoluteY = posInBox.y;
        keyboard.x = -posInBox.x;
    }
}
