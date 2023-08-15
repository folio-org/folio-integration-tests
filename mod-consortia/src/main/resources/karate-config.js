function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  var config = {
    baseUrl: 'http://localhost:9130',
    edgeUrl: 'http://localhost:8000',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    mobiusAdmin: {tenant: 'mobius', name: 'mobius_admin', password: 'admin'},
    prototypeTenant: 'diku',

    // define global features
    login: karate.read('classpath:common/login.feature'),
    dev: karate.read('classpath:common/dev.feature'),

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
    getCurrentYear: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy');
      var date = new java.util.Date();
      return sdf.format(date);
    },
    getCurrentDate: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy-MM-dd');
      var date = new java.util.Date();
      return sdf.format(date);
    },

    getYesterday: function() {
      var LocalDate = Java.type('java.time.LocalDate');
      var localDate = LocalDate.now().minusDays(1);
      var formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
      var formattedString = localDate.format(formatter);
      return localDate.format(formatter);
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
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    config.baseUrl = 'https://folio-snapshot-okapi.dev.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-dev-thunderjet-okapi.ci.folio.org';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.prototypeTenant= '${mobiusAdmin.tenant}'
    config.admin = {
      tenant: 'consortium',
      name: 'consortium_admin',
      password: 'admin'
    }
  } else if (env == 'thunderjet-consortia-rancher') {
    config.baseUrl = 'https://folio-dev-thunderjet-okapi.ci.folio.org:443';
    config.edgeUrl = 'https://folio-snapshot.dev.folio.org:8000';
    config.prototypeTenant= '${mobiusAdmin.tenant}'
    config.admin = {
      tenant: 'consortium',
      name: 'consortium_admin',
      password: 'admin'
    }
  } else if(env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeUrl = '${edgeUrl}';
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
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}
