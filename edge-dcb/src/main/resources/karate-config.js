function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    edgeUrl: 'http://localhost:1212',
    centralServerUrl: 'https://folio-dev-volaris-mock-server.ci.folio.org',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    tenantParams: {loadReferenceData: true},
    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: 'test_edge_dcb', name: 'dcbClient', password: 'password'},

    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    loginAdmin: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:volaris/mod-dcb/global/variables.feature'),

    globalPath: 'classpath:volaris/mod-dcb/global/',
    featuresPath: 'classpath:volaris/mod-dcb/features/',
    edgeFeaturesPath: 'classpath:volaris/edge-dcb/features/',

    // define global functions
        random_uuid: function () {
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
        random_numbers: function() {
        return Math.floor(Math.random() * 1000000)
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
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org:8000';
    config.apikey = 'eyJzIjoidVh5a2xCZTRnaiIsInQiOiJ0ZXN0X2VkZ2VfZGNiIiwidSI6ImRjYkNsaWVudCJ9';

    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.apikey = 'eyJzIjoidVh5a2xCZTRnaiIsInQiOiJ0ZXN0X2VkZ2VfZGNiIiwidSI6ImRjYkNsaWVudCJ9';

    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-dev-volaris-2nd-okapi.ci.folio.org';
    config.edgeUrl = 'https://folio-dev-volaris-2nd-edge.ci.folio.org';
    config.apikey = 'eyJzIjoidVh5a2xCZTRnaiIsInQiOiJ0ZXN0X2VkZ2VfZGNiIiwidSI6ImRjYkNsaWVudCJ9';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.apikey = 'eyJzIjoidVh5a2xCZTRnaiIsInQiOiJ0ZXN0X2VkZ2VfZGNiIiwidSI6ImRjYkNsaWVudCJ9';

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
    config.edgeUrl = 'http://' + env + ':8000';
    config.apikey = 'eyJzIjoidVh5a2xCZTRnaiIsInQiOiJ0ZXN0X2VkZ2VfZGNiIiwidSI6ImRjYkNsaWVudCJ9';

    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}