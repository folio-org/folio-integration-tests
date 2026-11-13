Feature: mgr-tenants - tenant attributes

  # Happy path for: POST /tenants/{tenantId}/tenant-attributes, GET /tenants/{tenantId}/tenant-attributes,
  # GET /tenants/{tenantId}/tenant-attributes/{id}, PUT /tenants/{tenantId}/tenant-attributes/{id},
  # DELETE /tenants/{tenantId}/tenant-attributes/{id}
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
  Scenario: create, get, list, update and delete tenant attributes
    * def tenantName = 'ittenantattr' + suffix
    * def keyA = 'it-key-a-' + suffix
    * def keyB = 'it-key-b-' + suffix

    Given path 'tenants'
    And request { name: '#(tenantName)' }
    When method post
    Then status 201
    * def tenantId = response.id
    * karate.appendTo('createdTenantIds', tenantId)

    # the new tenant has no attributes
    Given path 'tenants', tenantId, 'tenant-attributes'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.tenantAttributes == []

    # create attributes
    Given path 'tenants', tenantId, 'tenant-attributes'
    And request { tenantAttributes: [ { key: '#(keyA)', value: 'value-a' }, { key: '#(keyB)', value: 'value-b' } ] }
    When method post
    Then status 201
    And match response.tenantAttributes == '#[2]'
    And match response.tenantAttributes[*].key contains only [ '#(keyA)', '#(keyB)' ]

    # list attributes
    Given path 'tenants', tenantId, 'tenant-attributes'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.tenantAttributes == '#[2]'
    * def attributeA = karate.filter(response.tenantAttributes, function(a) { return a.key == keyA })[0]
    * def attributeB = karate.filter(response.tenantAttributes, function(a) { return a.key == keyB })[0]
    And match attributeA.id == '#uuid'
    And match attributeA.value == 'value-a'
    And match attributeB.id == '#uuid'
    And match attributeB.value == 'value-b'

    # list attributes with CQL query and pagination
    Given path 'tenants', tenantId, 'tenant-attributes'
    And param query = 'key==' + keyA
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.tenantAttributes[0].id == attributeA.id

    Given path 'tenants', tenantId, 'tenant-attributes'
    And param offset = 0
    And param limit = 1
    When method get
    Then status 200
    And match response.tenantAttributes == '#[1]'
    And match response.totalRecords == 2

    # get attribute by id
    Given path 'tenants', tenantId, 'tenant-attributes', attributeA.id
    When method get
    Then status 200
    And match response.id == attributeA.id
    And match response.key == keyA
    And match response.value == 'value-a'

    # update attribute
    Given path 'tenants', tenantId, 'tenant-attributes', attributeA.id
    And request { id: '#(attributeA.id)', key: '#(keyA)', value: 'value-a-updated' }
    When method put
    Then status 200
    And match response.id == attributeA.id
    And match response.key == keyA
    And match response.value == 'value-a-updated'

    Given path 'tenants', tenantId, 'tenant-attributes', attributeA.id
    When method get
    Then status 200
    And match response.value == 'value-a-updated'

    # delete attribute
    Given path 'tenants', tenantId, 'tenant-attributes', attributeA.id
    When method delete
    Then status 204

    Given path 'tenants', tenantId, 'tenant-attributes', attributeA.id
    When method get
    Then status 404

    Given path 'tenants', tenantId, 'tenant-attributes'
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.tenantAttributes[0].id == attributeB.id
