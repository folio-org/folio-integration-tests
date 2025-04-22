function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    tenantParams: {
      loadReferenceData : true
    },
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
    loadTestVariables: karate.read('classpath:global/variables.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },
    random: function (max) {
      return Math.floor(Math.random() * 100)
    },
    addVariables: function(a,b){
      return a + b;
    },
    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    },
    randomString: function(length) {
      var result = '';
      var characters = 'abcdefghijklmnopqrstuvwxyz';
      var charactersLength = characters.length;
      for ( var i = 0; i < length; i++ ) {
       result += characters.charAt(Math.floor(Math.random() * charactersLength));
      }
      return result;
    },
    orWhereQuery: function(field, values) {
      var orStr = ' or ';
      var string = '(' + field + '=(' + values.map(x => '"' + x + '"').join(orStr) + '))';
      return string;
    },
    replaceRegex: function(line, regex, newString) {
      return line.replace(new RegExp(regex, "gm"), newString);
    },
    getCurrentDate: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy-MM-dd');
      var date = new java.util.Date();
      return sdf.format(date);
    },
    randomMillis: function() {
      return java.lang.System.currentTimeMillis() + '';
    }
  };

  config.getModuleByIdPath = '_/proxy/tenants/' + config.admin.tenant + '/modules';

  if (env === 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.edgeHost = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env === 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.admin = {tenant: 'supertenant', name: 'testing_admin', password: 'admin'};
    config.edgeHost = 'https://folio-etesting-snapshot-edge.ci.folio.org';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env === 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.edgeHost = '${edgeUrl}';
    config.edgeApiKey = 'eyJzIjoiNXNlNGdnbXk1TiIsInQiOiJkaWt1IiwidSI6ImRpa3UifQ==';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
    config.baseKeycloakUrl = 'https://folio-etesting-karate-eureka-keycloak.ci.folio.org';
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env == 'rancher') {
    config.baseUrl = 'https://folio-edev-firebird-kong.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-firebird-edge.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-firebird-keycloak.ci.folio.org';
     config.admin = {
        tenant:'supertenant',
        name:'testing_admin',
        password:'admin'
     }
     karate.configure('ssl',true)
    config.clientSecret = karate.properties['clientSecret'] || 'SecretPassword';
  } else if (env != null && env.match(/^ec2-\d+/)) {
    config.baseUrl = 'http://' + env + ':9130';
    config.admin = {tenant: 'supertenant', name: 'admin', password: 'admin'}
  }


//   uncomment to run on local
//   karate.callSingle('classpath:global/add-okapi-permissions.feature', config);

  return config;
}
