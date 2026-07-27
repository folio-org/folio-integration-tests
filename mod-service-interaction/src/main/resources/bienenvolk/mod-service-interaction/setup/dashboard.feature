Feature: dashboard helpers

  # A "user" is a bare FOLIO user UUID carried in X-Okapi-User-Id: the module
  # never resolves it against mod-users, it only stores it on the access
  # objects. Features therefore mint a fresh UUID per scenario and start from a
  # guaranteed-empty per-user state.

  Background:
    * url baseUrl
    * def actor = asUser(__arg.user)

  @provision
  Scenario: fetch my-dashboards, provisioning the caller's default dashboard
    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers actor
    When method GET
    Then status 200
    * def accessObjects = response

  @create
  Scenario: create a dashboard owned by the calling user
    Given path 'servint', 'dashboard'
    And headers actor
    And request { name: '#(__arg.name)' }
    When method POST
    # Registered deviation D-27: legacy answers 200 from a bespoke respond(),
    # the port answers the conventional 201. The body is identical.
    Then match responseStatus == expect.dashboardCreate
    * def dashboardId = response.id

  @grant
  Scenario: grant another user access to a dashboard (caller must hold manage)
    Given path 'servint', 'dashboard', __arg.dashboardId, 'users'
    And headers actor
    And request [{ user: { id: '#(__arg.target)' }, access: '#(__arg.access)' }]
    When method POST
    Then status 200
    * def users = response
