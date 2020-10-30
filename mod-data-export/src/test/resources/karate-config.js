function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    destroyData: karate.read('classpath:common/destroy-data.feature'),
    getModuleIdByName: karate.read('classpath:common/module.feature@getModuleIdByName'),
    enableModule: karate.read('classpath:common/module.feature@enableModule'),
    deleteModule: karate.read('classpath:common/module.feature@deleteModule'),
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

  if (env === 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  }

  config.runId = karate.properties['runId'] ? karate.properties['runId'] : config.random(10000);
  config.testTenant = 'data_export_test_tenant' +  config.runId
  karate.log('===RUNNING TESTS IN ENVIRONMENT===' + env);
  karate.log('===TENANT===' + config.testTenant);

  config.testUser = {tenant: config.testTenant, name: 'test-user', password: 'test', id: '00000000-1111-5555-9999-999999999991'}

  var params = JSON.parse(JSON.stringify(config.admin))
  params.baseUrl = config.baseUrl;
  var response = karate.callSingle('classpath:common/login.feature', params)
  config.adminToken = response.responseHeaders['x-okapi-token'][0]

  return config;
}
