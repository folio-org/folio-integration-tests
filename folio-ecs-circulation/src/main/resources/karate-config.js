function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  var testTenant = karate.properties['testTenant'];
  var resolvedTestTenant = testTenant || 'testtenant';
  var testTenantId = karate.properties['testTenantId'];
  var testAdminUsername = karate.properties['testAdminUsername'] || 'test-admin';
  var testAdminPassword = karate.properties['testAdminPassword'] || 'admin';
  var testUserUsername = karate.properties['testUserUsername'] || 'test-user';
  var testUserPassword = karate.properties['testUserPassword'] || 'test';

  var randomNumbers = karate.properties['randomNumbers'] || (function() { return java.util.UUID.randomUUID().toString().replace('-', '').substring(0, 10); })();
  var centralTenant = 'consortium' + randomNumbers;
  var collegeTenant = 'college' + randomNumbers;
  var universityTenant = 'university' + randomNumbers;

  var centralTenantId = karate.properties['centralTenantId'];
  var collegeTenantId = karate.properties['collegeTenantId'];
  var universityTenantId = karate.properties['universityTenantId'];
  var consortiumId = karate.properties['consortiumId'];

  var consortiaAdminUserId = karate.properties['consortiaAdminUserId'] || (function() { return java.util.UUID.randomUUID() + '' })();
  var universityUserId = karate.properties['universityUserId'] || (function() { return java.util.UUID.randomUUID() + '' })();
  var collegeUserId = karate.properties['collegeUserId'] || (function() { return java.util.UUID.randomUUID() + '' })();
  var universityUser1Id = universityUserId;

  var config = {
    baseUrl: 'http://localhost:8000',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: resolvedTestTenant,
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: resolvedTestTenant, name: testAdminUsername, password: testAdminPassword},
    testUser: {tenant: resolvedTestTenant, name: testUserUsername, password: testUserPassword},

    centralTenant: centralTenant,
    centralTenantId: centralTenantId ? centralTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    collegeTenant: collegeTenant,
    collegeTenantId: collegeTenantId ? collegeTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    universityTenant: universityTenant,
    universityTenantId: universityTenantId ? universityTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    randomNumbers: randomNumbers,
    consortiumId: consortiumId ? consortiumId : (function() { return java.util.UUID.randomUUID() + '' })(),

    consortiaAdminUserId: consortiaAdminUserId,
    universityUserId: universityUserId,
    collegeUserId: collegeUserId,

    consortiaAdmin: { id: consortiaAdminUserId, username: 'consortia_admin', password: 'consortia_admin_password', tenant: centralTenant },
    universityUser1: { id: universityUser1Id, username: 'university_user1', password: 'university_user1_password', tenant: universityTenant },
    collegeUser1: { id: collegeUserId, username: 'college_user1', password: 'college_user1_password', tenant: collegeTenant },

    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

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
    }
  };

  var rand = function(i) {
    karate.set("uuid"+i, function() {
      return java.util.UUID.randomUUID() + '';
    });
  }
  karate.repeat(100, rand);

  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-vega-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-vega-keycloak.ci.folio.org';
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
  } else if (env == 'dev') {
    config.checkDepsDuringModInstall = 'false';
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  }
  return config;
}
