Feature: Resources

  Background:
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/resources/'

    * def existResourceId = karate.properties['resourceId']
    * def resourcePackageId = karate.properties['packageForResourceId']
    * def freePackageId = karate.properties['packageId']
    * def titleId = karate.properties['titleId']

  @Positive
  Scenario: POST Resources with 200 on success
    * def packageWithoutTitleId = freePackageId
    Given path '/eholdings/resources'
    And headers vndHeaders
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

    #waiting for resources creation
    * eval sleep(10000)
    * def resourcesId = response.data.id

    #destroy recourse
    Given path '/eholdings/resources', resourcesId
    And headers vndHeaders
    When method DELETE
    Then status 204

  @Positive
  Scenario: GET Resource by id with 200 on success
    Given path '/eholdings/resources', existResourceId
    And headers vndHeaders
    When method GET
    Then status 200
    And match response.data.id contains resourcePackageId + '-' + titleId

  @Positive
  Scenario: PUT Resource by id with 200 on success
    Given path '/eholdings/resources', existResourceId
    And headers vndHeaders
    And def resourceUrl = 'http://updated.resources/' + random_string()
    And request read(samplesPath + 'updateResources.json')
    When method PUT
    Then status 200

    Given path '/eholdings/resources', existResourceId
    And headers vndHeaders
    When method GET
    Then status 200
    And match response.data.attributes.url == resourceUrl

  @Positive
  Scenario: PUT Tags assigned to Resource by id with 200 on success
    Given path '/eholdings/resources', existResourceId, 'tags'
    And headers vndHeaders
    And def tagsName = 'karateTags'
    And request read(samplesPath + 'tags.json')
    When method PUT
    Then status 200

  @Positive
  Scenario: POST Fetch resources in bulk with 200 on success
    * def resourcesId = '186-3150130-19087921'
    Given path '/eholdings/resources/bulk/fetch'
    And headers vndHeaders
    And request read(samplesPath + 'bulkFetch.json')
    When method POST
    Then status 200
    And match response.included[0].id == resourcesId

  @Negative
  Scenario: GET Resource by id should return 400 if id is invalid
    * def wrongId = 'WRONG_ID'
    Given path '/eholdings/resources', wrongId
    And headers vndHeaders
    When method GET
    Then status 400
    And match response.errors[0].title == 'Resource id is invalid - ' + wrongId

  @Negative
  Scenario: POST Fetch resources in bulk should return 422 if id format is invalid
    * def resourcesId = '413-3757-9g04662'
    Given path '/eholdings/resources/bulk/fetch'
    And headers vndHeaders
    And request read(samplesPath + 'bulkFetch.json')
    When method POST
    Then status 422
    And match response.errors[0].message == 'elements in list must match pattern'

  @Negative
  Scenario: POST Fetch resources in bulk should return 422 if resources size more than 20
    Given path '/eholdings/resources/bulk/fetch'
    And headers vndHeaders
    And request read(samplesPath + 'bulkFetchMoreThen20.json')
    When method POST
    Then status 422
    And match response.errors[0].message == 'size must be between 0 and 20'

  @Negative
  Scenario: POST Resources should return 400 if Title id is invalid
    * def titleId = 'wrongTitleId'
    Given path '/eholdings/resources'
    And headers vndHeaders
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 400
    And match response.errors[0].title == 'Title id is invalid - ' + titleId

  @Negative
  Scenario: POST Resources should return 400 if Package id is invalid
    * def packageWithoutTitleId = 'wrongPackageId'
    Given path '/eholdings/resources'
    And headers vndHeaders
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 400
    And match response.errors[0].title == 'Package and provider id are required'

  @Negative
  Scenario: PUT Tags assigned to Resource by id should return 422 if name is blank
    Given path '/eholdings/resources', existResourceId, 'tags'
    And headers vndHeaders
    And def tagsName = ' '
    And request read(samplesPath + 'tags.json')
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid name'
    And match response.errors[0].detail == 'name must not be empty'

  @Negative
  Scenario: PUT Tags assigned to Resource by id should return 422 if name is too long
    Given path '/eholdings/resources', existResourceId, 'tags'
    And headers vndHeaders
    And def tagsName = new Array(201).fill('1').join('')
    And request read(samplesPath + 'tags.json')
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid name'
    And match response.errors[0].detail == 'name is too long (maximum is 200 characters)'

  @Negative
  Scenario: PUT Resource by id should return 400 if Coverage list contain overlapping dates
    Given path '/eholdings/resources', existResourceId
    And headers vndHeaders
    And request read(samplesPath + 'resourcesOverlappingDates.json')
    When method PUT
    Then status 400
    And match response.errors[0].title == 'Title custom coverage date should be within the package custom coverage date limit'

  @Negative
  Scenario: PUT Resource by id should return 422 if coverage is invalid format
    Given path '/eholdings/resources', existResourceId
    And headers vndHeaders
    And def updateResources = read(samplesPath + 'resourcesOverlappingDates.json')
    And set updateResources.data.attributes.customCoverages[0].beginCoverage = " "
    And set updateResources.data.attributes.customCoverages[0].endCoverage = "2004-02-01"
    And request updateResources
    When method PUT
    Then status 422
    And match response.errors[0].title == 'Invalid beginCoverage'
    And match response.errors[0].detail == 'beginCoverage has invalid format. Should be YYYY-MM-DD'

  @Negative
  Scenario: DELETE Resource by id should return 400 if Resource is invalid
    Given path '/eholdings/resources/wrongId'
    And headers vndHeaders
    When method DELETE
    Then status 400
    And match response.errors[0].title == 'Resource id is invalid - wrongId'