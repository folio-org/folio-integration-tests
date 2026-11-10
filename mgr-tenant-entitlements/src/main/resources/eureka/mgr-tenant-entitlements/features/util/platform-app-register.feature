Feature: register an application for the platform entitlement tests

  # Helper, not a test. Arguments: masterToken, name, version, scope (optional: 'platform' or 'regular'),
  # dependencies (optional: [{ name, version }]). Returns the application id in `id`.
  # The applications have no modules, because platform entitlement only stores rows and installs nothing.

  Scenario: register the application
    * url baseUrl
    * def scope = karate.get('scope')
    * def dependencies = karate.get('dependencies')
    * def descriptor = { name: '#(name)', version: '#(version)', scope: '##(scope)', dependencies: '##(dependencies)' }
    Given path 'applications'
    And param check = true
    And header Authorization = 'Bearer ' + masterToken
    And request descriptor
    When method post
    Then status 201
    * def id = response.id
    * match id == name + '-' + version
