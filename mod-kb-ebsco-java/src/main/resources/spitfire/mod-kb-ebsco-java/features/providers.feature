Feature: Providers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/providers/'

    * def existProvider = read(samplesPath + 'existProvider.json')
    * def credentialId = karate.properties['credentialId']

#   ================= positive test cases =================

  Scenario: Get all Providers
    Given path "/eholdings/providers"
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: GET all Providers filtered by tags with 200 on success
    Given path "/eholdings/providers"
    And param filter[tags] = 'test'
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: PUT Provider by id with 200 on success
    And def providerToken = random_string() + "UPDATED_PROVIDER"
    And def providerToUpdate = read(samplesPath + 'updateProvider.json')

    Given path '/eholdings/providers', providerToUpdate.data.id
    And request providerToUpdate
    When method PUT
    Then status 200

  Scenario: PUT Tags assigned to Provider by id with 200 on success
    Given path '/eholdings/providers/', existProvider.data.id, 'tags'
    And request read(samplesPath + 'tags.json')
    When method PUT
    Then status 200

  Scenario: GET Packages associated with a given Provider with 200 on success
    Given path '/eholdings/providers/', existProvider.data.id, 'packages'
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: GET selected Packages associated with a given Provider with 200 on success
    Given path '/eholdings/providers/', existProvider.data.id, 'packages'
    And param filter[selected] = 'false'
    When method GET
    Then status 200
    And match response.data[0].attributes.isSelected == false

#   ================= negative test cases =================

  Scenario: PUT Tags assigned to Provider by id should return 422 if name is invalid
    Given path '/eholdings/providers/', existProvider.data.id, 'tags'
    And def invalidTags = read(samplesPath + 'tags.json')
    And set invalidTags.data.attributes.name = ' '
    And request invalidTags
    When method PUT
    Then status 422

  Scenario: GET Packages associated with a given Provider should return 400 if search parameter is empty
    Given path '/eholdings/providers/', existProvider.data.id, 'packages'
    And param q = ''
    When method GET
    Then status 400
