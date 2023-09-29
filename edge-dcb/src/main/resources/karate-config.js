function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    edgeUrl: 'http://localhost:9703',
    centralServerUrl: 'https://folio-dev-volaris-mock-server.ci.folio.org',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

      login: karate.read('classpath:common/login.feature'),
      loginRegularUser: karate.read('classpath:common/login.feature'),
      loginAdmin: karate.read('classpath:common/login.feature'),
      dev: karate.read('classpath:common/dev.feature'),

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
    config.apikey = 'eyJzIjoiWHlwaEhYT28wWCIsInQiOiJkaWt1IiwidSI6ImRpa3VfYWRtaW4ifQ==';

    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.apikey = 'eyJzIjoiWHlwaEhYT28wWCIsInQiOiJkaWt1IiwidSI6ImRpa3VfYWRtaW4ifQ==';

    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-dev-volaris-okapi.ci.folio.org';
    config.edgeUrl = 'https://folio-dev-volaris-edge-dcb.ci.folio.org';
    config.apikey = 'eyJzIjoiWHlwaEhYT28wWCIsInQiOiJkaWt1IiwidSI6ImRpa3VfYWRtaW4ifQ==';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':9130';
    config.edgeUrl = 'http://' + env + ':8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}