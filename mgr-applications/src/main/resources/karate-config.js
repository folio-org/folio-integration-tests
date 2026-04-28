function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  karate.configure('retry', { count: 20, interval: 15000 });

  var env = karate.env;
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];
  var baseUrlOverride = karate.properties['baseUrl'];
  var baseKeycloakUrlOverride = karate.properties['baseKeycloakUrl'];
  var kongAdminUrlOverride = karate.properties['kongAdminUrl'];
  var kcClientIdOverride = karate.properties['kcClientId'];
  var kcClientSecretOverride = karate.properties['clientSecret'];
  var adminTenantOverride = karate.properties['admin.tenant'];
  var adminNameOverride = karate.properties['admin.name'];
  var adminPasswordOverride = karate.properties['admin.password'];
  var effectiveTestTenant = testTenant ? testTenant : 'testtenant';

  var config = {
    baseUrl: baseUrlOverride || 'http://localhost:8000',
    kongAdminUrl: kongAdminUrlOverride || 'http://localhost:8001',
    admin: {
      tenant: adminTenantOverride || 'diku',
      name: adminNameOverride || 'diku_admin',
      password: adminPasswordOverride || 'admin'
    },
    prototypeTenant: 'diku',
    kcClientId: kcClientIdOverride || 'folio-backend-admin-client',
    kcClientSecret: kcClientSecretOverride || 'SecretPassword',
    tenantParams: { loadReferenceData: true },
    testTenant: effectiveTestTenant,
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: { tenant: effectiveTestTenant, name: 'test-admin', password: 'admin' },
    testUser: { tenant: effectiveTestTenant, name: 'test-user', password: 'test' },
    login: karate.read('classpath:common/login.feature'),
    uuid: function () {
      return java.util.UUID.randomUUID() + '';
    },
    nowMillis: function() {
      return java.lang.System.currentTimeMillis() + '';
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
    config.kongAdminUrl = 'https://folio-edev-eureka-kong-admin-api.ci.folio.org';
  } else if (env == 'eureka2') {
    config.baseUrl = 'https://folio-edev-eureka-2nd-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-eureka-2nd-keycloak.ci.folio.org';
    config.kongAdminUrl = 'https://folio-edev-eureka-2nd-kong-admin-api.ci.folio.org';
  } else if (env == 'local') {
    config.baseUrl = 'http://localhost:8000';
    config.baseKeycloakUrl = 'http://localhost:8080';
    config.kongAdminUrl = 'http://localhost:8001';
    config.kcClientSecret = 'folio-backend-admin-client-secret';
    config.m2mClientId = 'm2m-client';
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
  if (kongAdminUrlOverride) {
    config.kongAdminUrl = kongAdminUrlOverride;
  }
  if (kcClientIdOverride) {
    config.kcClientId = kcClientIdOverride;
  }
  if (kcClientSecretOverride) {
    config.kcClientSecret = kcClientSecretOverride;
  }

  return config;
}
