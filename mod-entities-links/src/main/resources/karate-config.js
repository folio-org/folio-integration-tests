function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:8000',
    featuresPath: 'classpath:spitfire/mod-entities-links/features/',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
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

  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.kcClientId = '${clientId}',
    config.kcClientSecret = '${clientSecret}'
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  }
  return config;
}
