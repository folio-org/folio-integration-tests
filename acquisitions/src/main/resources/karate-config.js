function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // specify runId property for tenant postfix to avoid close connection issues
  // once we run tests again
  var runId = karate.properties['runId'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    runId: runId ? runId: '',

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:global/variables.feature'),

    // finances
    createFund: karate.read('classpath:domain/mod-finance/reusable/createFund.feature'),
    createBudget: karate.read('classpath:domain/mod-finance/reusable/createBudget.feature'),
    createTransaction: karate.read('classpath:domain/mod-finance/reusable/createTransaction.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    random: function (max) {
      return Math.floor(Math.random() * max)
    }
  };

  // Create 20 functions for uuid generation
  var rand = function(i) {
    karate.set("uuid"+i, function() {
      return java.util.UUID.randomUUID() + '';
    });
  }
  karate.repeat(20, rand);

  if (env == 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.aws.indexdata.com:443';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.aws.indexdata.com:443';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}
