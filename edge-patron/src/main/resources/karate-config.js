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
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

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
    },

    orWhereQuery: function(field, values) {
      var orStr = ' or ';
      var string = '(' + field + '=(' + values.map(x => '"' + x + '"').join(orStr) + '))';

      return string;
    }
  };
  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if(env == 'eureka') {
    config.baseUrl = 'https://folio-edev-dojo-kong.ci.folio.org:443';
    config.baseKeycloakUrl = 'https://folio-edev-dojo-keycloak.ci.folio.org:443';
    config.clientSecret = karate.properties['clientSecret'];
    config.edgeUrl = 'https://folio-edev-dojo-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // edge modules cannot run properly on dedicated environment for the Karate tests
    // short term solution is to have the module run on testing
    // This is not ideal as it negates a lot of the purpose of the tests
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-dev-volaris-okapi.ci.folio.org';
    config.edgeUrl = 'https://folio-dev-volaris-edge.ci.folio.org';
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.admin = {
     tenant: 'diku',
     name: 'diku_admin',
     password: 'admin'
    }
  }
  return config;
}
