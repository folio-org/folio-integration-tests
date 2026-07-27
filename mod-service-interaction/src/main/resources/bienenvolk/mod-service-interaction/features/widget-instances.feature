Feature: Widget instances

  # Widgets placed on a dashboard. Authorization is derived entirely from the
  # OWNING dashboard's access level: view to read, edit to create, change or
  # remove. Weights are auto-assigned when the caller does not supply one.

  Background:
    * url baseUrl
    * def owner = uuid()
    * def ownerHeaders = asUser(owner)
    * def created = call read(setupPath + 'dashboard.feature@create') { user: '#(owner)', name: 'Widget board' }
    * def dashboardId = created.dashboardId
    * def viewer = uuid()
    * call read(setupPath + 'dashboard.feature@grant') { user: '#(owner)', dashboardId: '#(dashboardId)', target: '#(viewer)', access: 'view' }
    * def instanceFor =
      """
      function (name, dashId) {
        return {
          name: name,
          definitionName: 'karate-def',
          definitionVersion: '1.0',
          configuration: '{"filters":[]}',
          owner: { id: dashId }
        };
      }
      """

  Scenario: Creating an instance needs an existing dashboard and edit access
    # An owner id that names no dashboard.
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Orphan', uuid())
    When method POST
    Then status 404

    # A viewer on a real dashboard may not place widgets on it.
    Given path 'servint', 'widgets', 'instances'
    And headers asUser(viewer)
    And request instanceFor('Not allowed', dashboardId)
    When method POST
    Then status 403

    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Allowed', dashboardId)
    When method POST
    Then status 201
    And match response.name == 'Allowed'
    # definitionName/definitionVersion render as a nested definition object.
    And match response.definition == { name: 'karate-def', version: '1.0' }

  Scenario: A null weight is auto-assigned, an explicit one is kept
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('First widget', dashboardId)
    When method POST
    Then status 201
    # The first widget on an empty dashboard sits at zero.
    And match response.weight == 0

    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Second widget', dashboardId)
    When method POST
    Then status 201
    # Then the highest existing weight plus one.
    And match response.weight == 1

    * def explicit = instanceFor('Third widget', dashboardId)
    * set explicit.weight = 7
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request explicit
    When method POST
    Then status 201
    And match response.weight == 7

  Scenario: Reading an instance needs view access on its dashboard
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Readable', dashboardId)
    When method POST
    Then status 201
    * def instanceId = response.id

    Given path 'servint', 'widgets', 'instances', instanceId
    And headers asUser(viewer)
    When method GET
    Then status 200
    And match response.name == 'Readable'

    Given path 'servint', 'widgets', 'instances', instanceId
    And headers asUser(uuid())
    When method GET
    Then status 403

  Scenario: Updating and deleting an instance need edit access
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Editable', dashboardId)
    When method POST
    Then status 201
    * def instanceId = response.id
    * def payload = instanceFor('Renamed', dashboardId)

    Given path 'servint', 'widgets', 'instances', instanceId
    And headers asUser(viewer)
    And request payload
    When method PUT
    Then status 403

    Given path 'servint', 'widgets', 'instances', instanceId
    And headers ownerHeaders
    And request payload
    When method PUT
    Then status 200
    And match response.name == 'Renamed'

    Given path 'servint', 'widgets', 'instances', instanceId
    And headers asUser(viewer)
    When method DELETE
    Then status 403

    Given path 'servint', 'widgets', 'instances', instanceId
    And headers ownerHeaders
    When method DELETE
    Then status 204

    # Gone from its dashboard. (Fetching a deleted instance by id is the
    # unknown-id path, where legacy and the port answer differently — that is
    # pinned once, in error-envelopes.feature.)
    Given path 'servint', 'dashboard', dashboardId, 'widgets'
    And headers ownerHeaders
    When method GET
    Then status 200
    And match response[*].id !contains instanceId

  Scenario: A dashboard lists its own widgets to anyone who can view it
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Listed one', dashboardId)
    When method POST
    Then status 201

    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Listed two', dashboardId)
    When method POST
    Then status 201

    Given path 'servint', 'dashboard', dashboardId, 'widgets'
    And headers asUser(viewer)
    When method GET
    Then status 200
    And match response == '#[2]'
    And match response[*].name contains only ['Listed one', 'Listed two']
    And match each response contains { definition: { name: 'karate-def', version: '1.0' } }

    Given path 'servint', 'dashboard', dashboardId, 'widgets'
    And headers asUser(uuid())
    When method GET
    Then status 403

  Scenario: The full instance index is reserved to the admin override
    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And request instanceFor('Indexed', dashboardId)
    When method POST
    Then status 201

    Given path 'servint', 'widgets', 'instances'
    And headers ownerHeaders
    And param perPage = 100
    When method GET
    Then status 403

    Given path 'servint', 'widgets', 'instances'
    And headers asAdmin(uuid())
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
