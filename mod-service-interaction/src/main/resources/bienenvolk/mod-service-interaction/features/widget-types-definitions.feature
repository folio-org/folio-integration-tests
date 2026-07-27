Feature: Widget types and definitions

  # The catalog side of widgets: the WidgetType schemas the module ships, the
  # local WidgetDefinition store, and the permission-free `dashboard` interface
  # endpoint other modules harvest definitions from.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)

  Scenario: Widget types render plainly, one row per name and version
    Given path 'servint', 'widgets', 'types'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    And match each response contains { id: '#string', name: '#string', typeVersion: '#string' }
    * def simpleSearch = karate.filter(response, function (t) { return t.name == 'SimpleSearch' })
    * match simpleSearch == '#[1]'
    * match simpleSearch[0].typeVersion == '1.0'
    # The schema stays the persisted JSON string, not a parsed object.
    * match simpleSearch[0].schema == '#string'

  Scenario: Local widget definitions render name, version, type and a parsed definition
    * def definitionName = 'karate-def-' + suffix
    Given path 'servint', 'widgets', 'definitions'
    And headers actor
    And request
      """
      {
        name: '#(definitionName)',
        definitionVersion: '1.0',
        typeName: 'SimpleSearch',
        typeVersion: '1.0',
        definition: '{"baseUrl":"/erm/sas","results":{"columns":[{"name":"agreementName","label":"Name"}]}}'
      }
      """
    When method POST
    # Registered deviation D-2: the legacy module creates the row and answers
    # 201; the port never declared local-definition creation and answers 405 —
    # definitions reach it through widget-type import and federation only.
    Then match responseStatus == expect.definitionCreate
    # Nothing local to read back on the port.
    * if (impl != 'legacy') karate.abort()

    Given path 'servint', 'widgets', 'definitions'
    And headers actor
    And param filters = 'name==' + definitionName
    And param perPage = 10
    When method GET
    Then status 200
    And match response == '#[1]'
    * def definition = response[0]
    * match definition.name == definitionName
    # definitionVersion renders as `version`, and the type is nested.
    * match definition.version == '1.0'
    * match definition.type == { name: 'SimpleSearch', version: '1.0' }
    # The stored JSON string renders as a parsed object...
    * match definition.definition.baseUrl == '/erm/sas'
    # ... and the entity id is never on the wire.
    * match definition.id == '#notpresent'

  Scenario: The dashboard interface serves the same definitions without permissions
    * def definitionName = 'karate-iface-' + suffix
    Given path 'servint', 'widgets', 'definitions'
    And headers actor
    And request
      """
      {
        name: '#(definitionName)',
        definitionVersion: '2.1',
        typeName: 'SimpleSearch',
        typeVersion: '1.0',
        definition: '{"baseUrl":"/erm/sas"}'
      }
      """
    When method POST
    Then match responseStatus == expect.definitionCreate
    * if (impl != 'legacy') karate.abort()

    # /dashboard/definitions is this module's implementation of the `dashboard`
    # 1.0 interface: GET only, no servint permission required, same render.
    Given path 'dashboard', 'definitions'
    And headers actor
    When method GET
    Then status 200
    * def served = karate.filter(response, function (d) { return d.name == definitionName })
    * match served == '#[1]'
    * match served[0].version == '2.1'
    * match served[0].type == { name: 'SimpleSearch', version: '1.0' }

  Scenario: Both definition read surfaces answer on the port
    # The two scenarios above stop at the D-2 405, so without this one the
    # port side of the definition surface would never be exercised at all.
    # Nothing can be created there (definitions reach the port through
    # widget-type import and federation only), so the row set is whatever the
    # tenant holds — the render shape and the permission-free interface route
    # are what get pinned.
    * if (impl != 'port') karate.abort()

    Given path 'servint', 'widgets', 'definitions'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#array'
    And match each response contains { name: '#string', version: '#string', type: '#object' }

    Given path 'dashboard', 'definitions'
    And headers actor
    When method GET
    Then status 200
    And match response == '#array'
    And match each response contains { name: '#string', version: '#string', type: '#object' }

  Scenario: Fetching an unknown definition answers 404
    Given path 'servint', 'widgets', 'definitions', uuid()
    And headers actor
    When method GET
    Then status 404

  Scenario: The global collection federates definitions across modules
    # Federation queries every module implementing the `dashboard` interface
    # through Okapi, so it only means something when the module under test sits
    # behind a gateway. Enable with -Dfederation=true.
    * if (!federationEnabled) karate.abort()

    Given path 'servint', 'widgets', 'definitions', 'global'
    And headers actor
    When method GET
    Then status 200
    And match response == '#array'
    # Every harvested definition carries the local render shape.
    And match each response contains { name: '#string', version: '#string', type: '#object' }
