function fn() {
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  karate.configure('retry', { count: 20, interval: 30000 })

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var env = karate.env;
  var adminPassword = karate.properties['karate.admin.password'] == null
    ? java.lang.System.getenv("ADMIN_PASSWORD") : karate.properties['karate.admin.password'];

  // specify runId property for tenant postfix to avoid close connection issues
  // once we run tests again
  var runId = karate.properties['runId'];

  var config = {
    runId: runId ? runId: '',
    baseUrl: 'https://falcon-okapi.ci.folio.org',
    admin: { tenant: 'diku', name: 'diku_admin', password: adminPassword },
    prototypeTenant: 'diku',
    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: { tenant: testTenant, name: 'test-admin', password: 'admin' },
    testUser: { tenant: testTenant, name: 'test-user', password: 'test' },
    tenantParams: { loadReferenceData: true },
    webSemanticInstance: 'af83c0ac-c3ba-4b11-95c8-4110235dec80',
    webOfMetaphorInstance: '7e18b615-0e44-4307-ba78-76f3f447041c',
    personalAuthorityId: 'c73e6f60-5edd-11ec-bf63-0242ac130002',
    corporateAuthorityId: 'fd0b6ed1-d6af-4738-ac44-e99dbf561720',
    meetingAuthorityId: 'cd3eee4e-5edd-11ec-bf63-0242ac130002',
    personalAuthoritySourceFileId: '4e224096-cae5-4dbd-9799-30c7bbba3f54',
    personalAuthorityNaturalId: 'nr10384',
    corporateAuthoritySourceFileId: '5de462a2-7a90-4467-b77f-b2057d6d69b6',
    corporateAuthorityNaturalId: 'sh34521',
    meetingAuthoritySourceFileId: '266026b6-1572-43c0-9a39-6e5d4ac20ba4',
    meetingAuthorityNaturalId: 'gf5038134',

    login: karate.read('classpath:common/login.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    random: function (max) {
      return Math.floor(Math.random() * max)
    },

    randomString: function(length) {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
      for (var i = 0; i < length; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },

    pause: function(millis) {
       var thread = Java.type('java.lang.Thread');
       thread.sleep(millis);
    },

    facet: function(id, totalRecords) {
      return {"id":id, "totalRecords":totalRecords};
    }
  };

  if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-snapshot-2-okapi.dev.folio.org';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: adminPassword
    }
  } else if (env == 'snapshot') {
      config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
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
