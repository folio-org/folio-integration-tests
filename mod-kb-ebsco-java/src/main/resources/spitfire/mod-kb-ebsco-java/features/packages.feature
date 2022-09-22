Feature: Packages

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/samples/packages/'

    * def existPackageId = karate.properties['packageId']

#   ================= positive test cases =================

  Scenario: Get all Packages
    Given path "/eholdings/packages"
    When method GET
    Then status 200
    And match responseType == 'json'

  Scenario: GET all custom Packages with 200 on success
    Given path "/eholdings/packages"
    And param filter[custom] = true
    When method GET
    Then status 200
    And match response.data[0].attributes.isCustom == true

  Scenario: POST Packages should create a custom package with 200 on success
    Given path "/eholdings/packages"
    When method GET
    Then status 200
    And def initial_num_records = response.meta.totalResults

    Given path "/eholdings/packages"
    And def packageName = random_string()
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    #waiting for package creation
    * eval sleep(15000)

    Given path "/eholdings/packages"
    And retry until response.meta.totalResults == initial_num_records + 1
    When method GET
    Then status 200

    #destroy package
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

    #should not find deleted package
    Given path '/eholdings/packages', packageId
    When method GET
    Then status 404

  Scenario: GET Package by id with 200 on success
    Given path '/eholdings/packages', existPackageId
    When method GET
    Then status 200
    And match response.data.id == existPackageId

  Scenario: PUT Package by id with 200 on success
    Given path '/eholdings/packages'
    And def randomPrefix = random_string()
    And def packageName = randomPrefix + 'TEST_PACKAGE_BEFORE_UPDATE'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    And def packageName = randomPrefix + 'UPDATED_TEST_PACKAGE'
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And request requestEntity
    When method PUT
    Then status 200

    Given path '/eholdings/packages', packageId
    When method GET
    Then status 200
    And match response.data.attributes.name == requestEntity.data.attributes.name

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: DELETE Package by id with 204 on success
    Given path '/eholdings/packages'
    And def randomPrefix = random_string()
    And def packageName = randomPrefix + 'PACKAGE_FOR_REMOVING'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  Scenario: PUT Tags by Package id with 200 on success
    Given path '/eholdings/packages/', existPackageId, 'tags'
    And request read(samplesPath + 'tags.json')
    When method PUT
    Then status 200

  Scenario: POST Fetch packages in bulk with 200 on success
    Given path '/eholdings/packages/bulk/fetch'
    And request read(samplesPath + 'bulkFetchPackages.json')
    When method POST
    Then status 200

#   ================= negative test cases =================

  Scenario: GET all Packages should return 400 if filter parameter is invalid
    Given path "/eholdings/packages"
    And param filter[custom] = 'null'
    When method GET
    Then status 400

  Scenario: POST Packages should return 400 if Package with the provided name already exists
    Given path '/eholdings/packages', existPackageId
    When method GET
    Then status 200
    And def packageName = response.data.attributes.name

    Given path '/eholdings/packages'
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 400

  Scenario: POST Packages should return 422 if name is empty
    Given path '/eholdings/packages'
    And def packageName = ' '
    And request read(samplesPath + 'createPackage.json')
    When method POST
    Then status 422

  Scenario: GET Package by id should return 400 if Package or provider id are invalid
    Given path '/eholdings/packages/wrongId'
    When method GET
    Then status 400

  Scenario: PUT Package by id should return 400 if Attribute is missing
    Given path '/eholdings/packages', existPackageId
    And def packageName = random_string()
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And remove requestEntity.data.attributes.isSelected
    And request requestEntity
    When method PUT
    Then status 400

  Scenario: PUT Package by id should return 422 if Coverage is invalid
    Given path '/eholdings/packages', existPackageId
    And def packageName = random_string()
    And def requestEntity = read(samplesPath + 'updatePackage.json')
    And set requestEntity.data.attributes.customCoverage.beginCoverage = ' '
    And request requestEntity
    When method PUT
    Then status 422

  Scenario: DELETE Package by id should return 400 if Package id is invalid
    Given path '/eholdings/packages/wrongId'
    When method DELETE
    Then status 400

  Scenario: PUT Tags assigned to Provider by id should return 422 if name is not provided
    Given path '/eholdings/packages/', existPackageId, 'tags'
    And def requestEntity = read(samplesPath + 'tags.json')
    And set requestEntity.data.attributes.name = ''
    And request requestEntity
    When method PUT
    Then status 422

  Scenario: POST Fetch packages in bulk should return 422 if id format is invalid
    Given path '/eholdings/packages/bulk/fetch'
    And def requestEntity = read(samplesPath + 'bulkFetchPackages.json')
    And set requestEntity.packages[0] = 'wrongId'
    And request requestEntity
    When method POST
    Then status 422