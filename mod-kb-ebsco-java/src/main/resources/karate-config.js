function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 50000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  var kbEbscoCredentialsApiKey = karate.properties['kbEbscoCredentialsApiKey']
  var kbEbscoCredentialsUrl = karate.properties['kbEbscoCredentialsUrl']
  var kbEbscoCredentialsCustomerId = karate.properties['kbEbscoCredentialsCustomerId']
  var usageConsolidationCredentialsId = karate.properties['usageConsolidationCredentialsId']
  var usageConsolidationCredentialsSecret = karate.properties['usageConsolidationCredentialsSecret']
  var usageConsolidationCustomerKey = karate.properties['usageConsolidationCustomerKey']

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',
    kbEbscoCredentialsApiKey: kbEbscoCredentialsApiKey,
    kbEbscoCredentialsUrl: kbEbscoCredentialsUrl,
    kbEbscoCredentialsCustomerId: kbEbscoCredentialsCustomerId,
    usageConsolidationCredentialsId: usageConsolidationCredentialsId,
    usageConsolidationCredentialsSecret: usageConsolidationCredentialsSecret,
    usageConsolidationCustomerKey: usageConsolidationCustomerKey,

    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },

    sleep: function(millis) {
     return java.lang.Thread.sleep(millis);
    },

    setSystemProperty: function(name, property) {
      java.lang.System.setProperty(name, property);
    },
    getAndClearSystemProperty: function(name) {
      return java.lang.System.clearProperty(name);
    },
    replaceRegex: function(line, regex, newString) {
      return line.replace(new RegExp(regex, "gm"), newString);
    },
    now: function() {
      return java.lang.System.currentTimeMillis();
    },
    orWhereQuery: function(field, values) {
       var orStr = ' or ';
       var string = '(' + field + '=(' + values.map(x => '"' + x + '"').join(orStr) + '))';

       return string;
     }
  };

  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'eureka') {
    config.baseUrl = 'https://folio-edev-dojo-kong.ci.folio.org:443';
    config.baseKeycloakUrl = 'https://folio-edev-dojo-keycloak.ci.folio.org:443';
    config.clientSecret = karate.properties['clientSecret'];
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.kbEbscoCredentialsApiKey = '${kbEbscoCredentialsApiKey}';
    config.kbEbscoCredentialsUrl = '${kbEbscoCredentialsUrl}';
    config.kbEbscoCredentialsCustomerId = '${kbEbscoCredentialsCustomerId}';
    config.usageConsolidationCredentialsId = '${usageConsolidationCredentialsId}';
    config.usageConsolidationCredentialsSecret = '${usageConsolidationCredentialsSecret}';
    config.usageConsolidationCustomerKey = '${usageConsolidationCustomerKey}';
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
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
