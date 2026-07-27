Feature: tenant lifecycle helper

  # The Okapi `_tenant` interface is the ONE place where the two
  # implementations genuinely differ, so the difference is confined to this
  # file and the rest of the corpus stays implementation-neutral:
  #
  #   legacy (`_tenant` 1.2): POST /_/tenant enables (201),
  #                           DELETE /_/tenant purges,
  #                           POST /_/tenant/disable disables.
  #   port   (`_tenant` 2.0): POST /_/tenant runs every job (204); a purge is a
  #                           blank module_to with an explicit purge flag.

  Background:
    * url baseUrl
    * def tenant = __arg.tenant
    * def tenantHeaders =
      """
      {
        'Content-Type': 'application/json',
        'X-Okapi-Tenant': '#(tenant)',
        'X-Okapi-Url': '#(okapiUrl)',
        'X-Okapi-Token': 'DUMMY'
      }
      """

  @enable
  Scenario: enable (or upgrade) the module for a tenant
    * def parameters =
      """
      (function () {
        var params = [];
        if (__arg.loadReference) { params.push({ key: 'loadReference', value: 'true' }); }
        if (__arg.loadSample) { params.push({ key: 'loadSample', value: 'true' }); }
        return params;
      })()
      """
    Given path '_', 'tenant'
    And headers tenantHeaders
    And request { module_to: '#(moduleId)', parameters: '#(parameters)' }
    When method POST
    Then match responseStatus == expect.tenantJob

  @purge
  Scenario: purge a tenant — drops its schema and every row
    * def dispatch = impl == 'legacy' ? '@purge12' : '@purge20'
    * call read(setupPath + 'tenant.feature' + dispatch) __arg

  @purge12
  Scenario: purge through `_tenant` 1.2 — DELETE /_/tenant
    Given path '_', 'tenant'
    And headers tenantHeaders
    When method DELETE
    Then assert responseStatus == 200 || responseStatus == 204

  @purge20
  Scenario: purge through `_tenant` 2.0 — POST with an explicit purge flag
    Given path '_', 'tenant'
    And headers tenantHeaders
    And request { module_from: '#(moduleId)', purge: true }
    When method POST
    Then status 204
