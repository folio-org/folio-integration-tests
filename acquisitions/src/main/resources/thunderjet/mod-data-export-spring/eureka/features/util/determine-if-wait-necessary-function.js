function(timeZone){
    var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
    var TimeZone = Java.type('java.util.TimeZone');
    var String = Java.type('java.lang.String');
    var sdf = new SimpleDateFormat("ss");

    var date = new java.util.Date();
        sdf.setTimeZone(TimeZone.getTimeZone(String.valueOf(timeZone)));

    var seconds = sdf.format(date);

    if(seconds.compareTo("50")>0) {
        return 10000;
    }

    return 0;
}