function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant ? testTenant : 'testtenant',
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
  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org:8000';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot-load') {
    config.baseUrl = 'https://folio-snapshot-load-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-load.dev.folio.org:8000';
    config.apikey = 'eyJzIjoibTE2M0k2NTRHZ1pWOVBMdnRTa1MiLCJ0IjoiZGlrdSIsInUiOiJkaWt1X2FkbWluIn0K';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-dev-dreamliner-okapi.ci.folio.org';
    config.edgeUrl = 'https://folio-dev-dreamliner-edge.ci.folio.org';
    config.apikey = 'eyJzIjoid2hhdHNpdCIsInQiOiJ0ZXN0cnRhYyIsInUiOiJ0ZXN0LXVzZXIifQ==';
    config.prototypeTenant='diku'
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
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // edge modules cannot run properly on dedicated environment for the Karate tests
    // short term solution is to have the module run on testing
    // This is not ideal as it negates a lot of the purpose of the tests
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org:8000';
    config.apikey = 'eyJzIjoibTE2M0k2NTRHZ1pWOVBMdnRTa1MiLCJ0IjoiZGlrdSIsInUiOiJkaWt1X2FkbWluIn0K';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  }
  return config;
}
