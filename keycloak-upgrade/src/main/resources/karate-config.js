function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  karate.configure('retry', { count: 20, interval: 15000 });

  var env = karate.env;
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];
  var baseUrlOverride = karate.properties['baseUrl'];
  var baseKeycloakUrlOverride = karate.properties['baseKeycloakUrl'];
  var kcClientIdOverride = karate.properties['kcClientId'];
  var kcClientSecretOverride = karate.properties['clientSecret'];
  var m2mClientIdOverride = karate.properties['m2mClientId'];
  var adminTenantOverride = karate.properties['admin.tenant'];
  var adminNameOverride = karate.properties['admin.name'];
  var adminPasswordOverride = karate.properties['admin.password'];
  var effectiveTestTenant = testTenant ? testTenant : 'testtenant';
  var effectiveTestTenantId = testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })();

  var config = {
    baseUrl: baseUrlOverride || 'http://localhost:8000',
    baseKeycloakUrl: baseKeycloakUrlOverride || 'http://localhost:8080',
    admin: {
      tenant: adminTenantOverride || 'diku',
      name: adminNameOverride || 'diku_admin',
      password: adminPasswordOverride || 'admin'
    },
    prototypeTenant: 'diku',
    kcClientId: kcClientIdOverride || 'folio-backend-admin-client',
    kcClientSecret: kcClientSecretOverride || 'SecretPassword',
    m2mClientId: m2mClientIdOverride || 'sidecar-module-access-client',
    tenantParams: { loadReferenceData: true },
    testTenant: effectiveTestTenant,
    testTenantId: effectiveTestTenantId,
    testUser: { tenant: effectiveTestTenant, name: 'kc-upgrade-user', password: 'test' },
    upgradeRoleName: 'kc-upgrade-role-' + effectiveTestTenant,
    upgradeRoleDescription: 'Role created before a Keycloak upgrade and verified after restart',
    upgradeRolePermission: 'roles.collection.get',
    uuid: function () {
      return java.util.UUID.randomUUID() + '';
    },
    decodeJwtPayload: function(token) {
      var Base64 = Java.type('java.util.Base64');
      var String = Java.type('java.lang.String');
      var payload = token.split('.')[1];
      return karate.fromString(new String(Base64.getUrlDecoder().decode(payload)));
    }
  };

  if (env == 'snapshot') {
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
  } else if (env == 'snapshot-2') {
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
  } else if (env == 'folio-testing-karate') {
    config.baseUrl = '${baseUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    };
    config.kcClientId = '${clientId}';
    config.kcClientSecret = '${clientSecret}';
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl', true);
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
  } else if (env == 'eureka1') {
    config.baseUrl = 'https://folio-edev-eureka-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-eureka-keycloak.ci.folio.org';
  } else if (env == 'eureka2') {
    config.baseUrl = 'https://folio-edev-eureka-2nd-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-eureka-2nd-keycloak.ci.folio.org';
  } else if (env == 'local') {
    config.baseUrl = 'http://localhost:8000';
    config.baseKeycloakUrl = 'http://localhost:8080';
    config.kcClientSecret = 'folio-backend-admin-client-secret';
    config.m2mClientId = m2mClientIdOverride || 'm2m-client';
  } else if (env == 'dev') {
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  }

  if (baseUrlOverride) {
    config.baseUrl = baseUrlOverride;
  }
  if (baseKeycloakUrlOverride) {
    config.baseKeycloakUrl = baseKeycloakUrlOverride;
  }
  if (kcClientIdOverride) {
    config.kcClientId = kcClientIdOverride;
  }
  if (kcClientSecretOverride) {
    config.kcClientSecret = kcClientSecretOverride;
  }
  if (m2mClientIdOverride) {
    config.m2mClientId = m2mClientIdOverride;
  }

  return config;
}
