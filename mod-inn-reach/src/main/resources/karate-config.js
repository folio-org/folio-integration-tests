function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant']|| 'testtenant';
  var testTenantId = karate.properties['testTenantId'];
  var config = {
    baseUrl: 'http://localhost:9130',
    edgeUrl: 'http://localhost:8000',
    centralServerUrl: 'https://folio-dev-volaris-2nd-mockserver.ci.folio.org',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    tenantParams: {loadReferenceData: true},
    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    loginAdmin: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:volaris/mod-inn-reach/global/variables.feature'),

    globalPath: 'classpath:volaris/mod-inn-reach/global/',
    featuresPath: 'classpath:volaris/mod-inn-reach/features/',
    mocksPath: 'classpath:volaris/mod-inn-reach/mocks/',
    samplesPath: 'classpath:volaris/mod-inn-reach/samples/',

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
      var possible = "abcdefghijklmnopqrstuvwxyz";
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

  if (env == 'snapshot-2') {
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'snapshot') {
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'rancher') {
    config.edgeUrl = 'https://folio-edev-volaris-edge-inn-reach.ci.folio.org';
    config.baseUrl = 'https://folio-edev-volaris-kong.ci.folio.org/';
    config.baseKeycloakUrl = 'https://folio-edev-volaris-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.centralServerUrl = karate.get('centralServerUrl') || 'https://folio-etesting-karate-eureka-mockserver.ci.folio.org'
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  }
  return config;
}
