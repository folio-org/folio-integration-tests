Feature: mgr-tenants - tenants

  # Happy path for: POST /tenants, GET /tenants, GET /tenants/{id}, PUT /tenants/{id}, DELETE /tenants/{id}
  # All names are randomized and everything created is removed in afterScenario.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * configure headers = { 'Authorization': '#("Bearer " + masterToken)', 'X-Okapi-Token': '#(masterToken)' }
    * def suffix = nowMillis() + uuid().substring(0, 4)

    * def createdTenantIds = []
    * configure afterScenario =
      """
      function() {
        karate.call('classpath:eureka/mgr-tenants/features/reusable/delete-tenants.feature',
          { tenantIds: karate.get('createdTenantIds'), masterToken: karate.get('masterToken') });
      }
      """

  @Positive
  Scenario: create, get, search, update and delete a tenant
    * def tenantName = 'ittenant' + suffix

    # create
    Given path 'tenants'
    And request { name: '#(tenantName)', description: 'created by karate' }
    When method post
    Then status 201
    And match response.id == '#uuid'
    And match response.name == tenantName
    And match response.description == 'created by karate'
    And match response.type == 'default'
    * def tenantId = response.id
    * karate.appendTo('createdTenantIds', tenantId)

    # get by id
    Given path 'tenants', tenantId
    When method get
    Then status 200
    And match response.id == tenantId
    And match response.name == tenantName
    And match response.description == 'created by karate'

    # search by CQL
    Given path 'tenants'
    And param query = 'name==' + tenantName
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.tenants == '#[1]'
    And match response.tenants[0].id == tenantId
    And match response.tenants[0].name == tenantName

    # list with pagination
    Given path 'tenants'
    And param offset = 0
    And param limit = 1
    When method get
    Then status 200
    And match response.tenants == '#[1]'
    And match response.totalRecords == '#number'

    # update
    Given path 'tenants', tenantId
    And request { id: '#(tenantId)', name: '#(tenantName)', description: 'updated by karate' }
    When method put
    Then status 200
    And match response.id == tenantId
    And match response.name == tenantName
    And match response.description == 'updated by karate'

    Given path 'tenants', tenantId
    When method get
    Then status 200
    And match response.description == 'updated by karate'

    # delete
    Given path 'tenants', tenantId
    When method delete
    Then status 204

    Given path 'tenants', tenantId
    When method get
    Then status 404

    Given path 'tenants'
    And param query = 'name==' + tenantName
    When method get
    Then status 200
    And match response.totalRecords == 0
