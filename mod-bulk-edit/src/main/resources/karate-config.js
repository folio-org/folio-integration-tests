function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 3, interval: 5000 }
  karate.configure('retry', retryConfig)

  var env = 'snapshot';
  var testTenant = karate.properties['testTenant'];

  var config = {
    tenantParams: {
        loadReferenceData : true
    },
    // define global variables
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    usersDataOriginal: read('classpath:samples/user/user-data-original.json'),

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    loadVariables: karate.read('classpath:global/variables.feature'),
    rollBackUsersData: karate.read('classpath:global/util/rall-back-users.feature@RollBackUsersData'),
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

  if (env === 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.admin = {tenant: diku, name: 'testing_admin', password: 'admin'};
    // config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    // config.admin = {tenant: testTenant, name: 'testing_admin', password: 'admin'};
  } else if (env != null && env.match(/^ec2-\d+/)) {
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  }

   // var params = JSON.parse(JSON.stringify(config.admin))
   // params.baseUrl = config.baseUrl;
   // var response = karate.callSingle('classpath:common/login.feature', params)
   // config.adminToken = response.responseHeaders['x-okapi-token'][0]

//   uncomment to run on local
//   karate.callSingle('classpath:global/add-okapi-permissions.feature', config);

  return config;
}