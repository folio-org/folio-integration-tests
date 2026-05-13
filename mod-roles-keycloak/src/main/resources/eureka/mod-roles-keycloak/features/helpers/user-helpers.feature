Feature: Shared user helpers for mod-roles-keycloak Karate tests

  Background:
    * url baseUrl

  @ignore @createAdditionalUser
  Scenario: createAdditionalUser
    * def callerHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * def resolvedUserPassword = karate.get('userPassword') || 'test'
    * def additionalUser =
      """
      {
        "tenant": "#(testTenant)",
        "name": "#(userName)",
        "password": "#(resolvedUserPassword)"
      }
      """
    * configure headers = null
    * def createUserResult = call read('classpath:common/eureka/create-additional-user.feature') { testUser: #(additionalUser), userPermissions: #(userPermissions) }
    * configure headers = callerHeaders
    * def userId = createUserResult.userId
