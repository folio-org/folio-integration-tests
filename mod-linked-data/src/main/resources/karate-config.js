function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 120, interval: 5000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    tenantParams: {loadReferenceData: true},
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',

    testTenant: testTenant ? testTenant : 'testtenant',
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),
    getResource: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getResource'),
    getInventoryInstance: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getInventoryInstance'),
    putInventoryInstance: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@putInventoryInstance'),
    postResource: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@postResource'),
    putResource: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@putResource'),
    postSourceRecordToStorage: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@postSourceRecordToStorage'),
    putSourceRecordToStorage: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@putSourceRecordToStorage'),
    searchLinkedDataWork: karate.read('classpath:citation/mod-linked-data/features/util/search-resource.feature@searchLinkedDataWork'),
    searchInventoryInstance: karate.read('classpath:citation/mod-linked-data/features/util/search-resource.feature@searchInventoryInstance'),
    searchAuthority: karate.read('classpath:citation/mod-linked-data/features/util/search-resource.feature@searchAuthority'),
    getSourceRecordFormatted: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getSourceRecordFormatted'),
    getResourceGraph: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getResourceGraph'),
    getDerivedMarc: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getDerivedMarc'),
    getResourceSupportCheck: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getResourceSupportCheck'),
    getResourcePreview: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@getResourcePreview'),
    validationErrorWithCodeOnResourceCreation: karate.read('classpath:citation/mod-linked-data/features/util/validation-resource.feature@validationErrorWithCodeOnResourceCreation'),
    getSettings: karate.read('classpath:citation/mod-linked-data/features/util/crud-settings.feature@getSettings'),
    putSetting: karate.read('classpath:citation/mod-linked-data/features/util/crud-settings.feature@putSetting'),
    postSetting: karate.read('classpath:citation/mod-linked-data/features/util/crud-settings.feature@postSetting'),
    getSetting: karate.read('classpath:citation/mod-linked-data/features/util/crud-settings.feature@getSetting'),
    postImport: karate.read('classpath:citation/mod-linked-data/features/util/crud-resource.feature@postImport'),
    getSpecifications: karate.read('classpath:citation/mod-linked-data/features/util/crud-specifications.feature@getSpecifications'),
    getRules: karate.read('classpath:citation/mod-linked-data/features/util/crud-specifications.feature@getRules'),
    patchRule: karate.read('classpath:citation/mod-linked-data/features/util/crud-specifications.feature@patchRule'),

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

    sleep: function(seconds) {
      java.lang.Thread.sleep(seconds * 1000)
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
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'eureka') {
    config.baseUrl = 'https://folio-edev-dojo-kong.ci.folio.org:443';
    config.baseKeycloakUrl = 'https://folio-edev-dojo-keycloak.ci.folio.org:443';
    config.clientSecret = karate.properties['clientSecret'];
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
  } else if (env === 'rancher') {
    config.baseUrl = 'https://folio-edev-citation-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-citation-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    };
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
