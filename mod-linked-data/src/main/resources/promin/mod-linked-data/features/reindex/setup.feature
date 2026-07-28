Feature: Setup for reindex tests - creates Work and Hub resources once

  Scenario: Create and index Work and Hub resources
    * url baseUrl
    * def workRequest = read('samples/work-request.json')
    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def workQuery = 'title all "Reindex test work"'
    Given path 'search/linked-data/works'
    And param query = workQuery
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200

    * def hubUri = 'https://id.loc.gov/resources/hubs/0f11341f-5bb5-9e64-110f-6bb4782fc615.json'
    * call importHub { hubUri: '#(hubUri)' }
    * def hubQuery = 'label="Eckardt, Jason, 1971-. Pulse-echo"'
    * def query = hubQuery
    * call searchLinkedDataHub
