function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  var testTenant = "testedgedcb";
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:8000',
    edgeUrl: 'http://localhost:1212',
    centralServerUrl: 'https://folio-dev-volaris-mock-server.ci.folio.org',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    tenantParams: {loadReferenceData: true},
    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: 'testedgedcb', name: 'dcbClient', password: 'password'},

    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    loginAdmin: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:volaris/mod-dcb/global/variables.feature'),

    globalPath: 'classpath:volaris/mod-dcb/global/',
    featuresPath: 'classpath:volaris/mod-dcb/features/',
    edgeFeaturesPath: 'classpath:volaris/edge-dcb/features/',

    // define global functions
        random_uuid: function () {
          return java.util.UUID.randomUUID() + ''
        },

        random: function (max) {
          return Math.floor(Math.random() * max)
        },

        randomMillis: function() {
          return java.lang.System.currentTimeMillis() + '';
        },

        getCurrentUtcDate: function() {
           return new Date().toISOString();
        },

        random_string: function() {
          var text = "";
          var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
          for (var i = 0; i < 5; i++)
            text += possible.charAt(Math.floor(Math.random() * possible.length));
          return text;
        },
        random_numbers: function() {
        return Math.floor(Math.random() * 1000000)
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
    config.apikey = 'eyJzIjoiWDhoYmM1THJDeSIsInQiOiJ0ZXN0ZWRnZWRjYiIsInUiOiJkY2JDbGllbnQifQ==';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiWDhoYmM1THJDeSIsInQiOiJ0ZXN0ZWRnZWRjYiIsInUiOiJkY2JDbGllbnQifQ==';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-volaris-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-volaris-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiWDhoYmM1THJDeSIsInQiOiJ0ZXN0ZWRnZWRjYiIsInUiOiJkY2JDbGllbnQifQ==';
    config.baseKeycloakUrl = 'https://folio-edev-volaris-keycloak.ci.folio.org';
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.apikey = 'eyJzIjoiWDhoYmM1THJDeSIsInQiOiJ0ZXN0ZWRnZWRjYiIsInUiOiJkY2JDbGllbnQifQ==';

    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  }
  return config;
}