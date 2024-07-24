function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  // generate names for consortia tenants
  var randomNumbers = karate.properties['randomNumbers'] ? karate.properties['randomNumbers'] : '1234567890';

  var centralTenant = 'central' + randomNumbers;
  var universityTenant = 'university' + randomNumbers;
  var collegeTenant = 'college' + randomNumbers;

  var consortiaAdminUserId = karate.properties['consortiaAdminUserId'];
  var centralUser1Id = karate.properties['centralUserId'];
  var universityUser1Id = karate.properties['universityUserId'];
  var collegeUser1Id = karate.properties['collegeUserId'];

  // define consortiumId
  var consortiumId = karate.properties['consortiumId'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    tenantParams: {loadReferenceData : true},
    testTenant: testTenant ? testTenant : 'testtenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define consortia users and tenants
    centralTenant: centralTenant,
    universityTenant: universityTenant,
    collegeTenant: collegeTenant,
    consortiumId: consortiumId,

    consortiaAdmin: { id: consortiaAdminUserId, username: 'consortia_admin', password: 'consortia_admin_password', tenant: centralTenant},
    centralUser1: { id: centralUser1Id, username: 'central_user1', password: 'central_user1_password', tenant: centralTenant},
    universityUser1: { id: universityUser1Id, username: 'university_user1', password: 'university_user1_password', tenant: universityTenant},
    collegeUser1: { id: collegeUser1Id, username: 'college_user1', password: 'college_user1_password', tenant: collegeTenant},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    random: function (max) {
      return Math.floor(Math.random() * max)
    },

    randomMillis: function() {
      return java.lang.System.currentTimeMillis() + '';
    },

    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },

    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    }
  };

  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
     config.baseUrl = 'https://folio-dev-folijet-okapi.ci.folio.org';
     config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
     config.prototypeTenant= 'consortium'
     config.admin = {
       tenant: 'consortium',
       name: 'consortium_admin',
       password: 'admin'
     }
    } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
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
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }

//   uncomment to run on local
//  karate.callSingle('classpath:common/add-okapi-permissions.feature', config);
  return config;
}
