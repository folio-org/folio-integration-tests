function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant ="testoaipmh";
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:8000',
    edgeUrl: 'http://localhost:9701',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    apikey: 'eyJzIjoiVExodW1JV2JiTCIsInQiOiJ0ZXN0b2FpcG1oIiwidSI6InRlc3QtdXNlciJ9',
    testTenant: 'testoaipmh',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:global/variables.feature'),

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
    isoDate: function() {
      // var dtf = java.time.format.DateTimeFormatter.ISO_INSTANT;
      var dtf = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
      var date = java.time.LocalDateTime.now(java.time.ZoneOffset.UTC);
      return dtf.format(date);
    },

    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    }

  };

  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
    config.apikey = 'eyJzIjoiVExodW1JV2JiTCIsInQiOiJ0ZXN0b2FpcG1oIiwidSI6InRlc3QtdXNlciJ9';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
    config.apikey = 'eyJzIjoiVExodW1JV2JiTCIsInQiOiJ0ZXN0b2FpcG1oIiwidSI6InRlc3QtdXNlciJ9';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-firebird-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-firebird-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-firebird-keycloak.ci.folio.org';
    config.apikey = 'eyJzIjoiVExodW1JV2JiTCIsInQiOiJ0ZXN0b2FpcG1oIiwidSI6InRlc3QtdXNlciJ9';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
    karate.configure('ssl',true)
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}'
    config.apikey = 'eyJzIjoiVExodW1JV2JiTCIsInQiOiJ0ZXN0b2FpcG1oIiwidSI6InRlc3QtdXNlciJ9';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':8000';
    config.edgeUrl = 'http://' + env + ':8000';
    config.apikey = 'eyJzIjoiVExodW1JV2JiTCIsInQiOiJ0ZXN0b2FpcG1oIiwidSI6InRlc3QtdXNlciJ9';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}
