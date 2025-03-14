function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env ? karate.env : 'rancher';

    // The "testTenant" property could be specified during test runs
    var testTenant = karate.properties['testTenant'];
    var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:9130',
    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',
    edgeHost:'http://localhost:9701',
    edgeApiKey: 'eyJzIjoiQlBhb2ZORm5jSzY0NzdEdWJ4RGgiLCJ0IjoiZGlrdSIsInUiOiJkaWt1In0',
    // define global features
    variables: karate.read('classpath:global/variables.feature'),
    destroyData: karate.read('classpath:common/destroy-data.feature'),
    getModuleIdByName: karate.read('classpath:global/module-operations.feature@getModuleIdByName'),
    enableModule: karate.read('classpath:global/module-operations.feature@enableModule'),
    deleteModule: karate.read('classpath:global/module-operations.feature@deleteModule'),
    resetConfiguration: karate.read('classpath:firebird/mod-configuration/reusable/reset-configuration.feature'),
    login: karate.read('classpath:common/eureka/login.feature'),
    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * max)
    },
    addVariables: function(a,b){
      return a + b;
    },
    base64Decode: function(string) {
    var Base64 = Java.type('java.util.Base64');
    var decoded = Base64.getDecoder().decode(string);
    var String = Java.type('java.lang.String');
    return new String(decoded);
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';
  config.env = env;

  if (env == 'rancher') {
    config.baseUrl = 'https://folio-dev-firebird-okapi.ci.folio.org';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
    karate.configure('ssl',true)
  }else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot-2.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
  } else if (env == 'eureka') {
    config.baseUrl = 'https://folio-edev-dojo-kong.ci.folio.org:443';
    config.baseKeycloakUrl = 'https://folio-edev-dojo-keycloak.ci.folio.org:443';
    config.clientSecret = karate.properties['clientSecret'];
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeHost = '${edgeUrl}';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
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
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
    config.getModuleByIdPath = '_/proxy/modules';
  }

  config.runId = karate.properties['runId'] ? karate.properties['runId'] : config.random(10000);
  config.testTenant = 'oaipmhtesttenant' +  config.runId
  karate.log('===RUNNING TESTS IN ENVIRONMENT===' + env);
  karate.log('===TENANT===' + config.testTenant);


  config.testUser = {tenant: config.testTenant, name: 'test-user', password: 'test', id: '00000000-1111-5555-9999-999999999991'}

  var params = JSON.parse(JSON.stringify(config.admin))
  params.baseUrl = config.baseUrl;

  return config;
}
