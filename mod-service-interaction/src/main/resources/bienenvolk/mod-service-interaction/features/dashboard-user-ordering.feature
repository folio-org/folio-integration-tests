Feature: Dashboard user ordering

  # Bulk update of the caller's OWN access objects: personal ordering weight
  # and the single-default invariant. The whole request is validated before
  # anything is applied — one bad item rejects the batch.

  Background:
    * url baseUrl
    * def owner = uuid()
    * def ownerHeaders = asUser(owner)
    * call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Board one' }
    * call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Board two' }
    * call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Board three' }
    * def myDashboards =
      """
      function () {
        return karate.call(setupPath + 'dashboard.feature@provision', { user: owner }).accessObjects;
      }
      """
    * def named =
      """
      function (accessObjects, name) {
        var hit = karate.filter(accessObjects, function (a) { return a.dashboard.name == name });
        return hit.length ? hit[0] : null;
      }
      """

  Scenario: The caller reorders their own dashboards by weight
    * def before = myDashboards()
    * match before == '#[3]'
    * def one = named(before, 'Board one')
    * def three = named(before, 'Board three')
    * match one.userDashboardWeight == 0
    * match three.userDashboardWeight == 2

    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    And request
      """
      [
        { id: '#(one.id)', user: { id: '#(owner)' }, userDashboardWeight: 5 },
        { id: '#(three.id)', user: { id: '#(owner)' }, userDashboardWeight: 1 }
      ]
      """
    When method PUT
    Then status 200
    * def after = named(response, 'Board one')
    * def afterThree = named(response, 'Board three')
    * match after.userDashboardWeight == 5
    * match afterThree.userDashboardWeight == 1

  Scenario: Electing a new default clears the previous one
    * def before = myDashboards()
    * def one = named(before, 'Board one')
    * def two = named(before, 'Board two')
    * match one.defaultUserDashboard == true
    * match two.defaultUserDashboard == false

    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    And request [{ id: '#(two.id)', user: { id: '#(owner)' }, defaultUserDashboard: true }]
    When method PUT
    Then status 200
    * def afterOne = named(response, 'Board one')
    * def afterTwo = named(response, 'Board two')
    * match afterTwo.defaultUserDashboard == true
    * match afterOne.defaultUserDashboard == false
    # Exactly one default survives.
    * def defaults = karate.filter(response, function (a) { return a.defaultUserDashboard == true })
    * match defaults == '#[1]'

  Scenario: An item without an id rejects the whole request
    * def before = myDashboards()
    * def one = named(before, 'Board one')

    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    And request
      """
      [
        { id: '#(one.id)', user: { id: '#(owner)' }, userDashboardWeight: 9 },
        { user: { id: '#(owner)' }, userDashboardWeight: 8 }
      ]
      """
    When method PUT
    Then status 400

    # Nothing was applied — the valid item in the same batch did not land.
    * def after = named(myDashboards(), 'Board one')
    * match after.userDashboardWeight == one.userDashboardWeight

  Scenario: An item naming another user rejects the whole request
    * def before = myDashboards()
    * def one = named(before, 'Board one')
    * def stranger = uuid()

    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    And request
      """
      [
        { id: '#(one.id)', user: { id: '#(owner)' }, userDashboardWeight: 9 },
        { id: '#(one.id)', user: { id: '#(stranger)' }, userDashboardWeight: 8 }
      ]
      """
    When method PUT
    Then status 403

    * def after = named(myDashboards(), 'Board one')
    * match after.userDashboardWeight == one.userDashboardWeight

  Scenario: An item whose id matches no access object is ignored
    Given path 'servint', 'dashboard', 'my-dashboards'
    And headers ownerHeaders
    And request [{ id: '#(uuid())', user: { id: '#(owner)' }, userDashboardWeight: 4 }]
    When method PUT
    Then status 200
    # The response is simply the caller's refreshed list — no dashboard was
    # created through the ordering endpoint.
    And match response == '#[3]'
