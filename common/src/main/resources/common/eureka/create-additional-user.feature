Feature: Create additional user
  # Parameters: testUser - attributes: tenant, name, password; userPermissions

Background:
  * url baseUrl

Scenario: searchApplication
  * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
  * call read('classpath:common/eureka/setup-users.feature@createTestUser')
  * call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials')
  * call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')
