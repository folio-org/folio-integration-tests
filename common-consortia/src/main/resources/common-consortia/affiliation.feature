Feature: Create affilitaion in api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }

  @AddAffiliation
  Scenario: Create tenant for consortia
    * def user = karate.get('user')
    * def tenant = karate.get('tenant')

    # POST non-primary affiliation
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers {'x-okapi-tenant':'#(centralTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request { userId: '#(user.id)', tenantId :'#(tenant)'}
    When method POST
    Then status 200
    And match response.userId == universityUser1.id
    And match response.username contains universityUser1.username
    And match response.tenantId == collegeTenant
    And match response.isPrimary == false