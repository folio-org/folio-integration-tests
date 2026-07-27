Feature: Dashboard user management

  # Sharing a dashboard: the manager posts a list of per-item instructions —
  # create (no id), delete (id + _delete), or change the level (id only) — and
  # gets the refreshed user list back. Items that would grant the caller
  # themselves, or re-grant a user who already has access, are ignored rather
  # than rejected.

  Background:
    * url baseUrl
    * def owner = uuid()
    * def ownerHeaders = asUser(owner)
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Team board' }
    * def dashboardId = created.dashboardId
    * def accessOf =
      """
      function (users, userId) {
        var hit = karate.filter(users, function (a) { return a.user.id == userId });
        return hit.length ? hit[0] : null;
      }
      """

  Scenario: Managing users requires manage access
    * def editor = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(editor)', access: 'edit' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers asUser(editor)
    And request [{ user: { id: '#(uuid())' }, access: 'view' }]
    When method POST
    Then status 403

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    And request [{ user: { id: '#(uuid())' }, access: 'view' }]
    When method POST
    Then status 200
    And match response == '#[_ > 0]'

  Scenario: A new grant takes its weight from the target's dashboard count
    * def newcomer = uuid()

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    And request [{ user: { id: '#(newcomer)' }, access: 'view' }]
    When method POST
    Then status 200
    * def grant = accessOf(response, newcomer)
    * match grant.access.value == 'view'
    # The newcomer owned nothing, so the shared board becomes their default.
    * match grant.userDashboardWeight == 0
    * match grant.defaultUserDashboard == true

    # A user who already owns two dashboards gets the next weight and no
    # default flag.
    * def established = uuid()
    * call read(setupPath + 'dashboard.feature@create') { user: '#(established)', name: 'Own board one' }
    * call read(setupPath + 'dashboard.feature@create') { user: '#(established)', name: 'Own board two' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    And request [{ user: { id: '#(established)' }, access: 'edit' }]
    When method POST
    Then status 200
    * def establishedGrant = accessOf(response, established)
    * match establishedGrant.userDashboardWeight == 2
    * match establishedGrant.defaultUserDashboard == false

  Scenario: Duplicate and self grants are ignored
    * def guest = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(guest)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    And request [{ user: { id: '#(guest)' }, access: 'manage' }, { user: { id: '#(owner)' }, access: 'view' }]
    When method POST
    Then status 200
    # Neither item applied: the guest keeps view, the manager keeps manage.
    * def guestAccess = accessOf(response, guest)
    * def ownerAccess = accessOf(response, owner)
    * match guestAccess.access.value == 'view'
    * match ownerAccess.access.value == 'manage'
    * match response == '#[2]'

  Scenario: Re-posting an existing item changes only the access level
    * def guest = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(guest)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    When method GET
    Then status 200
    * def guestAccess = accessOf(response, guest)
    * def guestAccessId = guestAccess.id
    * def originalWeight = guestAccess.userDashboardWeight

    # The weight in the payload is ignored — only the level is editable here.
    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    And request [{ id: '#(guestAccessId)', user: { id: '#(guest)' }, access: 'edit', userDashboardWeight: 99 }]
    When method POST
    Then status 200
    * def updated = accessOf(response, guest)
    * match updated.access.value == 'edit'
    * match updated.userDashboardWeight == originalWeight

  Scenario: An item flagged _delete removes the grant
    * def guest = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(guest)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    When method GET
    Then status 200
    * def guestAccessId = accessOf(response, guest).id

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    And request [{ id: '#(guestAccessId)', user: { id: '#(guest)' }, _delete: true }]
    When method POST
    Then status 200
    And match response[*].user.id !contains guest

    # The guest has lost the dashboard.
    Given path 'servint', 'dashboard', dashboardId
    And headers asUser(guest)
    When method GET
    Then status 403

  Scenario: The users list expands the access level but not the dashboard
    * def guest = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(guest)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response == '#[2]'
    And match each response contains { user: '#object', access: '#object', dashboard: '#object' }
    # Access is the expanded refdata value...
    * def guestAccess = accessOf(response, guest)
    * match guestAccess.access.value == 'view'
    * match guestAccess.access.label == 'View'
    # ... while the dashboard is an id-only reference in this render.
    * match guestAccess.dashboard.id == dashboardId
    * match guestAccess.dashboard.widgets == '#notpresent'
    * match guestAccess.dashboard.name == '##null'

  Scenario: A viewer may read the users list
    * def viewer = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(viewer)', access: 'view' }

    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers asUser(viewer)
    When method GET
    Then status 200
    And match response == '#[2]'

    # ... but a stranger may not.
    Given path 'servint', 'dashboard', dashboardId, 'users'
    And headers asUser(uuid())
    When method GET
    Then status 403
