function fn() {

    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    var env = karate.env;

    // The "testTenant" property could be specified during test runs
    var testTenant = karate.properties['testTenant'];
    var testTenantId = karate.properties['testTenantId'];

    var config = {
        baseUrl: 'http://localhost:8000',
        edgeUrl: 'http://localhost:8000',
        admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
        prototypeTenant: 'diku',
        consortiaSystemUserName: 'consortia-system-user',

        kcClientId: 'folio-backend-admin-client',
        kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

        testTenant: testTenant,
        testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
        testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
        testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

        // define global features
        login: karate.read('classpath:common-consortia/eureka/initData.feature@Login'),
        dev: karate.read('classpath:common/dev.feature'),

        // define global functions
        uuid: function () {
            return java.util.UUID.randomUUID() + ''
        },

        uuids: function (n) {
            var list = [];
            for (var i = 0; i < n; i++) {
                list.push(java.util.UUID.randomUUID() + '');
            }
            return list;
        },

        random: function (max) {
            return Math.floor(Math.random() * max)
        },

        randomMillis: function () {
            return java.lang.System.currentTimeMillis() + '';
        },

        random_string: function () {
            var text = "";
            var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
            for (var i = 0; i < 5; i++)
                text += possible.charAt(Math.floor(Math.random() * possible.length));
            return text;
        },
        getCurrentYear: function () {
            var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
            var sdf = new SimpleDateFormat('yyyy');
            var date = new java.util.Date();
            return sdf.format(date);
        },
        getCurrentDate: function () {
            var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
            var sdf = new SimpleDateFormat('yyyy-MM-dd');
            var date = new java.util.Date();
            return sdf.format(date);
        },

        getYesterday: function () {
            var LocalDate = Java.type('java.time.LocalDate');
            var localDate = LocalDate.now().minusDays(1);
            var formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
            var formattedString = localDate.format(formatter);
            return localDate.format(formatter);
        },

        pause: function (millis) {
            var Thread = Java.type('java.lang.Thread');
            Thread.sleep(millis);
        }

    };

    // Create 100 functions for uuid generation
    var rand = function (i) {
        karate.set("uuid" + i, function () {
            return java.util.UUID.randomUUID() + '';
        });
    }
    karate.repeat(100, rand);

    if (env == 'dev' || env == 'dev-shared') {
        config.checkDepsDuringModInstall = 'false';
        config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
        config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
    } else if (env == 'snapshot-2') {
        config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
        config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
        config.edgeUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org:8000';
        config.admin = {
            tenant: 'supertenant',
            name: 'testing_admin',
            password: 'admin'
        }
    } else if (env == 'rancher') {
        config.baseUrl = 'https://folio-edev-thunderjet-kong.ci.folio.org';
        config.baseKeycloakUrl = 'https://folio-edev-thunderjet-keycloak.ci.folio.org';
        config.edgeUrl = 'https://folio-edev-thunderjet-edge.ci.folio.org';
        config.prototypeTenant = 'diku'
        config.admin = {
            tenant: 'diku',
            name: 'diku_admin',
            password: 'admin'
        }
    } else if (env == 'rancher-consortia') {
        config.baseUrl = 'https://ecs-folio-edev-thunderjet-kong.ci.folio.org';
        config.baseKeycloakUrl = 'https://folio-edev-thunderjet-keycloak.ci.folio.org';
        config.edgeUrl = 'https://ecs-folio-edev-thunderjet-edge.ci.folio.org';
        config.prototypeTenant = 'consortium'
        config.admin = {
            tenant: 'consortium',
            name: 'consortium_admin',
            password: 'admin'
        }
    } else if (env == 'folio-testing-karate') {
        config.baseUrl = '${baseUrl}';
        config.baseKeycloakUrl = '${baseKeycloakUrl}';
        config.edgeUrl = '${edgeUrl}';
        config.admin = {
            tenant: '${admin.tenant}',
            name: '${admin.name}',
            password: '${admin.password}'
        }
        config.kcClientId = '${clientId}';
        config.kcClientSecret = '${clientSecret}';
        config.prototypeTenant = '${prototypeTenant}';
        config.consortiaSystemUserName = 'mod-consortia-system';
        karate.configure('ssl', true);
    } else if (env != null && env.match(/^ec2-\d+/)) {
        // Config for FOLIO CI "folio-integration" public ec2- dns name
        config.baseUrl = 'http://' + env + ':8000';
        config.edgeUrl = 'http://' + env + ':8000';
        config.admin = {
            tenant: 'supertenant',
            name: 'admin',
            password: 'admin'
        }
    }
    return config;
}
