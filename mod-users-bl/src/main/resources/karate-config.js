function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'] || 'testtenant';
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:8000',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: testTenant,
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
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

  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'rancher-2') {
    config.baseUrl = 'https://folio-edev-volaris-2nd-kong.ci.folio.org/';
    config.baseKeycloakUrl = 'https://folio-edev-volaris-2nd-keycloak.ci.folio.org/';
  } else if (env == 'snapshot') {
      config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
      config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
      config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
      config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
  }

  return config;
}
