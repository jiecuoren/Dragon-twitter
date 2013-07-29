import QtQuick 1.0
import QtWebKit 1.0

Flickable {
    id: flickable

    property alias progress: webView.progress
    property alias url: webView.url
    property alias back: webView.back
    property alias stop: webView.stop
    property alias reload: webView.reload
    property alias forward: webView.forward
    property alias title: webView.title

    signal loadStarted()
    signal loadFinished()

    clip: true
    contentWidth: Math.max(width, webView.width)
    contentHeight: Math.max(height, webView.height)
    pressDelay: 200

    onWidthChanged : {
        // Expand (but not above 1:1) if otherwise would be smaller that available width.
        if (width > webView.width*webView.contentsScale && webView.contentsScale < 1.0)
            webView.contentsScale = width / webView.width * webView.contentsScale;
    }

    WebView {
        id: webView
        transformOrigin: Item.TopLeft

        smooth: false // We don't want smooth scaling, since we only scale during (fast) transitions

        onAlert: console.log(message)

        function doZoom(zoom, centerX, centerY)
        {
            if (centerX) {
                var sc = zoom*contentsScale;
                scaleAnim.to = sc;
                flickVX.from = flickable.contentX
                flickVX.to = Math.max(0,Math.min(centerX-flickable.width/2,webView.width*sc-flickable.width))
                finalX.value = flickVX.to
                flickVY.from = flickable.contentY
                flickVY.to = Math.max(0,Math.min(centerY-flickable.height/2,webView.height*sc-flickable.height))
                finalY.value = flickVY.to
                quickZoom.start()
            }
        }

        preferredWidth: flickable.width
        preferredHeight: flickable.height
        contentsScale: 1

        onLoadStarted: {
            flickable.loadStarted();
        }

        onLoadFinished: {
            flickable.loadFinished();
        }

        onContentsSizeChanged: {
            // zoom out
            contentsScale = Math.min(1,flickable.width / contentsSize.width)
        }
        onUrlChanged: {
            // got to topleft
            flickable.contentX = 0
            flickable.contentY = 0
        }
        onDoubleClick: {
                        if (!heuristicZoom(clickX,clickY,2.5)) {
                            var zf = flickable.width / contentsSize.width
                            if (zf >= contentsScale)
                                zf = 2.0/zoomFactor // zoom in (else zooming out)
                            doZoom(zf,clickX*zf,clickY*zf)
                         }
                       }

        SequentialAnimation {
            id: quickZoom

            PropertyAction {
                target: webView
                property: "renderingEnabled"
                value: false
            }
            ParallelAnimation {
                NumberAnimation {
                    id: scaleAnim
                    target: webView
                    property: "contentsScale"
                    // the to property is set before calling
                    easing.type: Easing.Linear
                    duration: 200
                }
                NumberAnimation {
                    id: flickVX
                    target: flickable
                    property: "contentX"
                    easing.type: Easing.Linear
                    duration: 200
                    from: 0 // set before calling
                    to: 0 // set before calling
                }
                NumberAnimation {
                    id: flickVY
                    target: flickable
                    property: "contentY"
                    easing.type: Easing.Linear
                    duration: 200
                    from: 0 // set before calling
                    to: 0 // set before calling
                }
            }
            // Have to set the contentXY, since the above 2
            // size changes may have started a correction if
            // contentsScale < 1.0.
            PropertyAction {
                id: finalX
                target: flickable
                property: "contentX"
                value: 0 // set before calling
            }
            PropertyAction {
                id: finalY
                target: flickable
                property: "contentY"
                value: 0 // set before calling
            }
            PropertyAction {
                target: webView
                property: "renderingEnabled"
                value: true
            }
        }
        onZoomTo: doZoom(zoom,centerX,centerY)
    }
}
