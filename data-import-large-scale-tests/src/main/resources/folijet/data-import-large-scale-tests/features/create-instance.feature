Feature: Create instance

  Background:
    * url baseUrl

    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

  Scenario: FAT-17607 Create instance and save MARC-BIB
    * print 'Create instance and save MARC-BIB'

    Given path 'authn/login-with-expiry'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    And header Authtoken-Refresh-Cache = true
    And request { username: '#(name)', password: '#(password)' }
    When method POST
    Then status 201
    * def okapitoken = responseCookies['folioAccessToken'].value
    * def refreshToken = responseCookies['folioRefreshToken'].value
    * configure cookies = null

    * print 'Create instance and save MARC-BIB', response