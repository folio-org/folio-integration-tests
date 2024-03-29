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
    featuresPath: 'classpath:spitfire/mod-entities-links/features/',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant ? testTenant : 'testtenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    setSystemProperty: function (name, property) {
      java.lang.System.setProperty(name, property);
    },
    toLocalDateTime: function(date) {
      var Instant = Java.type("java.time.Instant");
      var LocalDateTime = Java.type("java.time.LocalDateTime");
      var ZoneId = Java.type("java.time.ZoneId");
      var instant = Instant.parse(date);
      return LocalDateTime.ofInstant(instant, ZoneId.of("UTC"));
    },
    fromLocalDateTime: function(date) {
      var Formatter = Java.type("java.time.format.DateTimeFormatter");
      var LocalDateTime = Java.type("java.time.LocalDateTime");
      var dtf = Formatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
      return dtf.format(date);
    },
    datePlusDays: function(dateString, days) {
      var date = toLocalDateTime(dateString);
      date = date.plusDays(days);
      return fromLocalDateTime(date);
    },
    datePlusSeconds: function(dateString, seconds) {
      var date = toLocalDateTime(dateString);
      date = date.plusSeconds(seconds);
      return fromLocalDateTime(date);
    },
    sleep: function(seconds) {
      java.lang.Thread.sleep(seconds * 1000);
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
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}
