Feature: Tenant lifecycle

  # Schema-per-tenant provisioning through the Okapi `_tenant` interface:
  # enable, idempotent re-enable (upgrade), purge, disable, and — on the 2.0
  # interface — the job-status routes and the explicit-purge guard.
  #
  # Every scenario provisions its OWN throwaway tenant so it can assert the
  # exact state of a fresh schema without disturbing the suite's tenant.

  Background:
    * url baseUrl
    * def scratchTenant = 'ktl' + uuid().replace('-', '').substring(0, 10)
    * def scratchHeaders =
      """
      {
        'Content-Type': 'application/json',
        'X-Okapi-Tenant': '#(scratchTenant)',
        'X-Okapi-Url': '#(okapiUrl)',
        'X-Okapi-Token': 'DUMMY',
        'X-Okapi-User-Id': '#(uuid())'
      }
      """

  Scenario: Enable provisions the tenant and a repeat enable upgrades it
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    # The schema is live: a listing endpoint answers on the new tenant.
    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200

    # A second enable is an upgrade of the same schema, not an error.
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200

  Scenario: Purge drops the tenant schema and all of its data
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And request { code: 'purgeprobe', name: 'Purge probe' }
    When method POST
    Then status 201

    * call read(setupPath + 'tenant.feature@purge') { tenant: '#(scratchTenant)' }

    # Re-enabling rebuilds an EMPTY schema — the probe row is gone with it.
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param filters = 'code==purgeprobe'
    When method GET
    Then status 200
    And match response == []

  Scenario: Disable leaves the tenant data intact
    # Legacy exposes disable as POST /_/tenant/disable (`_tenant` 1.2); the
    # port receives it as the Okapi 2.0 disable job — module_from present,
    # blank module_to, purge explicitly false. Both must be a near-no-op:
    # nothing is migrated, nothing is seeded, no row is dropped (ADR-012 /
    # deviation D-26).
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And request { code: 'disableprobe', name: 'Disable probe' }
    When method POST
    Then status 201

    * def disablePath = impl == 'legacy' ? '/_/tenant/disable' : '/_/tenant'
    * def disableBody = impl == 'legacy' ? { module_from: moduleId } : { module_from: moduleId, module_to: '', purge: false }
    Given path disablePath
    And headers scratchHeaders
    And request disableBody
    When method POST
    Then assert responseStatus >= 200 && responseStatus < 300

    # Data survives the disable: re-enabling finds the row still there.
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param filters = 'code==disableprobe'
    When method GET
    Then status 200
    And match response[0].code == 'disableprobe'

  Scenario: A blank module_to without an explicit purge flag is refused
    # `_tenant` 2.0 only. Destroying a tenant schema must be asked for
    # explicitly: a blank module_to whose purge flag is missing is rejected
    # before any tenant work starts, rather than defaulting to destruction.
    * if (impl != 'port') karate.abort()
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path '_', 'tenant'
    And headers scratchHeaders
    And request { module_from: '#(moduleId)', module_to: '' }
    When method POST
    Then status 400
    And match response.errors == '#[_ > 0]'

    # Nothing was touched — the schema still answers.
    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200

  Scenario: Tenant operation status routes answer as declared
    # `_tenant` 2.0 only: every job this module runs completes synchronously
    # inside the POST, so the status route always reports completion.
    * if (impl != 'port') karate.abort()
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }
    * def operationId = uuid()

    Given path '_', 'tenant', operationId
    And headers scratchHeaders
    When method GET
    Then status 200
    And match response == 'true'

    Given path '_', 'tenant', operationId
    And headers scratchHeaders
    When method DELETE
    Then status 204
