function () {
  var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
  var sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
  var date = new java.util.Date();
  return sdf.format(date);
}
