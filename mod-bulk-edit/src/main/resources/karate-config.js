function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 3, interval: 5000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;
  var testTenant = karate.properties['testTenant'];

  var config = {
    tenantParams: {
        loadReferenceData : true
    },
    // define global variables
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin-unique', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user-unique', password: 'test'},

    usersDataOriginal: read('classpath:samples/user/user-data-original.json'),

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    loadVariables: karate.read('classpath:global/variables.feature'),
    rollBackUsersData: karate.read('classpath:global/util/rall-back-users.feature@RollBackUsersData'),

    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

  if (env === 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'}
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'}
  } else if (env != null && env.match(/^ec2-\d+/)) {
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  }

//   uncomment to run on local
//   karate.callSingle('classpath:global/add-okapi-permissions.feature', config);

  return config;
}