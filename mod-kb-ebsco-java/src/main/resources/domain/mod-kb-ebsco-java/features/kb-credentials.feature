Feature: KB Credentials

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain, application/vnd.api+json' }
    * def credentials = read('classpath:domain/mod-kb-ebsco-java/features/samples/credentials/credentials.json')
    * def random_uuid = 'dee3b52e-f37e-44f6-9d9c-681799c97543'
    * def long_name = 'This name longer than 255 characters___This name longer than 255 characters___This name longer than 255 characters___This name longer than 255 characters___This name longer than 255 charactersThis name longer than 255 characters___This name longer than 255 characters___'

  @Positive
  Scenario: GET /eholdings/kb-credentials should return all existed KB credentials (response: status 200 and json body)
    Given path '/eholdings/kb-credentials'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.data[0].type == 'kbCredentials'

  @Positive
  Scenario: POST /eholdings/kb-credentials should create KB credentials (response: status 201 and json body)
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    And match responseType == 'json'
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    When method GET
    Then status 200
    And match response.attributes.name == credentials.data.attributes.name
    And match response.attributes.customerId == credentials.data.attributes.customerId
    And match response.attributes.url == credentials.data.attributes.url
    And match response.attributes.apiKey == '#present'

    Given path '/eholdings/kb-credentials', response.id
    When method DELETE
    And status 204

  @Positive
  Scenario: GET /eholdings/kb-credentials/{id} should return specific KB credentials by id (response: status 200 and json body)
    Given path '/eholdings/kb-credentials'
    When method GET
    Then status 200
    * def id = response.data.id

    Given path '/eholdings/kb-credentials', id
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.data[0].type == 'kbCredentials'

  @Positive
  Scenario: PATCH /eholdings/kb-credentials/{id} should update KB credentials by id (response: status 204)
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.name = 'NEW_NAME'
    When method PATCH
    Then status 204

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.url = 'http://api.ebsco.io'
    When method PATCH
    Then status 204

    Given path '/eholdings/kb-credentials', id
    When method GET
    Then status 200
    And match response.attributes.name == 'NEW_NAME'
    And match response.attributes.url == 'http://api.ebsco.io'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Positive
  Scenario: PUT /eholdings/kb-credentials/{id} should update KB credentials by id (response: status 204)
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.name = 'NEW_NAME'
    When method PUT
    Then status 204

    Given path '/eholdings/kb-credentials', id
    When method GET
    Then status 200
    And match response.attributes.name == 'NEW_NAME'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Positive
  Scenario: DELETE /eholdings/kb-credentials/{id} should should delete KB credentials by id (response: status 204)
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', response.id
    When method DELETE
    And status 204

    Given path '/eholdings/kb-credentials', id
    When method GET
    Then status 404

  @Positive
  Scenario: GET /eholdings/kb-credentials/{id}/key should return specific KB credentials key by id (response: status 200 and json body)
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id, 'key'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.attributes.apiKey == credentials.data.attributes.apiKey

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: GET /eholdings/kb-credentials/{id}/key should return status 400 and json if customerId invalid
    Given path '/eholdings/kb-credentials', 'id', 'key'
    When method GET
    Then status 400

  @Negative
  Scenario: GET /eholdings/kb-credentials/{id}/key should return status 404 and json if customerId not exist
    Given path '/eholdings/kb-credentials', random_uuid, 'key'
    When method GET
    Then status 404
    And match responseType == 'json'

  @Undefined
  Scenario: GET /eholdings/user-kb-credential should return status 404 and json if user not assigned
    * print 'undefined'

  @Negative
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if credentials invalid
    Given path '/eholdings/kb-credentials'
    And request '{}'
    When method POST
    Then status 422
    And match responseType == 'json'

  @Negative
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if name longer than 255 characters
    Given path '/eholdings/kb-credentials'
    And request credentials
    And set credentials.data.attributes.name = long_name
    When method POST
    Then status 422
    And match responseType == 'json'

  @Negative
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if name is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    And set credentials.data.attributes.name = ''
    When method POST
    Then status 422
    And match responseType == 'json'

  @Negative
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if name is already exist
    Given path '/eholdings/kb-credentials'
    And request
    """
      {
        "data": {
          "type": "kbCredentials",
          "attributes": {
            "name": "Dummy Credentials",
            "customerId": "dummyCustomerId",
            "apiKey": "dummyKey",
            "url": "http://dummy.url.com"
          }
        }
      }
    """
    When method POST
    Then status 422

  @Negative
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if url is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    And set credentials.data.attributes.url = ''
    When method POST
    Then status 422
    And match responseType == 'json'

  @Negative
  Scenario: POST /eholdings/kb-credentials should return status 422 and json if customerId is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    And set credentials.data.attributes.customerId = ''
    When method POST
    Then status 422
    And match responseType == 'json'


  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 400 and json if customerId invalid
    Given path '/eholdings/kb-credentials', 'id'
    And request credentials
    When method PUT
    Then status 400
    And match responseType == 'json'

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 404 and json if customerId not exist
    Given path '/eholdings/kb-credentials', random_uuid
    And request credentials
    When method PUT
    Then status 404
    And match responseType == 'json'

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 422 and json if credentials invalid
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request '{}'
    When method PUT
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 422 and json if name longer than 255 characters
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.name = long_name
    When method PUT
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 422 and json if name is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.name = ''
    When method PUT
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 422 and json if name is already exist
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.name = 'Dummy Credentials'
    When method PUT
    Then status 422
    And match responseType == 'json'
    And match response.errors[0].title == 'Duplicate name'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 422 and json if url is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.url = ''
    When method PUT
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PUT /eholdings/kb-credentials/{id} should return status 422 and json if customerId is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request credentials
    And set credentials.data.attributes.customerId = ''
    When method PUT
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204



  @Negative
  Scenario: PATCH /eholdings/kb-credentials{id} should return status 400 and json if customerId invalid
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', 'invalid_id'
    And request credentials
    And set credentials.data.attributes.name = 'NEW_NAME'
    When method PATCH
    Then status 400
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials{id} should return status 404 and json if customerId not exist
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request
    """
    {
      "data": {
        "type": "kbCredentials",
        "attributes": {
          "customerId": #(random_uuid)
        }
      }
    }
    """
    When method PATCH
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials{id} should return status 422 and json if credentials invalid
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request {}
    When method PATCH
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials/{id} should return status 422 and json if name longer than 255 characters
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request
    """
    {
      "data": {
        "type": "kbCredentials",
        "attributes": {
          "name": "#(long_name)"
        }
      }
    }
    """
    When method PATCH
    Then status 422
    And match responseType == 'json'
    And match response.errors[0].title == 'Invalid name'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials/{id} should return status 422 and json if name is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request
    """
    {
      "data": {
        "type": "kbCredentials",
        "attributes": {
          "name": ""
        }
      }
    }
    """
    When method PATCH
    Then status 422
    And match responseType == 'json'
    And match response.errors[0].title == 'Invalid attributes'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials/{id} should return status 422 and json if name is already exist
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request
    """
    {
      "data": {
        "type": "kbCredentials",
        "attributes": {
          "name": "Dummy Credentials"
        }
      }
    }
    """
    When method PATCH
    Then status 422
    And match responseType == 'json'
    And match response.errors[0].title == 'Duplicate name'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials/{id} should return status 422 and json if url is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request
    """
    {
      "data": {
        "type": "kbCredentials",
        "attributes": {
          "url": ""
        }
      }
    }
    """
    When method PATCH
    Then status 422
    And match responseType == 'json'
    And match response.errors[0].title == 'Invalid attributes'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Negative
  Scenario: PATCH /eholdings/kb-credentials/{id} should return status 422 and json if customerId is empty
    Given path '/eholdings/kb-credentials'
    And request credentials
    When method POST
    Then status 201
    * def id = response.id

    Given path '/eholdings/kb-credentials', id
    And request
    """
    {
      "data": {
        "type": "kbCredentials",
        "attributes": {
          "customerId": ""
        }
      }
    }
    """
    When method PATCH
    Then status 422
    And match responseType == 'json'

    Given path '/eholdings/kb-credentials', id
    When method DELETE
    And status 204

  @Undefined
  Scenario: DELETE /eholdings/kb-credentials/{id} should return status 400 and json if customerId invalid
    Given path '/eholdings/kb-credentials', 'invalidId'
    When method DELETE
    And status 400

  @Negative
  Scenario: DELETE /eholdings/kb-credentials/{id} should return status 404 and json if customerId not exist
    Given path '/eholdings/kb-credentials', random_uuid
    When method DELETE
    And status 204