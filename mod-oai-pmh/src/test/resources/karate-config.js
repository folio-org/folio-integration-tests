function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env ? karate.env : 'rancher';

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
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},
    edgeHost:'http://localhost:9701',
    edgeApiKey: 'eyJzIjoiQlBhb2ZORm5jSzY0NzdEdWJ4RGgiLCJ0IjoiZGlrdSIsInUiOiJkaWt1In0',
    // define global features
    variables: karate.read('classpath:global/variables.feature'),
    destroyData: karate.read('classpath:common/destroy-data.feature'),
    getModuleIdByName: karate.read('classpath:global/module-operations.feature@getModuleIdByName'),
    enableModule: karate.read('classpath:global/module-operations.feature@enableModule'),
    deleteModule: karate.read('classpath:global/module-operations.feature@deleteModule'),
    resetConfiguration: karate.read('classpath:firebird/mod-configuration/reusable/reset-configuration.feature'),
    login: karate.read('classpath:common/login.feature'),
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

  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-firebird-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-firebird-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-firebird-keycloak.ci.folio.org';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
    karate.configure('ssl',true)
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules'
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
  } else if (env == 'folio-testing-karate') {
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
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':8000';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
    config.getModuleByIdPath = '_/proxy/modules';
  }

  return config;
}
