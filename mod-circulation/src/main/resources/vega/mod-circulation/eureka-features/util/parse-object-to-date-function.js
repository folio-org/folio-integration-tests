function(object){
    return Java.type('java.time.ZonedDateTime').parse(Java.type('java.lang.String').valueOf(object))
}
