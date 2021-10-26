Feature: Proxy

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

    * def credential = callonce read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupCredentials')
    * def credentialId = credential.credentialId

#   ================= positive test cases =================

  Scenario: GET proxy types with 200 on success
    Given path '/eholdings/proxy-types'
    When method GET
    Then status 200

  Scenario: GET proxy types by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'proxy-types'
    When method GET
    Then status 200

  Scenario: GET root proxy with 200 on success
    Given path '/eholdings/root-proxy'
    When method GET
    Then status 200

  Scenario: GET root proxy by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    When method GET
    Then status 200

  Scenario: PUT root proxy by KB credentials id with 200 on success
    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    When method GET
    Then status 200
    And def proxy = response

    And set typeIdBeforeUpdate = proxy.data.attributes.proxyTypeId
    And set proxy.data.attributes.proxyTypeId = 'UpdatedTypeId'

    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    And request proxy
    When method PUT
    Then status 200

    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    When method GET
    Then status 200
    And match response.data.attributes.proxyTypeId != typeIdBeforeUpdate

#   ================= negative test cases =================

  Scenario: PUT root proxy by KB credentials id should return 422 if required attribute is missing
    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    When method PUT
    Then status 422

#   ================= destroy test data =================

  Scenario: Destroy kb-credential
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyCredentials') {credentialId: #(credentialId)}
