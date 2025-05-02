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
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    tenantParams: {loadReferenceData : true},
    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: 'testfqmtenant', name: 'testFqmUser', password: 'test'},

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

    pause: function(millis) {
          var Thread = Java.type('java.lang.Thread');
          Thread.sleep(millis);
    }
  };

  // Create 100 functions for uuid generation
  var rand = function(i) {
    karate.set("uuid"+i, function() {
      return java.util.UUID.randomUUID() + '';
    });
  }
  karate.repeat(100, rand);

  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJ0ZXN0ZnFtdGVuYW50IiwidSI6InRlc3RGcW1Vc2VyIn0='
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJ0ZXN0ZnFtdGVuYW50IiwidSI6InRlc3RGcW1Vc2VyIn0='
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJ0ZXN0ZnFtdGVuYW50IiwidSI6InRlc3RGcW1Vc2VyIn0='
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);

    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-corsair-kong.ci.folio.org:443';
    config.edgeUrl = 'https://folio-edev-corsair-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJ0ZXN0ZnFtdGVuYW50IiwidSI6InRlc3RGcW1Vc2VyIn0='
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    };
    config.prototypeTenant = 'diku';

    config.baseKeycloakUrl = 'https://folio-edev-corsair-keycloak.ci.folio.org';
  }
  return config;
}
