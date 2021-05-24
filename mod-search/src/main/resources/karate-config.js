function fn() {
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // specify runId property for tenant postfix to avoid close connection issues
  // once we run tests again
  var runId = karate.properties['runId'];

  var config = {
    baseUrl: 'https://falcon-okapi.ci.folio.org',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    runId: runId ? runId: '',
    baseHeaders: {'Content-Type': 'application/json', 'Accept': '*/*'},

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
    }
  };

  if (env == 'testing') {
    config.baseUrl = 'https://folio-testing-okapi.dev.folio.org';
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
      config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org';
      config.admin = {
        tenant: 'diku',
        name: 'diku_admin',
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

  // Login the admin client
  var params = JSON.parse(JSON.stringify(config.admin));
  params.baseUrl = config.baseUrl;
  var response = karate.callSingle('classpath:common/login.feature', params);
  config.baseHeaders['x-okapi-token'] = response.responseHeaders['x-okapi-token'][0];
  config.baseHeaders['x-okapi-tenant'] = config.admin.tenant;

  return config;
}
