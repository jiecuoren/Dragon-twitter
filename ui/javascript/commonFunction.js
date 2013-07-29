
// public function
// format time
function getTimeInterval( createdDate )
{
    var currentDate = new Date();
    var seconds = ( currentDate.getTime() - createdDate.getTime() ) / 1000;
    var oneMinute = 60;
    var oneHour = 60*oneMinute;
    var oneDay = 24*oneHour;
    var month = currentDate.getMonth() - createdDate.getMonth();
    var year = currentDate.getFullYear() - createdDate.getFullYear();

    var str = "";

    if (year > 0)
    {
        str = Qt.formatDateTime(createdDate,"yyyy-MM-dd")
    }
    else if (month > 0 &&  month < 12)
    {
        str = Qt.formatDateTime(createdDate,"MM-dd")
    }
    else
    {
        //within same month
        var days = Math.floor(seconds / oneDay);
        if (days > 0)
        {
            str = (days == 1) ? "1 day" : String(days) + " days";
        }
        else
        {
            //within one day
            var hours = Math.floor(seconds / oneHour);
            if (hours > 0)
            {
                str = (hours == 1) ? "1 hour" : String(hours) + " hours";
            }
            else
            {
                //within one hour
                var mins = Math.floor(seconds / oneMinute);
                if (mins > 0)
                {
                    str = (mins == 1) ? "1 min" : String(mins) + " mins";
                }
                else
                {
                    //within one minute
                    str = (Math.floor(seconds) == 1) ? "1 sec" : String(Math.floor(seconds)) + " secs";
                }
            }
        }
    }

    return str;
}

function extractFormatedTime( timeStr )
{
    var monthDay = timeStr.slice(4,10);
    var year = timeStr.slice(timeStr.length-4, timeStr.length);
    return monthDay + ", " + year;
}

function formatDatetime(timeStr)
{
    var result = Qt.formatDateTime(new Date(timeStr), "MM/dd/yy h:mm AP");
    return result;
}

function convert(str)
{
    str = str.replace(/&amp;/g, "&");
    str = str.replace(/&gt;/g, ">");
    str = str.replace(/&lt;/g, "<");
    str = str.replace(/&quot;/g, "\"");
    str = str.replace(/&#039;/g, "\'");
    return str;
}
