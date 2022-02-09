function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    loginAdmin: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:global/variables.feature'),

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

    isoDate: function() {
      // var dtf = java.time.format.DateTimeFormatter.ISO_INSTANT;
      var dtf = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
      var date = java.time.LocalDateTime.now(java.time.ZoneOffset.UTC);
      return dtf.format(date);
    },

    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis * 1000);
    }
  };

  if (env == 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-testing.dev.folio.org:8000';
    config.apikey = 'eyJzIjoidlphbUR3TnNYVmhqdVptSjIza2ciLCJ0IjoidGVzdFRlbmFudCIsInUiOiJ0ZXN0LWFkbWluIn0=';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.apikey = 'eyJzIjoidlphbUR3TnNYVmhqdVptSjIza2ciLCJ0IjoidGVzdFRlbmFudCIsInUiOiJ0ZXN0LWFkbWluIn0=';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name, the testing endpoint is used via user creation approach of caiasoft user
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-testing.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiY2FpYVNvZnRDbGllbnQiLCJ0IjoiZGlrdSIsInUiOiJjYWlhU29mdENsaWVudCJ9';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}
