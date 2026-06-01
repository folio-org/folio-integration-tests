Feature: verify consortia Keycloak-relevant behavior after Keycloak upgrade

  Background:
    * url baseUrl
    * configure cookies = null
    * configure retry = { count: 20, interval: 5000 }

  Scenario: verify non-primary affiliation can deactivate and reactivate a shadow user after upgrade
    # Log in through Keycloak as the central consortia admin.
    * call read('classpath:common-consortia/eureka/initData.feature@Login') consortiaAdmin
    * def centralToken = okapitoken
    * def memberAffiliationQuery = { userId: '#(consortiaUser.id)', tenantId: '#(memberTenant)' }

    # Delete the member affiliation after the upgrade; this drives mod-consortia-keycloak -> users-keycloak -> Keycloak user update.
    Given path 'consortia', consortiumId, 'user-tenants'
    And params query = memberAffiliationQuery
    And headers { 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(centralToken)' }
    When method delete
    Then status 204

    # Verify the shadow user was deactivated in the member tenant as a result of the Keycloak-aware update path.
    * call read('classpath:common-consortia/eureka/initData.feature@Login') memberAdmin
    * def memberToken = okapitoken
    Given path 'users', consortiaUser.id
    And headers { 'x-okapi-tenant': '#(memberTenant)', 'x-okapi-token': '#(memberToken)' }
    And retry until response.active == false
    When method get
    Then status 200
    And match response.id == consortiaUser.id
    And match response.username contains consortiaUser.username
    And match response.active == false
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == centralTenant

    # Re-add the member affiliation after the upgrade; this drives mod-consortia-keycloak -> users-keycloak -> Keycloak user update again.
    Given path 'consortia', consortiumId, 'user-tenants'
    And headers { 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(centralToken)' }
    And request { userId: '#(consortiaUser.id)', tenantId :'#(memberTenant)' }
    When method post
    Then status 200
    And match response.userId == consortiaUser.id
    And match response.username contains consortiaUser.username
    And match response.tenantId == memberTenant
    And match response.isPrimary == false

    # Verify the shadow user was reactivated in the member tenant as a result of the Keycloak-aware update path.
    Given path 'users', consortiaUser.id
    And headers { 'x-okapi-tenant': '#(memberTenant)', 'x-okapi-token': '#(memberToken)' }
    And retry until response.active == true
    When method get
    Then status 200
    And match response.id == consortiaUser.id
    And match response.username contains consortiaUser.username
    And match response.active == true
    And match response.type == 'shadow'
    And match response.customFields.originaltenantid == centralTenant
