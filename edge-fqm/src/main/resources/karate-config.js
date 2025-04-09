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
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

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

  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org:8000';
    // API key for diku tenant, diku_admin user
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJkaWt1IiwidSI6ImRpa3VfYWRtaW4ifQ==';
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    // API key for diku tenant, diku_admin user
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJkaWt1IiwidSI6ImRpa3VfYWRtaW4ifQ==';
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJ0ZXN0ZnFtdGVuYW50IiwidSI6InRlc3RGcW1Vc2VyIn0=';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    };
    config.prototypeTenant = '${prototypeTenant}';
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
    karate.configure('ssl',true);
  } else if (env == 'eureka') {
    config.edgeUrl = 'https://folio-edev-dojo-edge.ci.folio.org'
    config.apikey = 'eyJzIjoiZlU4ZDNkc0pKTCIsInQiOiJ0ZXN0ZnFtdGVuYW50IiwidSI6InRlc3RGcW1Vc2VyIn0='
    config.baseUrl = 'https://folio-edev-dojo-kong.ci.folio.org:443'
    config.baseKeycloakUrl = 'https://folio-edev-dojo-keycloak.ci.folio.org:443';
    config.clientSecret = karate.properties['clientSecret'];
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-perf-corsair-okapi.ci.folio.org:443';
    config.admin = {
      tenant: 'fs09000000',
      name: 'admin',
      password: 'bugfest09'
    };
    config.edgeUrl = 'https://folio-perf-corsair-edge.ci.folio.org';
    config.apikey = 'eyJzIjoidGhMQ2Y5WFRVWERFUGxubXhDcGciLCJ0IjoiZnMwOTAwMDAwMCIsInUiOiJhZG1pbiJ9';
    config.prototypeTenant = 'fs09000000';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':9130';
    config.edgeUrl = 'http://' + env + ':8000';
    config.apikey = 'eyJzIjoibTE2M0k2NTRHZ1pWOVBMdnRTa1MiLCJ0IjoiZGlrdSIsInUiOiJkaWt1X2FkbWluIn0K';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  }
  return config;
}
