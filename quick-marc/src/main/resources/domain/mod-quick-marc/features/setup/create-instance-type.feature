Feature: Create instance type

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersDelete = { 'Content-Type': 'text/plain', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'text/plain'  }
    * def instanceType = read('classpath:domain/mod-quick-marc/features/setup/samples/instance-type.json');

  @CreateInstanceType
  Scenario: create instance type
    Given path 'instance-types'
    And headers headersUser
    And request instanceType
    When method post
    Then assert responseStatus == 201 || responseStatus == 400
    And eval if (responseStatus == 400) karate.call('create-instance-type.feature@DeleteInstanceType')

  @DeleteInstanceType
  Scenario: delete instance type
    Given path 'instance-types'
    And param query = "name=" + instanceType.name + " or code=" + instanceType.code
    And headers headersUser
    When method get
    Then status 200
    * def idToDelete = response.instanceTypes[0].id

    Given path 'instance-types', idToDelete
    And headers headersDelete
    When method delete
    Then status 204
    And call read('create-instance-type.feature@CreateInstanceType')