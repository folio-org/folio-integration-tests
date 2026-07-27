Feature: Dashboard access control

  # Per-dashboard access levels form a hierarchy — view < edit < manage — and
  # every dashboard-scoped operation is gated by the caller's level. The Okapi
  # authority servint.dashboards.admin.allops bypasses the whole check.

  Background:
    * url baseUrl
    * def owner = uuid()
    * def ownerHeaders = asUser(owner)
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Shared board' }
    * def dashboardId = created.dashboardId

  Scenario: A manage holder passes the view and edit checks
    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    When method GET
    Then status 200

    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    And request { name: 'Renamed by the manager' }
    When method PUT
    Then status 200
    And match response.name == 'Renamed by the manager'

  Scenario: A view-only user may read but not update the dashboard
    * def viewer = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(viewer)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId
    And headers asUser(viewer)
    When method GET
    Then status 200

    Given path 'servint', 'dashboard', dashboardId
    And headers asUser(viewer)
    And request { name: 'Renamed by a viewer' }
    When method PUT
    Then status 403

    # The dashboard is untouched.
    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.name == 'Shared board'

  Scenario: An edit holder may update but not delete the dashboard
    * def editor = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(editor)', access: 'edit' }

    Given path 'servint', 'dashboard', dashboardId
    And headers asUser(editor)
    And request { name: 'Renamed by an editor' }
    When method PUT
    Then status 200

    # Deleting needs manage.
    Given path 'servint', 'dashboard', dashboardId
    And headers asUser(editor)
    When method DELETE
    Then status 403

    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    When method GET
    Then status 200

  Scenario: A user with no access object is refused
    Given path 'servint', 'dashboard', dashboardId
    And headers asUser(uuid())
    When method GET
    Then status 403

  Scenario: My access reports the caller's own level
    * def editor = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(editor)', access: 'edit' }

    Given path 'servint', 'dashboard', dashboardId, 'my-access'
    And headers asUser(editor)
    When method GET
    Then status 200
    # Exactly one field, naming the level.
    And match response == { access: 'edit' }

    Given path 'servint', 'dashboard', dashboardId, 'my-access'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response == { access: 'manage' }

    # No access object at all: refused, not reported as "none".
    Given path 'servint', 'dashboard', dashboardId, 'my-access'
    And headers asUser(uuid())
    When method GET
    Then status 403

  Scenario: The admin override bypasses the per-dashboard checks
    * def administrator = asAdmin(uuid())

    Given path 'servint', 'dashboard', dashboardId
    And headers administrator
    When method GET
    Then status 200
    And match response.id == dashboardId

    Given path 'servint', 'dashboard', dashboardId, 'widgets'
    And headers administrator
    When method GET
    Then status 200
