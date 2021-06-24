function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
  };

  if (env == 'testing') {
      config.baseUrl = 'https://folio-testing-okapi.dev.folio.org:443';
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
