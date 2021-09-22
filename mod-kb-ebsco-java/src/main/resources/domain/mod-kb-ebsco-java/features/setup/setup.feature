Feature: Setup kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)'}
    * def credentials = read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/credentials.json')
    * def user = read('classpath:domain/mod-kb-ebsco-java/features/setup/samples/user.json')

  Scenario: Create kb-credentials and assign user
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    And match responseType == 'json'
    And def credentialId = response.id

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And request
    """
    {
    "data": {
       "id":"00000000-1111-5555-9999-999999999992",
       "type": "assignedUsers",
       "attributes": {
         "credentialsId": "#(credentialId)",
         "userName": "test_user",
         "firstName": "Test",
         "lastName": "User",
         "patronGroup": "Staff"
        }
      }
    }
    """
    And print testUser
    When method POST
    Then status 201