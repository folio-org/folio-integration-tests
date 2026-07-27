Feature: Admin actions

  # Maintenance actions dispatched by path segment. Each answers a constant
  # {status: "OK"} envelope and is safe to re-run.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())

  Scenario: Importing widget types is idempotent
    Given path 'servint', 'admin', 'triggerTypeImport'
    And headers actor
    When method GET
    Then status 200
    And match response.status == 'OK'

    Given path 'servint', 'widgets', 'types'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    * def afterFirst = karate.filter(response, function (t) { return t.name == 'SimpleSearch' })
    * match afterFirst == '#[1]'

    # A repeat import skips the (name, typeVersion) pairs already present
    # instead of duplicating them.
    Given path 'servint', 'admin', 'triggerTypeImport'
    And headers actor
    When method GET
    Then status 200
    And match response.status == 'OK'

    Given path 'servint', 'widgets', 'types'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    * def afterSecond = karate.filter(response, function (t) { return t.name == 'SimpleSearch' })
    * match afterSecond == '#[1]'
    * match afterSecond[0].id == afterFirst[0].id

  Scenario: A clean import replaces the whole type catalog
    Given path 'servint', 'admin', 'triggerTypeImportClean'
    And headers actor
    When method GET
    Then status 200
    And match response.status == 'OK'

    # Everything is deleted first and re-imported from the bundled sample data,
    # so the catalog is present again — with fresh rows.
    Given path 'servint', 'widgets', 'types'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    And match response[*].name contains 'SimpleSearch'

  Scenario: Ensuring display data repairs dashboards that lack it
    * def owner = uuid()
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Repaired board' }
    * def dashboardId = created.dashboardId

    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers asUser(owner)
    And request { layoutData: '{"kept":true}' }
    When method PUT
    Then status 200

    Given path 'servint', 'admin', 'ensureDisplayData'
    And headers actor
    When method GET
    Then status 200
    And match response.status == 'OK'

    # Existing rows are left exactly as they were.
    Given path 'servint', 'dashboard', dashboardId, 'displayData'
    And headers asUser(owner)
    When method GET
    Then status 200
    And match response.layoutData == '{"kept":true}'
