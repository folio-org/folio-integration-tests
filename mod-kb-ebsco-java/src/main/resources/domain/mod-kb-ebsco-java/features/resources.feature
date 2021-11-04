Feature: Resources

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:domain/mod-kb-ebsco-java/features/samples/resources/'

    * def credentialId = karate.properties['credentialId']
    * def packageWithoutTitleId = karate.properties['packageId']
    * def packageId = karate.properties['titlesPackageId']
    * def titleId = karate.properties['titleId']

  @Positive
  Scenario: POST Resources with 200 on success
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

    #waiting for resources creation
    * eval sleep(20000)
    * def resourcesId = response.data.id

    #destroy recourse
    Given path '/eholdings/resources', resourcesId
    When method DELETE
    Then status 204
    * eval sleep(20000)

  @Positive
  Scenario: GET Resource by id with 200 on success
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

    #waiting for resources creation
    * eval sleep(20000)
    * def resourcesId = response.data.id

    Given path '/eholdings/resources', resourcesId
    When method GET
    Then status 200
    And match response.data.id contains packageWithoutTitleId + '-' + titleId

    #destroy recourse
    Given path '/eholdings/resources', resourcesId
    When method DELETE
    Then status 204
    * eval sleep(20000)

  @Positive
  Scenario: DELETE Resource by id with 204 on success
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

    #waiting for resources creation
    * eval sleep(20000)
    * def resourcesId = response.data.id

    #destroy recourse
    Given path '/eholdings/resources', resourcesId
    When method DELETE
    Then status 204
    * eval sleep(20000)

  @Negative
  Scenario: PUT Resource by id with 200 on success
    * print 'undefined'

  @Positive
  Scenario: PUT Tags assigned to Resource by id with 200 on success
    * print 'undefined'

  @Positive
  Scenario: POST Fetch resources in bulk with 200 on success
    * def resourcesId = uuid()
    Given path '/eholdings/resources/bulk/fetch'
    And request read(samplesPath + 'bulkFetch.json')
    When method POST
    Then status 200
    And match response.included[0].id == resourcesId

  @Negative
  Scenario: GET Resource by id should return 400 if id is invalid
    * def wrongId = 'WRONG_ID'
    Given path '/eholdings/resources', wrongId
    When method GET
    Then status 400
    And match response.errors[0].title == 'Resource id is invalid - ' + wrongId

  @Negative
  Scenario: POST Fetch resources in bulk should return 422 if id format is invalid
    * def resourcesId = '413-3757-9g04662'
    Given path '/eholdings/resources/bulk/fetch'
    And request read(samplesPath + 'bulkFetch.json')
    When method POST
    Then status 422
    And match response.errors[0].message == 'elements in list must match pattern'

  @Negative
  Scenario: POST Fetch resources in bulk should return 422 if resources size more than 20
    Given path '/eholdings/resources/bulk/fetch'
    And request read(samplesPath + 'bulkFetchMoreThen20.json')
    When method POST
    Then status 422
    And match response.errors[0].message == 'size must be between 0 and 20'

  @Negative
  Scenario: POST Resources should return 400 if Title id is invalid
    * def titleId = 'wrongTitleId'
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 400
    And match response.errors[0].title == 'Title id is invalid - ' + titleId

  @Negative
  Scenario: POST Resources should return 400 if Package id is invalid
    * def packageWithoutTitleId = 'wrongPackageId'
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 400
    And match response.errors[0].title == 'Package and provider id are required'

  @Negative
  Scenario: PUT Tags assigned to Resource by id should return 422 if name is invalid
    * print 'undefined'

  @Negative
  Scenario: PUT Resource by id should return 400 if Coverage list contain overlapping dates
    * print 'undefined'

  @Negative
  Scenario: PUT Resource by id should return 422 if coverage is invalid
    * print 'undefined'

  @Negative
  Scenario: DELETE Resource by id should return 400 if Resource is invalid
    Given path '/eholdings/resources/wrongId'
    When method DELETE
    Then status 400
    And match response.errors[0].title == 'Resource id is invalid - wrongId'