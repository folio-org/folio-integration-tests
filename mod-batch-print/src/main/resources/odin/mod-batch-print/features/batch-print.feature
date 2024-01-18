Feature: Batch print

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Test CRUD operations
    * def requestEntity = read('samples/print-entry.json')
    * def requestEntityUpdated = read('samples/print-entry-updated.json')
    * def entryId = '47c62bf9-e225-4a4b-bb61-dc6fc11eed76'
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-url': '#(baseUrl)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    Given path '/print/entries'
    And request requestEntity
    When method POST
    Then status 204

    Given path '/print/entries/' + entryId
    When method GET
    Then status 200
    And match $.id == entryId

    Given path '/print/entries/' + entryId
    And request requestEntityUpdated
    When method PUT
    Then status 204

    Given path '/print/entries/' + entryId
    When method GET
    Then status 200
    And match $.id == entryId
    And match $.content == 'AABB11'

    Given path '/print/entries'
    And params {query:'type="SINGLE" sortby sortingField created',limit:5,offset:0}
    When method GET
    Then status 200
    And match response == { items: #present, resultInfo: #present }
    And match $.resultInfo.totalRecords == 1

    Given path '/print/entries/' + entryId
    When method DELETE
    Then status 204

    Given path '/print/entries/' + entryId
    When method GET
    Then status 404

  Scenario: Create print entry by notice template
    * def requestEntity = read('samples/mail.json')

    Given path '/mail'
    And request requestEntity
    When method POST
    Then status 200
    And def entryId = $.id

    Given path '/print/entries/' + entryId
    When method GET
    Then status 200
    And match response.id == entryId
    And match response  == { id: #present, created: #present, type: #present, sortingField: #present, content: #present }

    Given path '/print/entries'
    And param ids = entryId
    When method DELETE
    Then status 204

    Given path '/print/entries/' + entryId
    When method GET
    Then status 404



  Scenario: Get print entries should return 500 if internal server error

    Given path '/print/entries'
    And params {query:'not valid',limit:5,offset:0}
    When method GET
    Then status 500
    And match response contains 'Unsupported CQL index'

  Scenario: Post print entries should return 400 if authorization token is invalid
    * configure headers = { 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }

    Given path '/print/entries'
    And request {}
    When method POST
    Then status 400
    And match response contains 'Invalid Token: Failed to decode:Unrecognized token'

  Scenario: Post print entries should return 400 if request did not pass validation

    Given path '/print/entries'
    And request {}
    When method POST
    Then status 400
    And match response contains 'Bad Request'




