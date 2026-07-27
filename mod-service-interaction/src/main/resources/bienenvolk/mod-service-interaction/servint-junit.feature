Feature: mod-service-interaction integration tests — bootstrap

  # Provisions the tenant every feature of the suite runs against. The module
  # is enabled through its own Okapi `_tenant` interface with both data
  # buckets requested, so the corpus can assert the seeded reference data and
  # the bundled widget types. Per-trigger seeding semantics (what each
  # parameter does, and what an enable does WITHOUT them) are covered on
  # throwaway tenants by features/reference-data-seeding.feature.

  Scenario: enable the module for the test tenant
    * print '--- mod-service-interaction suite: impl =', impl, '| baseUrl =', baseUrl, '| tenant =', testTenant
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(testTenant)', loadReference: true, loadSample: true }
