Feature: Providers

  Background:
    * url baseUrl
    * call login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:promin/mod-kb-ebsco-java/features/samples/providers/'

    * def existProvider = read(samplesPath + 'existProvider.json')
    * def existPackageId = karate.properties['packageId']
    * def existPackageName = karate.properties['packageName']

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
    * def providerId = karate.properties['providerId']

    Given path '/eholdings/providers/', providerId, 'packages'
    And param filter[selected] = 'true'
    When method GET
    Then status 200
    And match response.data[0].attributes.isSelected == true

  Scenario: GET Provider by id with 200 on success
    * def providerId = karate.properties['providerId']

    Given path '/eholdings/providers', providerId
    When method GET
    Then status 200
    And match response.data.id == providerId
    And match response.data.type == 'providers'
    And match response.data.attributes.packagesTotal == '#? _ > 0'
    And match response.data.attributes.supportsCustomPackages == true

  Scenario: GET Packages associated with a given Provider searched by name with 200 on success
    * configure retry = { count: 10, interval: 5000 }
    * def providerId = karate.properties['providerId']

    Given path '/eholdings/providers/', providerId, 'packages'
    And param q = existPackageName
    And param q[field] = 'name'
    And param q[type] = 'exactphrase'
    And retry until response.meta.totalResults >= 1
    When method GET
    Then status 200
    And match response.data[*].id contains existPackageId

  Scenario: GET Packages associated with a given Provider filtered by selection and content type with 200 on success
    * def providerId = karate.properties['providerId']

    Given path '/eholdings/providers/', providerId, 'packages'
    And param filter[selected] = 'true'
    And param filter[type] = 'unknown'
    And param count = 5
    When method GET
    Then status 200
    And match response.data == '#[_ > 0]'
    And match each response.data[*].attributes contains { isSelected: true, contentType: 'Unknown' }

  Scenario: GET Packages associated with a given Provider paginated with 200 on success
    * def providerId = karate.properties['providerId']

    Given path '/eholdings/providers/', providerId, 'packages'
    And param sort = 'name'
    And param count = 1
    And param page = 1
    When method GET
    Then status 200
    And match response.data == '#[1]'
    And match each response.data[*].attributes.providerId == '#(parseInt(providerId))'

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

  Scenario Outline: GET Packages associated with a given Provider should return 400 if <param> is invalid
    Given path '/eholdings/providers/', existProvider.data.id, 'packages'
    And param <param> = '<value>'
    When method GET
    Then status 400
    And match response.errors[0].title == '<message>'

    Examples:
      | param             | value  | message                                           |
      | q[field]          | bogus  | Invalid Query Parameter for q[field]              |
      | q[type]           | bogus  | Invalid Query Parameter for q[type]               |
      | sort              | bogus  | Invalid Query Parameter for sort                  |
      | filter[selected]  | bogus  | Invalid Query Parameter for filter[selected]      |
      | filter[type]      | bogus  | Invalid Query Parameter for filter[type]          |
      | filter[access]    | bogus  | Invalid Query Parameter for filter[access]        |
