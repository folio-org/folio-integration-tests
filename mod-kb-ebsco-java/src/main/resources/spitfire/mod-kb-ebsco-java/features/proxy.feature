Feature: Proxy

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/proxy/'

    * def credentialId = karate.properties['credentialId']

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
    And def proxyTypeId = '<n>'
    And def requestEntity = read(samplesPath + 'root-proxy.json')
    And request requestEntity
    When method PUT
    Then status 200

    #waiting for proxy updating
    * eval sleep(10000)

    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    When method GET
    Then status 200
    And match response.data.attributes.proxyTypeId == requestEntity.data.attributes.proxyTypeId

#   ================= negative test cases =================

  Scenario: PUT root proxy by KB credentials id should return 400 if proxyTypeId is invalid
    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    And def proxyTypeId = 'WrongTypeId'
    And def requestEntity = read(samplesPath + 'root-proxy.json')
    And request requestEntity
    When method PUT
    Then status 400

  Scenario: PUT root proxy by KB credentials id should return 422 if required attribute is missing
    Given path '/eholdings/kb-credentials', credentialId, 'root-proxy'
    And def requestEntity = read(samplesPath + 'root-proxy.json')
    And remove requestEntity.data.attributes.proxyTypeId
    And request requestEntity
    When method PUT
    Then status 422
