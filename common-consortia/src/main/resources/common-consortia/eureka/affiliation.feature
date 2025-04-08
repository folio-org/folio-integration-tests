Feature: Create affilitaion in api tests

  Background:
    * url kongUrl
    * configure retry = { count: 20, interval: 40000 }

  @AddAffiliation
  Scenario:
    # POST non-primary affiliation
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(token)'}
    And request { userId: '#(user.id)', tenantId :'#(tenant)'}
    When method POST
    Then status 200
    And match response.userId == user.id
    And match response.username contains user.username
    And match response.tenantId == tenant
    And match response.isPrimary == false