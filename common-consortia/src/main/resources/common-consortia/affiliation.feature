Feature: Create affilitaion in api tests

  Background:
    * url kongUrl
    * configure retry = { count: 20, interval: 40000 }

  @AddAffiliation
  Scenario: Create tenant for consortia
    # POST non-primary affiliation
    Given path 'user-tenants/', consortium.id
    And headers {'x-okapi-tenant':'#(tenant.name)', 'x-okapi-token':'#(token)'}
    And request { userId: '#(user.id)', tenantId :'#(tenant.id)'}
    When method POST
    Then status 200
    And match response.userId == user.id
    And match response.username contains user.username
    And match response.tenantId == collegeTenant
    And match response.isPrimary == false