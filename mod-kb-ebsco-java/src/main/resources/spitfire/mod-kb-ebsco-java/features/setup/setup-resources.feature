Feature: Setup resources

  Background:
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)'}
    * def jsonHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)'}
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/setup/samples/'

  @SetupPackage
  Scenario: Create package with Agreements and Notes
    Given path '/eholdings/packages'
    And headers vndHeaders
    And def packageName = random_string()
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    * setSystemProperty('packageId', packageId)
    * eval sleep(10000)

    #Assign agreement
    Given path '/erm/sas'
    And headers jsonHeaders
    And def recordId = packageId
    And def recordType = 'EKB-PACKAGE'
    And def agreementName = 'Package Agreement'
    And request read(samplesPath + 'agreements.json')
    When method POST
    Then status 201

    #Assign notes
    Given path '/notes'
    And headers jsonHeaders
    And request read(samplesPath + 'notes.json')
    When method POST
    Then status 201

  @SetupResources
  Scenario: Create resource
    #create package for resources
    Given path '/eholdings/packages'
    And headers vndHeaders
    And def packageName = random_string()
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    * setSystemProperty('packageForResourceId', packageId)
    * eval sleep(10000)

    #create title for resources
    Given path '/eholdings/titles'
    And headers vndHeaders
    And def titleName = random_string()
    And request read(samplesPath + 'title.json')
    When method POST
    Then status 200
    And def titleId = response.data.id

    * setSystemProperty('titleId', titleId)

    #create resources
    Given path '/eholdings/resources'
    And headers vndHeaders
    And request read(samplesPath + 'resources.json')
    When method POST
    Then status 200
    And def resourceId = response.data.id

    * setSystemProperty('resourceId', resourceId)
    * eval sleep(10000)

    #Assign agreement
    Given path '/erm/sas'
    And headers jsonHeaders
    And def recordId = resourceId
    And def recordType = 'EKB-TITLE'
    And def agreementName = 'Resource Agreement'
    And request read(samplesPath + 'agreements.json')
    When method POST
    Then status 201

    #Assign notes
    Given path '/notes'
    And headers jsonHeaders
    And request read(samplesPath + 'notes.json')
    When method POST
    Then status 201

