Feature: Setup kb-ebsco-java

  Background:
    * url baseUrl
    * def credentials = read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/credentials.json')

  @SetupCredentials
  Scenario: Create kb-credentials and assign user
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    And match responseType == 'json'
    And def credentialId = response.id

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And request read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/user.json')
    When method POST
    Then status 201

  @SetupPackage
  Scenario: Create package
    Given path '/eholdings/packages'
    And def packageName = random_string()
    And request read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/package.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

  @SetupTitle
  Scenario: Create title
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And request read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/title.json')
    When method POST
    Then status 200
    And def titleId = response.data.id
    * eval sleep(20000)