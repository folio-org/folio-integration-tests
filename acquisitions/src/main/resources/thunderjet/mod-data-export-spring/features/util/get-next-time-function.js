function(timeZone, delay){
    var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
    var TimeZone = Java.type('java.util.TimeZone');
    var Calendar = Java.type('java.util.Calendar');
    var String = Java.type('java.lang.String');
    var sdf = new SimpleDateFormat("HH:mm:00");

    var date = new java.util.Date();

    var calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.add(Calendar.MINUTE, delay);
        date = calendar.getTime();
        sdf.setTimeZone(TimeZone.getTimeZone(String.valueOf(timeZone)));

    return sdf.format(date);
}