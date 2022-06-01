function fn(s) {
    var SimpleDateFormat = Java.type("java.text.SimpleDateFormat");
    var sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    try {
        sdf.parse(s).time;
        return true;
    } catch(e) {
        karate.log('*** invalid date string:', s);
        return false;
    }
}