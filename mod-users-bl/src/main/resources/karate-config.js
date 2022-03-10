function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    // The tenant property of testUser is required by destroy-data.feature
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    random: function (max) {
      return Math.floor(Math.random() * max)
    },

    randomMillis: function() {
      return java.lang.System.currentTimeMillis() + '';
    },

    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },

    base64Decode: function(string) {
      var Base64 = Java.type('java.util.Base64');
      var decoded = Base64.getDecoder().decode(string);
      var String = Java.type('java.lang.String');
      return new String(decoded);
    },

    getPasswordResetExpiration: function() {
      var hour = 3600 * 1000;
      //var hour = 0;
      var now = new java.util.Date().getTime();
      var nowWithOffset = new java.util.Date(now + hour);
      var df = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS+00:00");
      df.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
      return df.format(nowWithOffset);
    },

    random_uuid: function() {
      return java.util.UUID.randomUUID();
    }
  };

  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  } else if (env == 'localhost') {
   // Running tests against the testing backend vagrant box requires these credentials.
   config.baseUrl = 'http://localhost:9130';
   config.admin = {
   tenant: 'diku',
   name: 'testing_admin',
   password: 'admin'
  }
 }

  return config;
}
