function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant']|| 'testtenant';
  var testTenantId = karate.properties['testTenantId'];
  var testAdminUsername = karate.properties['testAdminUsername'] || 'test-admin';
  var testUserUsername = karate.properties['testUserUsername'] || 'test-user';

  var generatePassword = karate.callSingle('classpath:common/util/generate-password.feature').generatePassword;

  var config = {
    generatePassword: generatePassword,
    baseUrl: 'http://localhost:8000',
    edgeUrl: 'http://localhost:9703',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: testTenant,
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: testAdminUsername, password: generatePassword(testAdminUsername)},
    testUser: {tenant: testTenant, name: testUserUsername, password: generatePassword(testUserUsername)},

      login: karate.read('classpath:common/login.feature'),
      loginRegularUser: karate.read('classpath:common/login.feature'),
      loginAdmin: karate.read('classpath:common/login.feature'),
      dev: karate.read('classpath:common/dev.feature'),
      variables: karate.read('classpath:vega/mod-dcb/global/variables.feature'),

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
    getCurrentYear: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy');
      var date = new java.util.Date();
      return sdf.format(date);
    },
    getCurrentDate: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy-MM-dd');
      var date = new java.util.Date();
      return sdf.format(date);
    },

    getYesterday: function() {
      var LocalDate = Java.type('java.time.LocalDate');
      var localDate = LocalDate.now().minusDays(1);
      var formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
      var formattedString = localDate.format(formatter);
      return localDate.format(formatter);
    },

    getCurrentUtcDate: function() {
       return new Date().toISOString();
    },

    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    }
  };

  // Create 100 functions for uuid generation
  var rand = function(i) {
    karate.set("uuid"+i, function() {
      return java.util.UUID.randomUUID() + '';
    });
  }
  karate.repeat(100, rand);

  if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-vega-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-vega-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-vega-edge.ci.folio.org';
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
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
    config.baseUrl = 'https://folio-edev-vega-2nd-kong.ci.folio.org:443';
    config.baseKeycloakUrl = 'https://folio-edev-vega-2nd-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-vega-2nd-edge.ci.folio.org';
    config.kcClientId = 'folio-backend-admin-client';
    config.kcClientSecret = karate.properties['clientSecret'] || 'SecretPassword';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  }

  return config;
}
