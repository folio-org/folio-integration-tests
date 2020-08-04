function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env ? karate.env : 'scratch';

  // specify runId property for tenant postfix to avoid close connection issues
  // once we run tests again
  var runId = karate.properties['runId'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    runId: runId ? runId: '',
    edgeHost:'http://localhost:9701',
    edgeApiKey: 'eyJzIjoiQlBhb2ZORm5jSzY0NzdEdWJ4RGgiLCJ0IjoiZGlrdSIsInUiOiJkaWt1In0',

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:global/variables.feature'),
    getModuleIdByName: karate.read('classpath:global/module-utils.feature@getModuleIdByName'),
    enableModule: karate.read('classpath:global/module-utils.feature@enableModule'),
    deleteModule: karate.read('classpath:global/module-utils.feature@deleteModule'),
    resetConfiguration: karate.read('classpath:domain/mod-configuration/reusable/reset-configuration.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    random: function (max) {
      return Math.floor(Math.random() * max)
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';
  config.env = env;

  if (env === 'scratch') {
    config.baseUrl = 'https://gulfstream-okapi.ci.folio.org/';
    config.admin = {tenant: 'diku', name: 'diku_admin', password: 'admin'};
    config.edgeHost = 'https://edge-pmh-gulfstream.ci.folio.org';
    config.edgeApiKey = 'eyJzIjoiQlBhb2ZORm5jSzY0NzdEdWJ4RGgiLCJ0IjoiZGlrdSIsInUiOiJkaWt1In0"';
  }else if (env === 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.aws.indexdata.com';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-testing.aws.indexdata.com:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.aws.indexdata.com';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-snapshot.aws.indexdata.com:8000';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.getModuleByIdPath = '_/proxy/modules';
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
