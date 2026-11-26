function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = {count: 20, interval: 30000}
  karate.configure('retry', retryConfig)

  var env = karate.env;
  var testTenant = karate.properties['testTenant'] || 'testtenant';
  var testTenantId = karate.properties['testTenantId'];
  var testAdminUsername = karate.properties['testAdminUsername'] || 'test-admin';
  var testAdminPassword = karate.properties['testAdminPassword'] || 'admin';
  var testUserUsername = karate.properties['testUserUsername'] || 'test-user';
  var testUserPassword = karate.properties['testUserPassword'] || 'test';
  var testUser2Username = karate.properties['testUser2Username'] || 'test-user2';
  var testUser2Password = karate.properties['testUser2Password'] || 'test2';

  // generate names for consortia tenants
  var randomNumbers = karate.properties['randomNumbers'] ? karate.properties['randomNumbers'] : '1234567890';

  var centralTenant = 'central' + randomNumbers;
  var centralTenantId = karate.properties['centralTenantId'];
  var universityTenant = 'university' + randomNumbers;
  var universityTenantId = karate.properties['universityTenantId'];
  var collegeTenant = 'college' + randomNumbers;
  var collegeTenantId = karate.properties['collegeTenantId'];

  var consortiaAdminUserId = karate.properties['consortiaAdminUserId'];
  var centralUser1Id = karate.properties['centralUserId'];
  var universityUser1Id = karate.properties['universityUserId'];
  var collegeUser1Id = karate.properties['collegeUserId'];

  // define consortiumId
  var consortiumId = karate.properties['consortiumId'];

  var generatePassword = karate.callSingle('classpath:common/util/generate-password.feature').generatePassword;

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

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: testTenant,
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: testAdminUsername, password: testAdminPassword},
    testUser: {tenant: testTenant, name: testUserUsername, password: testUserPassword},
    testUser2: {tenant: testTenant, name: testUser2Username, password: testUser2Password},

    // define consortia users and tenants
    centralTenant: centralTenant,
    centralTenantId: centralTenantId ? centralTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    universityTenant: universityTenant,
    universityTenantId: universityTenantId ? universityTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    collegeTenant: collegeTenant,
    collegeTenantId: collegeTenantId ? collegeTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    consortiumId: consortiumId,

    consortiaAdmin: { id: consortiaAdminUserId, username: 'consortia_admin', password: generatePassword('consortia_admin'), tenant: centralTenant},
    centralUser1: { id: centralUser1Id, username: 'central_user1', password: generatePassword('central_user1'), tenant: centralTenant},
    universityUser1: { id: universityUser1Id, username: 'university_user1', password: generatePassword('university_user1'), tenant: universityTenant},
    collegeUser1: { id: collegeUser1Id, username: 'college_user1', password: generatePassword('college_user1'), tenant: collegeTenant},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    createAdditionalUser: karate.read('classpath:common/eureka/create-additional-user.feature'),

    epoch: epoch,

    // define global functions
    setSystemProperty: function (name, property) {
      java.lang.System.setProperty(name, property);
    },
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * 100)
    },
    addVariables: function (a, b) {
      return a + b;
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
    },
    orWhereQuery: function(field, values) {
      var orStr = ' or ';
      var string = '(' + field + '=(' + values.map(x => '"' + x + '"').join(orStr) + '))';

      return string;
    },
    containsDuplicatesOfFields: function(array, fields) {
      let keys = [];
      let result = false;
      karate.forEach(array, function(x){keys.push(Object.keys(x))});

      fields.forEach(field => {
        let count = 0;
        keys.forEach(key => {
          if (key == field) {
            if (count > 0) {
              result = true;
              return;
            }
            count++;
          }
        })
      })
      return result;
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

  if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.kcClientId = '${clientId}',
    config.kcClientSecret = '${clientSecret}'
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-promin-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-promin-keycloak.ci.folio.org';
    config.prototypeTenant = 'consortium';
    config.admin = {tenant: 'consortium', name: 'consortium_admin', password: 'admin'};
  } else if (env === 'edev-promin') {
    config.baseUrl = 'https://folio-edev-promin-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-promin-keycloak.ci.folio.org';
    config.testUser = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
  } else if (env == 'dev') {
    config.checkDepsDuringModInstall = 'false';
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  }
  return config;
}

