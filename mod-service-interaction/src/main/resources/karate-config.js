function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  karate.configure('readTimeout', 60000);
  karate.configure('connectTimeout', 30000);

  var env = karate.env ? karate.env : 'legacy';

  var prop = function (name, fallback) {
    var value = karate.properties[name];
    return (value === null || value === undefined || value === '') ? fallback : value;
  };

  // ---------------------------------------------------------------------
  // The suite is ONE corpus authored against the legacy Grails module
  // (mod-service-interaction master) and re-runnable, unchanged, against the
  // Spring Boot port, so the two can be compared for functional parity and
  // data integrity. `karate.env` selects which deployment is under test.
  // ---------------------------------------------------------------------
  var deployments = {
    legacy: {
      impl: 'legacy',
      baseUrl: 'http://localhost:8080',
      moduleId: 'mod-service-interaction-4.4.0'
    },
    port: {
      impl: 'port',
      baseUrl: 'http://localhost:8081',
      moduleId: 'mod-service-interaction-5.0.0'
    }
  };
  var deployment = deployments[env] ? deployments[env] : deployments.legacy;

  var config = {
    // 'legacy' | 'port' — selects the expected status of the handful of
    // registered wire deviations (see `expect` below). Everything else in the
    // suite is asserted identically for both.
    impl: prop('impl', deployment.impl),
    // Base URL of the module under test. Point it at the module itself for a
    // dedicated parity environment, or at an Okapi/Kong gateway that proxies
    // it; the suite always sends the Okapi headers a gateway would inject.
    baseUrl: prop('baseUrl', deployment.baseUrl),
    okapiUrl: prop('okapiUrl', 'http://localhost:9130'),
    // TestBaseEureka seeds `testTenant` with a fresh random tenant per run, so
    // every run starts from an empty schema and the seeding assertions are
    // exact. Override with -DtestTenant=... to re-use one.
    testTenant: prop('testTenant', 'servintkarate'),
    moduleId: prop('moduleId', deployment.moduleId),
    // Purge the test tenant after the run (drops its schema). Off by default:
    // a parity run usually wants the resulting data left in place for a
    // side-by-side database diff.
    purgeOnExit: prop('purgeOnExit', 'false') == 'true',
    // Widget definition federation harvests every module implementing the
    // `dashboard` Okapi interface, so it only means anything when the module
    // under test sits behind a reachable gateway. Enable with -Dfederation=true.
    federationEnabled: prop('federation', 'false') == 'true',

    featuresPath: 'classpath:bienenvolk/mod-service-interaction/features/',
    setupPath: 'classpath:bienenvolk/mod-service-interaction/setup/',
    samplesPath: 'classpath:bienenvolk/mod-service-interaction/samples/',

    // Okapi hands the module the caller's granted "desired" permissions as a
    // JSON array in X-Okapi-Permissions; both implementations read the admin
    // override from there.
    adminPermissions: '["servint.dashboards.admin.allops"]'
  };

  // UTC calendar year — the ${current_year} token and the year-reset sweep are
  // asserted against it.
  config.currentYear = new Date().getFullYear();
  config.current_year = new Date().getFullYear();

  config.uuid = function () {
    return java.util.UUID.randomUUID() + '';
  };

  // Every request carries the headers Okapi injects. The module resolves the
  // acting FOLIO user from X-Okapi-User-Id, so a "user" in this suite is just
  // a UUID: no user records, mod-users or login are needed.
  config.asUser = function (userId) {
    return {
      'Content-Type': 'application/json',
      'X-Okapi-Tenant': config.testTenant,
      'X-Okapi-Url': config.okapiUrl,
      'X-Okapi-Token': 'DUMMY',
      'X-Okapi-User-Id': userId
    };
  };

  // Same, plus the dashboard admin override authority.
  config.asAdmin = function (userId) {
    var headers = config.asUser(userId);
    headers['X-Okapi-Permissions'] = config.adminPermissions;
    return headers;
  };

  // ---------------------------------------------------------------------
  // Registered deviations between the two implementations. These are the ONLY
  // places where the corpus expects a different answer per deployment; each is
  // a documented decision in the module's migration dossier
  // (docs/migration/wire-compat-deviations.md), not a test workaround.
  // ---------------------------------------------------------------------
  config.expect = {
    // `_tenant` 1.2 (legacy) answers 201 on enable; 2.0 (port) answers 204 — ADR-012 / D-26.
    tenantJob: config.impl == 'legacy' ? 201 : 204,
    // POST /servint/dashboard: legacy answers 200 from a bespoke respond(), the port 201 — D-27.
    dashboardCreate: config.impl == 'legacy' ? 200 : 201,
    // POST /servint/widgets/definitions: legacy creates (201), the port never
    // declared local-definition creation and answers 405 — D-2.
    definitionCreate: config.impl == 'legacy' ? 201 : 405
  };

  return config;
}
