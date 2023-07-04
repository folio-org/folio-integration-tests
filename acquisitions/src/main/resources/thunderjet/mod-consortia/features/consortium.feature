Feature: Consortium object in mod-consortia api tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure retry = { count: 6, interval: 20000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  Scenario: Create, Read, Update a consortium for positive cases
    * def consortiumName = 'Consortium name for test'

    # create a consortium
    Given path '/consortia'
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }

    # get consortiums
    Given path '/consortia'
    When method GET
    Then status 200
    And match response == { consortia: '#present', totalRecords: 1 }
    And match response.consortia[0] == { id: '#(consortiumId)', name: '#(consortiumName)' }

    # get consortium
    Given path '/consortia', consortiumId
    When method GET
    Then status 200
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }

    # update consortium
    Given path '/consortia', consortiumId
    And request { id: '#(consortiumId)', name: 'Updated consortium name for test' }
    When method PUT
    Then status 200
    And match response == { id: '#(consortiumId)', name: 'Updated consortium name for test' }

  Scenario: Create, Read, Update a consortium for negative cases
    * def nonExistingConsortiumId = 'd9acad2f-2aac-4b48-9097-e6ab85906b25'

    # attempt to get non-existing consortium
    Given path '/consortia', nonExistingConsortiumId
    When method GET
    Then status 404
    And match response == { errors: [{message: 'Objects with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to update consortium with non-equal id in payload
    Given path '/consortia', consortiumId
    And request { id: '#(nonExistingConsortiumId)', name: 'Updated consortium name for test' }
    When method PUT
    Then status 400
    And match response == { errors: [{message: 'Request body consortiumId and path param consortiumId should be identical', type: '-1', code: 'VALIDATION_ERROR'}] }

    # attempt to update non-existing consortium
    Given path '/consortia', nonExistingConsortiumId
    And request { id: '#(nonExistingConsortiumId)', name: 'Updated consortium name for test' }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Objects with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to create second consortium
    Given path '/consortia'
    And request { id: '#(consortiumId)', name: 'Consortium name for test' }
    When method POST
    Then status 409
    And match response == { errors: [{message: 'System can not have more than one consortium record', type: '-1', code: 'DUPLICATE_ERROR'}] }
