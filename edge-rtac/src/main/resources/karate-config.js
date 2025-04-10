function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},
  
    // define global features
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    
    // define global functions
    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },
    //to generate random barcode
    random_numbers: function() {
      return Math.floor(Math.random() * 1000000);
    },
    random_uuid: function() {
      return java.util.UUID.randomUUID() + '';
    },
    expectedData : function(array,resource) {
     var temp = [];
     for (var i = 0; i < array.length; i++)
     {
     if(resource == "holdings")
      temp[i] = array[i].holding.id
     else if(resource == "instances")
      temp[i] = array[i].instanceId
     else if(resource == "status")
      temp[i] = array[i].holding.status
     }
     return temp;
    }
  };
  if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot2-edge.ci.folio.org';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-dreamliner-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-dreamliner-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-dreamliner-keycloak.ci.folio.org';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
    config.prototypeTenant='diku'
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
    config.admin = {
     tenant: 'diku',
     name: 'diku_admin',
     password: 'admin'
    }
 } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
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
