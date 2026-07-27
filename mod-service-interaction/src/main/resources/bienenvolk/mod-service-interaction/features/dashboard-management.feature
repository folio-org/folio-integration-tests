Feature: Dashboard management

  # Dashboard CRUD and the auto-provisioning rules that give every user a
  # working surface on first use. Each scenario mints a fresh user UUID, so it
  # starts from a user with zero dashboards and the weights and default flags
  # are exact.

  Background:
    * url baseUrl
    * def owner = uuid()
    * def ownerHeaders = asUser(owner)

  Scenario: The first my-dashboards call provisions a default dashboard
    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response == '#[1]'
    * def access = response[0]
    * match access.user.id == owner
    * match access.access.value == 'manage'
    * match access.userDashboardWeight == 0
    * match access.defaultUserDashboard == true
    * match access.dashboard.name == 'My dashboard'
    * def provisionedId = access.dashboard.id

    # Provisioning is idempotent — a second call creates nothing.
    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response == '#[1]'
    And match response[0].dashboard.id == provisionedId

    # The default dashboard gets an empty display-data row alongside it.
    Given path 'servint', 'dashboard', provisionedId, 'displayData'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.dashId == provisionedId

  Scenario: Creating a dashboard grants the creator manage access
    Given path 'servint', 'dashboard'
    And headers ownerHeaders
    And request { name: 'First board', description: 'Created by the owner' }
    When method POST
    # Registered deviation D-27 — legacy 200, port 201; identical body.
    Then match responseStatus == expect.dashboardCreate
    And match response.name == 'First board'
    And match response.id == '#string'
    # A brand new dashboard renders an empty widgets summary array.
    And match response.widgets == '#[0]'
    * def firstId = response.id

    Given path 'servint', 'dashboard'
    And headers ownerHeaders
    And request { name: 'Second board' }
    When method POST
    Then match responseStatus == expect.dashboardCreate
    * def secondId = response.id

    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response == '#[2]'
    * def first = karate.filter(response, function (a) { return a.dashboard.id == firstId })[0]
    * def second = karate.filter(response, function (a) { return a.dashboard.id == secondId })[0]
    # The creator's grant: manage, and the default flag only for the very first
    # dashboard the user ever owned.
    * match first.access.value == 'manage'
    * match first.userDashboardWeight == 0
    * match first.defaultUserDashboard == true
    * match second.access.value == 'manage'
    * match second.userDashboardWeight == 1
    * match second.defaultUserDashboard == false

  Scenario: A dashboard renders its widgets as summaries
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'With widgets' }
    * def dashboardId = created.dashboardId

    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request { name: 'Summary widget', definitionName: 'karate-def', definitionVersion: '1.0', configuration: '{}', owner: { id: '#(dashboardId)' }, weight: 3 }
    When method POST
    Then status 201
    * def instanceId = response.id

    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.name == 'With widgets'
    And match response.widgets == '#[1]'
    # Summaries only: id, weight and name — never the full instance shape.
    And match response.widgets[0] == { id: '#(instanceId)', weight: 3, name: 'Summary widget' }

  Scenario: Update a dashboard, and an unknown id answers 404
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Before rename' }
    * def dashboardId = created.dashboardId

    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    And request { name: 'After rename' }
    When method PUT
    Then status 200
    And match response.name == 'After rename'

    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response.name == 'After rename'

    # Access is evaluated before existence: an ordinary caller has no access
    # object for an id that does not exist, so the answer is 403 ...
    Given path 'servint', 'dashboard', uuid()
    And headers ownerHeaders
    When method GET
    Then status 403

    # ... while a caller holding the admin override gets past the check and
    # sees the real answer.
    Given path 'servint', 'dashboard', uuid()
    And headers asAdmin(uuid())
    When method GET
    Then status 404

  Scenario: Deleting a dashboard takes its access objects and display data with it
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Doomed board' }
    * def dashboardId = created.dashboardId
    * def guest = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(guest)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers ownerHeaders
    When method GET
    Then status 200

    Given path 'servint', 'dashboard', dashboardId
    And headers ownerHeaders
    When method DELETE
    Then status 204

    # The row is gone — seen through the admin override, which is not subject
    # to the (also deleted) access objects.
    Given path 'servint', 'dashboard', dashboardId
    And headers asAdmin(uuid())
    When method GET
    Then status 404

    # The grant is gone with the dashboard: the guest no longer sees it.
    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers asUser(guest)
    When method GET
    Then status 200
    And match response[*].dashboard.id !contains dashboardId

  Scenario: The full dashboard index is reserved to the admin override
    * call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Indexed board' }

    Given path 'servint', 'dashboard'
    And headers ownerHeaders
    And param perPage = 100
    When method GET
    Then status 403

    # The Okapi authority servint.dashboards.admin.allops bypasses every
    # per-dashboard access check.
    Given path 'servint', 'dashboard'
    And headers asAdmin(uuid())
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
