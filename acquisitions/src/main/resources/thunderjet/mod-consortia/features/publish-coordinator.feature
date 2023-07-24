Feature: Consortia publish coordinator tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure retry = { count: 10, interval: 1000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    * def publicationBody =
    """
      {
          "url": "/tags",
          "method": "POST",
          "tenants": [
              "#(centralTenant)",
              "#(universityTenant)"
          ],
          "payload": {
              "label": "cons-test",
              "description": "consortia karate test tag"
          }
      }
    """

  Scenario: Verify publish coordinator has persisted requests:
    # 1. Publish requests to endpoint /tags
    Given path 'consortia', consortiumId, 'publications'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request publicationBody
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200

    # 3. Retrieve succeeded publication results
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    ###
    # 4. Publish requests to endpoint /tags. The body is the same as previous one, so expected 'duplicate key violation' error#
    Given path 'consortia', consortiumId, 'publications'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And request publicationBody
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def failedPublicationId = response.id

    # 5. Retrieve publication status with errors. expected status ERROR
    Given path 'consortia', consortiumId, 'publications', failedPublicationId
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200

    # 6. Retrieve failed publication results
    Given path 'consortia', consortiumId, 'publications', failedPublicationId, 'results'
    And headers {'x-okapi-tenant':'#(tenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200