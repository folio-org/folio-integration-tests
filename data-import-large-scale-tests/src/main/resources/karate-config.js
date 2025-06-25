function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = {count: 20, interval: 30000}
  karate.configure('retry', retryConfig)

  var env = karate.env;
  var testTenant = karate.properties['testTenant'] || 'testtenant';
  var testAdminUsername = karate.properties['testAdminUsername'] || 'test-admin';
  var testAdminPassword = karate.properties['testAdminPassword'] || 'admin';
  var testUserUsername = karate.properties['testUserUsername'] || 'test-user';
  var testUserPassword = karate.properties['testUserPassword'] || 'test';

  var epoch = (()=> {
    // Get the current date and time
    let now = new Date();

    // Extract year, month, day, hour, and minute
    let year = now.getFullYear();
    let month = String(now.getMonth() + 1).padStart(2, '0');
    let day = String(now.getDate()).padStart(2, '0');
    let hour = String(now.getHours()).padStart(2, '0');
    let minute = String(now.getMinutes()).padStart(2, '0');
    let seconds = String(now.getSeconds()).padStart(2, '0');

    // Format the date and time into a string
    return [year,month,day,hour,minute,seconds].join('');
  })()

  var config = {
    tenantParams: {loadReferenceData: true},
    baseUrl: 'http://localhost:8000',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant,
    testAdmin: {tenant: testTenant, name: testAdminUsername, password: testAdminPassword},
    testUser: {tenant: testTenant, name: testUserUsername, password: testUserPassword},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    epoch: epoch,

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * 100)
    },
    pause: function (millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    },
    randomString: function(length) {
      var result = '';
      var characters = 'abcdefghijklmnopqrstuvwxyz';
      var charactersLength = characters.length;
      for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
      }
      return result;
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

  if (env === 'etesting-lsdi') {
    config.baseUrl = 'https://folio-etesting-lsdi-kong.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if (env === 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if (env === 'etesting-sprint') {
    config.baseUrl = 'https://folio-etesting-sprint-kong.ci.folio.org';
    config.testUser = {tenant: 'fs09000000', name: 'folio', password: 'folio'};
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot.dev.folio.org:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
  } else if (env === 'rancher') {
    config.baseUrl = 'https://folio-dev-folijet-okapi.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if (env === 'folijet-perf') {
    config.baseUrl = 'https://folio-perf-folijet-okapi.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if(env === 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.admin = {tenant: '${admin.tenant}', name: '${admin.name}', password: '${admin.password}'}
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl', true);
  } else if (env === 'edev') {
    config.baseUrl = 'https://folio-edev-folijet-kong.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if(env === 'dev') {
    config.checkDepsDuringModInstall = 'false';
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env?.match(/^ec2-\d+/)) {
    config.baseUrl = 'http://' + env + ':8000';
    config.testUser = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  }

  return config;
}

