function fn() {

  karate.configure('logPrettyRequest', true);
  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  // Get config values from system properties with defaults if not provided
  var config = {
    baseUrl: karate.properties['baseUrl'] || 'http://localhost:9130',
    admin: {
      tenant: karate.properties['admin.tenant'] || 'diku',
      name: karate.properties['admin.name'] || 'diku_admin',
      password: karate.properties['admin.password'] || 'admin'
    },
    prototypeTenant: karate.properties['prototypeTenant'] || 'diku',

    testTenant: testTenant ? testTenant : 'testtenant',
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
