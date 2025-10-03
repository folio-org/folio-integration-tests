Feature: Create User

  Background:
    * url baseUrl

  Scenario: createUser
    * def user = karate.get('user', {})
    * if (!user.type) user.type = 'patron'
    Given path 'users'
    And request user
    When method POST
    Then status 201
    * print 'Created user response:', response
    * match response.type == user.type
    * if (user.id) karate.match(response.id, user.id)
