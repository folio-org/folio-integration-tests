Feature: Application settings

  # Web-toolkit AppSetting CRUD — the module's tenant-level configuration
  # surface (e.g. the number generator warning switches).

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)
    * def settingKey = 'displayWarnings' + suffix

  Scenario: Create, read, update and delete a setting
    Given path 'servint', 'settings', 'appSettings'
    And headers actor
    And request { section: 'numberGenerators', key: '#(settingKey)', settingType: 'String', value: 'one' }
    When method POST
    Then status 201
    * def settingId = response.id
    And match response contains { section: 'numberGenerators', key: '#(settingKey)', value: 'one' }

    Given path 'servint', 'settings', 'appSettings', settingId
    And headers actor
    When method GET
    Then status 200
    And match response.value == 'one'
    And match response.settingType == 'String'

    Given path 'servint', 'settings', 'appSettings', settingId
    And headers actor
    And request { value: 'two' }
    When method PUT
    Then status 200
    And match response.value == 'two'

    Given path 'servint', 'settings', 'appSettings', settingId
    And headers actor
    When method DELETE
    Then status 204

    Given path 'servint', 'settings', 'appSettings'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].key !contains settingKey

  Scenario: The settings collection renders the web-toolkit shape in a stats envelope
    Given path 'servint', 'settings', 'appSettings'
    And headers actor
    And request { section: 'karate', key: '#("hidden" + suffix)', settingType: 'Password', value: 's3cr3t', hidden: true }
    When method POST
    Then status 201

    Given path 'servint', 'settings', 'appSettings'
    And headers actor
    And param filters = 'section==karate'
    And param stats = true
    And param perPage = 100
    When method GET
    Then status 200
    And match response.totalRecords == '#number'
    And match response.results == '#[_ > 0]'
    And match each response.results contains { id: '#string', section: 'karate', key: '#string', settingType: '#string' }

  Scenario: Fetching an unknown setting answers 404
    Given path 'servint', 'settings', 'appSettings', uuid()
    And headers actor
    When method GET
    Then status 404
