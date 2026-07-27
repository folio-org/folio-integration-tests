Feature: mod-service-interaction integration tests — teardown

  # Off by default: a parity run normally wants the tenant left in place so the
  # legacy and port databases can be diffed after the fact. Run with
  # -DpurgeOnExit=true to drop the tenant schema instead.

  Scenario: purge the test tenant when the run asked for it
    * if (!purgeOnExit) karate.abort()
    * call read(setupPath + 'tenant.feature@purge') { tenant: '#(testTenant)' }
