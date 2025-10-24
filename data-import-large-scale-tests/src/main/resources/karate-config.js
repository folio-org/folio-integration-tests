function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = {count: 20, interval: 30000}
  karate.configure('retry', retryConfig)

  var env = karate.env;
  console.log('karate.env system property is set to:', env);
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

  if (env === null || env === 'etesting-lsdi') {
    config.baseUrl = 'https://folio-etesting-lsdi-kong.ci.folio.org';
    //config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
    config.testUser = {tenant: 'consortium', name: 'consortium_admin', password: 'admin'};
  } else if (env === 'folio-tmp-test') {
      config.baseUrl = 'https://folio-tmp-test-kong.ci.folio.org';
      config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if (env === 'etesting-sprint') {
    config.baseUrl = 'https://folio-etesting-sprint-kong.ci.folio.org';
    config.testUser = {tenant: 'fs09000000', name: 'folio', password: 'folio'};
  } else if (env === 'edev-folijet') {
    config.baseUrl = 'https://folio-edev-folijet-kong.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  }

  return config;
}

