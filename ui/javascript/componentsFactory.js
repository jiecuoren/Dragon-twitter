var componentsArray = null;

function initWithCapacity(maxLength)
{
    componentsArray = new Array(maxLength);
    for (var i = 0; i < maxLength; ++i)
    {
        componentsArray[i] = null;
    }
}

function getComponent(viewId, fileName)
{
    if (componentsArray[viewId] === null)
    {
        console.log("component " + fileName + " doesn't exist, create it!");
        componentsArray[viewId] = Qt.createComponent(fileName);
    }

    return componentsArray[viewId];
}
