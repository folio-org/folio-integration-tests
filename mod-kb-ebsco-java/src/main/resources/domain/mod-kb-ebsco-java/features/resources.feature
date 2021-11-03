Feature: Resources

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

    * def credential = callonce read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupCredentials')
    * def credentialId = credential.credentialId

#    * def package = call read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupPackage')
    * def package = call read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupPackage')
    * def packageId = package.packageId

    * def samplesPath = 'classpath:domain/mod-kb-ebsco-java/features/samples/resources/'
    * def title = callonce read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupTitle')
    * def titleId = title.titleId

    * def packageWithoutTitle = call read('classpath:domain/mod-kb-ebsco-java/features/setup/setup.feature@SetupPackage')
    * def packageWithoutTitleId = packageWithoutTitle.packageId


  Scenario: POST Resources with 200 on success
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

    #waiting for resources creation
    * eval sleep(20000)
    * def resourcesId = response.data.id

    #destroy recourse
    Given call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyResource') {resourcesId: #(resourcesId)}

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

    #destroy recourse
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyResource') {resourcesId: #(resourcesId)}

  @Negative
  Scenario: GET Resource by id should return 400 if id is invalid
    Given path '/eholdings/resources/wrongId'
    When method GET
    Then status 400

  @Undefined
  Scenario: GET Resource by id should return 404 if Title not found
    * print 'undefined'

  @Undefined
  Scenario: POST Resource by id should return 400 if Coverage list contain overlapping dates
    * print 'undefined'

  @Undefined
  Scenario: POST Resource by id should return 422 if coverage is invalid
    * print 'undefined'

  Scenario: DELETE Resource by id with 204 on success
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

    #waiting for resources creation
    * eval sleep(20000)
    * def resourcesId = response.data.id

    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyResource') {resourcesId: #(resourcesId)}

  Scenario: DELETE Resource by id should return 400 if Resource is invalid
    Given path '/eholdings/resources/wrongId'
    When method DELETE
    Then status 400
    And match response.errors[0].title == 'Resource id is invalid - wrongId'

  @Undefined
  Scenario: PUT Tags assigned to Resource by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Resource by id should return 422 if name is invalid
    * print 'undefined'

  Scenario: POST Fetch resources in bulk with 200 on success
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

#    #waiting for resources creation
    * eval sleep(10000)
    * def resourcesId = response.data.id

    Given path '/eholdings/resources/bulk/fetch'
    And request
    """
    {
	  "resources": ["#(resourcesId)"]
    }
    """
    When method POST
    Then status 200
    And match response.included[0].id == resourcesId

    #    #destroy recourse
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyResource') {resourcesId: #(resourcesId)}

  @Negative
  Scenario: POST Fetch resources in bulk with invalid id should return 400
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200

#    #waiting for resources creation
    * eval sleep(10000)
    * def resourcesId = response.data.id

    Given path '/eholdings/resources/bulk/fetch'
    And request
    """
    {
	  "resources": ["413-3757-9g04662"]
    }
    """
    When method POST
    Then status 422
    And match response.errors[0].message == 'elements in list must match pattern'
    #    #destroy recourse
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyResource') {resourcesId: #(resourcesId)}

  @Undefined
  Scenario: POST Fetch resources in bulk should return 422 if resources size more than 20
    * print 'undefined'

  @Negative
  Scenario: POST Resources should return 404 if Title not found (NOT WORKED)
    * def titleId = 'wrongTitleId'
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 404

  @Negative
  Scenario: POST Resources should return 400 if Package id is invalid
    Given path '/eholdings/resources'
    And def packageId = 'wrongId'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 400
    And match response.errors[0].title == 'Package and provider id are required'

  @Negative
  Scenario: POST Resources should return 404 if Package is not found
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyPackage') {packageId: #(packageId)}
    Given path '/eholdings/resources'
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 404
    And match response.errors[0].title == 'Title not found'

    #   ================= Destroy test fata =================

  Scenario: Destroy kb-credential and package
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyPackage') {packageId: #(packageId)}
    And call read('classpath:domain/mod-kb-ebsco-java/features/setup/destroy.feature@DestroyCredentials') {credentialId: #(credentialId)}
