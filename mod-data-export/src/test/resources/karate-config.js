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
    variables: karate.read('classpath:global/variables.feature'),

    getJobExecutions: karate.read('classpath:domain/dataexport/features/get-job-execution.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * 100)
    },
    addVariables: function(a,b){
      return a + b;
    },
    pause: function() {
    var Thread = Java.type('java.lang.Thread');
    Thread.sleep(3000);
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

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
  // uncomment to run on local
  //karate.callSingle('classpath:global/add-okapi-permissions.feature', config)

  return config;
}
