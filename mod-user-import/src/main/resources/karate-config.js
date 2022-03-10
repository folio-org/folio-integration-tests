function fn() {
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var retryConfig = { count: 20, interval: 30000 }
  karate.configure('retry', retryConfig)

  var env = karate.env;

  // The "testTenant" property could be specified during test runs.
  var testTenant = karate.properties['testTenant'];

  // Create an users array which will be imported. Note that the patron group is empty here and will be created
  // as part of the test run since it needs to exist for importing to succeed.
  var toImport =
  {
    "users": [
      {
        "username": "jhandey",
        "patronGroup": "",
        "externalSystemId": "111_112",
        "barcode": "1234567",
        "active": true,
        "personal": {
          "lastName": "Handey",
          "firstName": "Jack",
          "middleName": "Michael",
          "preferredFirstName": "Jackie",
          "phone": "+36 55 230 348",
          "mobilePhone": "+36 55 379 130",
          "dateOfBirth": "1995-10-10",
          "addresses": [
            {
              "countryId": "HU",
              "addressLine1": "Andrássy Street 1.",
              "addressLine2": "",
              "city": "Budapest",
              "region": "Pest",
              "postalCode": "1061",
              "addressTypeId": "Home",
              "primaryAddress": true
            }
          ],
          "preferredContactTypeId": "mail"
        },
        "enrollmentDate": "2017-01-01",
        "expirationDate": "2019-01-01"
      }
    ],
    "totalRecords": 1,
    "deactivateMissingUsers": true,
    "updateOnlyPresentFields": false,
    "sourceType": "sourceTypeName"
  };

  // Define the karate configuration.
  var config = {
    baseUrl: 'http://localhost:9130',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},

    testTenant: testTenant ? testTenant: 'testTenant',
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // Make the test users object a config variable so that it will be accessible in the test scenarios.
    usersToImport: toImport,

    // Define global features.
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

    // Define global functions.
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
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
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
