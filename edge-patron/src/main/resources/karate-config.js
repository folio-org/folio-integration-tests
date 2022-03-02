function fn() {

  karate.configure('logPrettyRequest', true);
  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)
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
  if (env == 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-testing.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // edge modules cannot run properly on dedicated environment for the Karate tests
    // short term solution is to have the module run on testing
    // This is not ideal as it negates a lot of the purpose of the tests
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-testing.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  }
  return config;
}
