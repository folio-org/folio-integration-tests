function fn() {

  karate.configure('logPrettyRequest', true);
  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:8000',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: 'ttttpatron', name: 'testpatron', password: 'password'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    variables: karate.read('classpath:global/variables.feature'),

    // consortia variables
    variablesCentral: karate.read('classpath:variables/variablesCentral.feature'),
    variablesUniversity: karate.read('classpath:variables/variablesUniversity.feature'),

    // inventory
    createItem: karate.read('classpath:reusable/createItem.feature'),
    createHolding: karate.read('classpath:reusable/createHolding.feature'),
    createHoldingSource: karate.read('classpath:reusable/createHoldingSource.feature'),
    createInstance: karate.read('classpath:reusable/createInstance.feature'),
    createInstanceWithHrid: karate.read('classpath:reusable/createInstanceWithHrid.feature'),
    createInstanceStatus: karate.read('classpath:reusable/createInstanceStatus.feature'),
    createInstanceType: karate.read('classpath:reusable/createInstanceType.feature'),
    createInstitution: karate.read('classpath:reusable/createInstitution.feature'),
    createLibrary: karate.read('classpath:reusable/createLibrary.feature'),
    createCampus: karate.read('classpath:reusable/createCampus.feature'),
    createLocation: karate.read('classpath:reusable/createLocation.feature'),
    createLoanType: karate.read('classpath:reusable/createLoanType.feature'),
    createMaterialType: karate.read('classpath:reusable/createMaterialType.feature'),
    createServicePoint: karate.read('classpath:reusable/createServicePoint.feature'),
    moveHolding: karate.read('classpath:reusable/moveHolding.feature'),
    moveItem: karate.read('classpath:reusable/moveItem.feature'),
    updateHoldingOwnership: karate.read('classpath:reusable/updateHoldingOwnership.feature'),
    updateItemOwnership: karate.read('classpath:reusable/updateItemOwnership.feature'),
    shareInstance: karate.read('classpath:reusable/shareInstance.feature'),
    updateHridSettings: karate.read('classpath:reusable/updateHridSettings.feature'),

    // Expose eurekaLogin as a function, not as a feature
    eurekaLogin: function(args) { return karate.call('classpath:common-consortia/eureka/initData.feature@Login', args); },

    // Utility functions
    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 8; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },
    uuid: function () {
      return java.util.UUID.randomUUID() + '';
    },
    //to generate random barcode
    random_numbers: function() {
      return Math.floor(Math.random() * 1000000);
    },
    uuids: function (n) {
      var list = [];
      for (var i = 0; i < n; i++) {
        list.push(java.util.UUID.randomUUID() + '');
      }
      return list;
    },
    randomMillis: function() {
      return java.lang.System.currentTimeMillis() + '';
    }
  };
  if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'snapshot-2') {
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'snapshot') {
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}'
    config.apikey = 'eyJzIjoiQnJVZEpkbDJrQSIsInQiOiJ0dHR0cGF0cm9uIiwidSI6InRlc3RwYXRyb24ifQ==';
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
    config.edgeUrl = 'https://folio-edev-vega-edge-inn-reach.ci.folio.org';
    config.baseUrl = 'https://folio-edev-vega-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-vega-keycloak.ci.folio.org';
  }
  return config;
}
