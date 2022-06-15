Feature: Setup resources

  Background:
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)'}
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/setup/samples/'

  @SetupPackage
  Scenario: Create package
    Given path '/eholdings/packages'
    And headers vndHeaders
    And def packageName = random_string()
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200

    * setSystemProperty('packageId', response.data.id)
    * eval sleep(10000)

#    Given path '/eholdings/packages', packageId
#    And request read(samplesPath + 'updatedPackage.json')
#    And headers vndHeaders
#    When method PUT
#    Then status 200

  @SetupResources
  Scenario: Create resources
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
