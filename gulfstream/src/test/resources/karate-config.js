function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env ? karate.env : 'scratch';

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    edgeHost:'http://localhost:9701',
    edgeApiKey: 'eyJzIjoiQlBhb2ZORm5jSzY0NzdEdWJ4RGgiLCJ0IjoiZGlrdSIsInUiOiJkaWt1In0',
    // define global features
    variables: karate.read('classpath:global/variables.feature'),
    destroyData: karate.read('classpath:common/destroy-data.feature'),
    getModuleIdByName: karate.read('classpath:common/module.feature@getModuleIdByName'),
    enableModule: karate.read('classpath:common/module.feature@enableModule'),
    deleteModule: karate.read('classpath:common/module.feature@deleteModule'),
    resetConfiguration: karate.read('classpath:domain/mod-configuration/reusable/reset-configuration.feature'),
    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * max)
    },
    addVariables: function(a,b){
      return a + b;
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';
  config.env = env;

  if (env === 'scratch') {
    config.baseUrl = 'https://gulfstream-okapi.ci.folio.org/';
    config.admin = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
    config.edgeHost = 'https://edge-pmh-gulfstream.ci.folio.org';
    config.edgeApiKey = 'eyJzIjoiQlBhb2ZORm5jSzY0NzdEdWJ4RGgiLCJ0IjoiZGlrdSIsInUiOiJkaWt1In0"';
  }else if (env === 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-testing.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
    config.getModuleByIdPath = '_/proxy/modules';
  }

  config.runId = karate.properties['runId'] ? karate.properties['runId'] : config.random(10000);
  config.testTenant = 'oaipmh_test_tenant' +  config.runId
  karate.log('===RUNNING TESTS IN ENVIRONMENT===' + env);

  config.testUser = {tenant: config.testTenant, name: 'test-user', password: 'test', id: '00000000-1111-5555-9999-999999999991'}

  var params = JSON.parse(JSON.stringify(config.admin))
  params.baseUrl = config.baseUrl;
  var response = karate.callSingle('classpath:common/login.feature', params)
  config.adminToken = response.responseHeaders['x-okapi-token'][0]

  // karate.callSingle('classpath:global/add-okapi-permissions.feature', config)

  return config;
}
