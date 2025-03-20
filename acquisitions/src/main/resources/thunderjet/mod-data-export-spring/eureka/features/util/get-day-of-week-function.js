function(timeZone){
    var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
    var TimeZone = Java.type('java.util.TimeZone');
    var Locale = Java.type('java.util.Locale');
    var String = Java.type('java.lang.String');
    var StringBuffer = Java.type('java.lang.StringBuffer');
    var sdf = new SimpleDateFormat("EEEE", Locale.ENGLISH);

    var date = new java.util.Date();
        sdf.setTimeZone(TimeZone.getTimeZone(String.valueOf(timeZone)));

    return sdf.format(date).toString().toUpperCase();
}
