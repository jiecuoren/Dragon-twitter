import QtQuick 1.0
import "ViewManager.js" as DataStructure

Item {

    //animation type
    property int noAnimation: 0      //no animation effect

    property int fade: 1             //current view fade in, new view fade out

    property int slideLeft: 2        //current view and new view slide from right to left

    property int slideRight: 3       //current view and new view slide from left to right

    property int slideDown: 4        //current view's opacity reduced, new view slide from
                                     //top to bottom

    property int slideUp: 5          //current view slides from bottom to top, new view's
                                     //opacity change back to 1.0

    property int slidePopup: 6       //current view covered by new view, new view slide from
                                     //bottom to top

    property int slidePopdown: 7       //current view slide from top to bottom, new view's
                                       //opacity change back to 1

    //view deletion behaviour
    property int noDelete:  0
    property int deleteOnHide: 1
    property int deleteOnBack: 2
    property int deleteAnyway: 3

    //flag that indicates we are activating a view, or backing a view
    property bool bActivateView: true

    function activateViewById(viewId, animType)
    {
        if (isAnimationOngoing())
        {
            console.log("animation is ongoing, not allow to activate a new viwe");
            return;
        }

        var newView = getView(viewId, false);
        bActivateView = true;
        doAnimationEffect(DataStructure.currentView, newView, animType);
    }

    function activateView(view, animType)
    {
        if (isAnimationOngoing())
        {
            console.log("animation is ongoing, not allow to activate a new view");
            return;
        }

        bActivateView = true;
        doAnimationEffect(DataStructure.currentView, view, animType);
    }

    function back(animType)
    {
        if (isAnimationOngoing())
        {
            console.log("animation is ongoing, not allow to back a view");
            return;
        }

        if (DataStructure.viewStack.length === 0)
        {
            console.log("hi, there is no view in viewstack, where do you want to back?");
            return;
        }

        bActivateView = false;
        var newView = DataStructure.viewStack.pop();
        doAnimationEffect(DataStructure.currentView, newView, animType);
    }

    function getView(viewId, alwaysCreateNewView)
    {
        var newView = null;

        if (alwaysCreateNewView)
        {
            newView = application.createView(viewId);
            DataStructure.allviews.push(newView);
            return newView;
        }

        for (var i = DataStructure.allviews.length - 1; i >= 0; --i)
        {
            if (DataStructure.allviews[i].viewId == viewId)
            {
                console.log("view " + viewId + " exists, return saved instance");
                return DataStructure.allviews[i];
            }
        }

        console.log("view does not exist, create it");
        newView = application.createView(viewId);
        DataStructure.allviews.push(newView);
        return newView;
    }

    function viewExists(viewId)
    {
        console.log("function viewExists(viewId), viewId=" + viewId);
        for (var i = DataStructure.allviews.length - 1; i >= 0; --i)
        {
            if (DataStructure.allviews[i].viewId == viewId)
            {
                console.log("the view exists");
                return true;
            }
        }

        return false;
    }

    function currentView()
    {
        var cur = DataStructure.currentView;
        return cur;
    }

    //destroy a view, and remove the instance from allViews and viewStack
    function deleteView(view)
    {
        //remove the view from allviews and viewStack first
        for (var i = 0; i < DataStructure.allviews.length; ++i)
        {
            if (DataStructure.allviews[i] == view)
            {
                console.log("remove view from DataStructures.allviews[]");
                DataStructure.allviews.splice(i, 1);
                break;
            }
        }
        for (var j = 0; j < DataStructure.viewStack.length; ++j)
        {
            if (DataStructure.viewStack[j] == view)
            {
                console.log("remove view from DataStructures.viewStack[]");
                DataStructure.viewStack.splice(j, 1);
                break;
            }
        }
        view.destroy();
    }

    function isAnimationOngoing()
    {
        //remember to add new animation.running!!!!
        return (fadeAnimation.running ||
                slideLeftAnimation.running ||
                slideRightAnimation.running ||
                slideDownAnimation.running ||
                slideUpAnimation.running ||
                slidePopupAnimation.running ||
                slidePopdownAnimation.running);
    }

    function doAnimationEffect(oldView, newView, animType)
    {
        declarativeView.interactive = false
        newView.opacity = 1.0;

        switch (animType)
        {
        case noAnimation:
            if (oldView !== null)
            {
                console.log("oldView is not null");
                oldView.visible = false;
                oldView.handleDeactivation();
            }

            DataStructure.currentView = newView;
            newView.visible = true;
            newView.handleActivation();
            break;

        case fade:
            fadeAnimation.oldView = oldView;
            fadeAnimation.newView = newView;
            fadeAnimation.start();
            break;

        case slideLeft:
            slideLeftAnimation.oldView = oldView;
            slideLeftAnimation.newView = newView;
            slideLeftAnimation.start();
            break;

        case slideRight:
            slideRightAnimation.oldView = oldView;
            slideRightAnimation.newView = newView;
            slideRightAnimation.start();
            break;

        case slideDown:
            slideDownAnimation.oldView = oldView;
            slideDownAnimation.newView = newView;
            slideDownAnimation.start();
            break;

        case slideUp:
            slideUpAnimation.oldView = oldView;
            slideUpAnimation.newView = newView;
            slideUpAnimation.start();
            break;

        case slidePopup:
            slidePopupAnimation.oldView = oldView;
            slidePopupAnimation.newView = newView;
            slidePopupAnimation.start();
            break;

        case slidePopdown:
            slidePopdownAnimation.oldView = oldView;
            slidePopdownAnimation.newView = newView;
            slidePopdownAnimation.start();
            break;

        default:
            console.log("god, what animation type you have passed?");
            break;
        }
    }

    function postHandleView(view)
    {
        if (bActivateView && view.deleteBehaviour == deleteOnHide)
        {
            deleteView(view);
            return;
        }

        if (!bActivateView && view.deleteBehaviour == deleteOnBack)
        {
            deleteView(view);
            return;
        }

        if (view.deleteBehaviour == deleteAnyway)
        {
            deleteView(view);
            return;
        }

        //push the view to stack if we are activating a view
        if (bActivateView)
        {
            view.opacity = 0.0;  // to improve performance
            DataStructure.viewStack.push(view);
        }
    }

    SequentialAnimation {
        id: fadeAnimation
        running: false

        property Item oldView;
        property Item newView;

        //pre-animation process
        PropertyAction { target: fadeAnimation.newView; property: "opacity"; value: 0.3 }
        ScriptAction {
            script: fadeAnimation.oldView.handleDeactivation();
        }

        //real animation
        ParallelAnimation {
            PropertyAnimation {target: fadeAnimation.oldView; property: "opacity";
                from: 1.0; to: 0.0; duration: 1500 }

            PropertyAnimation {target: fadeAnimation.newView; property: "opacity"; to: 1.0;
                duration: 1500 }
        }

        //post-animation process
        ScriptAction {
            script: {
                fadeAnimation.newView.handleActivation();
                postHandleView(fadeAnimation.oldView);
                DataStructure.currentView = fadeAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }

    SequentialAnimation {
        id: slideLeftAnimation
        running: false

        property Item oldView;
        property Item newView;

        //pre-animation process
        PropertyAction { target: slideLeftAnimation.newView; property: "x";
                         value: application.width }
        ScriptAction {
            script: slideLeftAnimation.oldView.handleDeactivation();
        }

        //real animation
        ParallelAnimation {
            PropertyAnimation {target: slideLeftAnimation.oldView; property: "x"; from: 0.0;
                               to: -application.width; duration: 1000;
                               easing.type: Easing.OutExpo }

            PropertyAnimation {target: slideLeftAnimation.newView; property: "x"; to: 0.0;
                               duration: 1000; easing.type: Easing.OutExpo }
        }

        //post-animation process
        ScriptAction {
            script: {
                slideLeftAnimation.newView.handleActivation();
                postHandleView(slideLeftAnimation.oldView);
                DataStructure.currentView = slideLeftAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }

    SequentialAnimation {
        id: slideRightAnimation
        running: false

        property Item oldView;
        property Item newView;

        //pre-animation process
        PropertyAction { target: slideRightAnimation.newView; property: "x";
                         value: -application.width }
        ScriptAction {
            script: slideRightAnimation.oldView.handleDeactivation();
        }

        //real animation
        ParallelAnimation {
            PropertyAnimation {target: slideRightAnimation.oldView; property: "x"; from: 0.0;
                to: application.width; duration: 1000; easing.type: Easing.OutExpo}

            PropertyAnimation {target: slideRightAnimation.newView; property: "x"; to: 0.0;
                               duration: 1000; easing.type: Easing.OutExpo }
        }

        //post-animation process
        ScriptAction {
            script: {
                slideRightAnimation.newView.handleActivation();
                postHandleView(slideRightAnimation.oldView);
                DataStructure.currentView = slideRightAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }

    SequentialAnimation {
        id: slideDownAnimation
        running: false

        property Item oldView;
        property Item newView;

        //pre-animation process
        PropertyAction {target: slideDownAnimation.newView; property: "y";
                        value: -application.height}
        PropertyAction {target: slideDownAnimation.oldView; property: "opacity";
                        value: 0.5}
        ScriptAction {
            script: slideDownAnimation.oldView.handleDeactivation();
        }

        //real animation
        PropertyAnimation {target: slideDownAnimation.newView; property: "y"; to: 0.0;
            duration: 1000; easing.type: Easing.OutExpo}

        //post-animation process
        ScriptAction {
            script: {
                slideDownAnimation.newView.handleActivation();
                postHandleView(slideDownAnimation.oldView);
                DataStructure.currentView = slideDownAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }

    SequentialAnimation {
        id: slideUpAnimation
        running: false

        property Item oldView;
        property Item newView;

        //pre-animation process
        ScriptAction {
            script: slideUpAnimation.oldView.handleDeactivation();
        }

        //real animation
        PropertyAnimation {target: slideUpAnimation.oldView; property: "y";
                           to: -application.height;  duration: 1000;
                           easing.type: Easing.InBack}

        //post-animation process
        ScriptAction {
            script: {
                slideUpAnimation.newView.opacity = 1.0
                slideUpAnimation.newView.handleActivation();
                postHandleView(slideUpAnimation.oldView);
                DataStructure.currentView = slideUpAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }

    SequentialAnimation {
        id: slidePopupAnimation
        running: false

        property Item oldView;
        property Item newView;

        //pre-animation process
        PropertyAction { target: slidePopupAnimation.newView; property: "y";
                         value: application.height }
        PropertyAction { target: slidePopupAnimation.oldView; property: "z";
                         value: 0 }
        PropertyAction { target: slidePopupAnimation.newView; property: "z";
                         value: 1 }
        ScriptAction {
            script: slidePopupAnimation.oldView.handleDeactivation();
        }

        //real animation
        PropertyAnimation {target: slidePopupAnimation.newView; property: "y"; to: 0.0;
                           duration: 1500; easing.type: Easing.OutExpo }

        //post-animation process
        ScriptAction {
            script: {
                slidePopupAnimation.newView.handleActivation();
                postHandleView(slidePopupAnimation.oldView);
                DataStructure.currentView = slidePopupAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }

    SequentialAnimation {
        id: slidePopdownAnimation
        running: false

        property Item oldView;
        property Item newView;

        ScriptAction {
            script: slidePopdownAnimation.oldView.handleDeactivation();
        }

        //real animation
        PropertyAnimation {target: slidePopdownAnimation.oldView; property: "y"; to: application.height;
                           duration: 1500; easing.type: Easing.OutExpo }

        //post-animation process
        ScriptAction {
            script: {
                slidePopdownAnimation.newView.handleActivation();
                postHandleView(slidePopdownAnimation.oldView);
                DataStructure.currentView = slidePopdownAnimation.newView;
                declarativeView.interactive = true
            }
        }
    }
}
