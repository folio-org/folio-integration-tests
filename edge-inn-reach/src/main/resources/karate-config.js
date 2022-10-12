function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];

  var config = {
    baseUrl: 'http://localhost:9130',
    edgeUrl: 'http://localhost:9703',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    tenantParams: {loadReferenceData: true},
    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: 'test_edge_inn_reach', name: 'innreachClient', password: 'password'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    loginAdmin: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:volaris/edge-inn-reach/global/variables.feature'),

    globalPath: 'classpath:volaris/mod-inn-reach/global/',
    featuresPath: 'classpath:volaris/mod-inn-reach/features/',
    mocksPath: 'classpath:volaris/mod-inn-reach/mocks/',
    samplesPath: 'classpath:volaris/mod-inn-reach/samples/',
    edgeGlobalPath: 'classpath:volaris/edge-inn-reach/global/',
    edgeFeaturesPath: 'classpath:volaris/edge-inn-reach/features/',
    edgeMocksPath: 'classpath:volaris/edge-inn-reach/mocks/',

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
      };

      // Create 100 functions for uuid generation
      var rand = function(i) {
        karate.set("uuid"+i, function() {
          return java.util.UUID.randomUUID() + '';
        });
      }
      karate.repeat(100, rand);

      if (env == 'snapshot-2') {
        config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
        config.edgeUrl = 'https://folio-snapshot-2.dev.folio.org';
        config.admin = {
          tenant: 'supertenant',
          name: 'testing_admin',
          password: 'admin'
        }
      } else if (env == 'snapshot') {
        config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
        config.edgeUrl = 'https://folio-snapshot.dev.folio.org';
        config.admin = {
          tenant: 'supertenant',
          name: 'testing_admin',
          password: 'admin'
        }
      } else if (env == 'rancher') {
            config.baseUrl = 'https://volaris-okapi.ci.folio.org';
            config.edgeUrl = 'https://volaris-edge-inn-reach.ci.folio.org';
            config.admin = {
              tenant: 'diku',
              name: 'diku_admin',
              password: 'admin'
            }
      } else if (env != null && env.match(/^ec2-\d+/)) {
        // Config for FOLIO CI "folio-integration" public ec2- dns name
        config.baseUrl = 'http://' + env + ':9130';
        config.edgeUrl = 'http://' + env + ':8000';
        config.admin = {
          tenant: 'supertenant',
          name: 'admin',
          password: 'admin'
        }
      }

      //   uncomment to run on local
         //karate.callSingle('classpath:volaris/edge-inn-reach/global/add-okapi-permissions.feature', config);

  return config;
}