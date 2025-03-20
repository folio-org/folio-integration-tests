Feature: Create affilitaion in api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }

  # Parameters: Tenant tenant, User user, Consortium consortium String token, String[] modules Result: void
  @AddAffiliation
  Scenario:
    # POST non-primary affiliation
    Given path 'consortia', consortium.id, 'user-tenants'
    And headers {'x-okapi-tenant':'#(tenant.name)', 'x-okapi-token':'#(token)'}
    And request { userId: '#(user.id)', tenantId :'#(tenant.id)'}
    When method POST
    Then status 200
    And match response.userId == user.id
    And match response.username contains user.username
    And match response.tenantId == tenant.id
    And match response.isPrimary == false