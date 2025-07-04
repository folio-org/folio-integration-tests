function fn() {

  karate.configure('logPrettyRequest', true);
  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)
  karate.configure('logPrettyResponse', true);

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

    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: 'ttttpatron', name: 'testpatron', password: 'password'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),

    // define global functions
    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 8; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },
    //to generate random barcode
    random_numbers: function() {
      return Math.floor(Math.random() * 1000000);
    },
    random_uuid: function() {
      return java.util.UUID.randomUUID() + '';
    }
  };
  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'snapshot-2') {
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'snapshot') {
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}'
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  } else if (env == 'rancher') {
    config.edgeUrl = 'https://folio-edev-vega-edge-inn-reach.ci.folio.org';
    config.baseUrl = 'https://folio-edev-vega-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-vega-keycloak.ci.folio.org';
  }
  return config;
}
