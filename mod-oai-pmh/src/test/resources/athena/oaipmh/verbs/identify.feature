Feature: tests for Identify verb

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl

  Scenario: get Identify
    Given param verb = 'Identify'
    When method GET
    Then status 200
    Then match response //protocolVersion == '2.0'
    Then match response //granularity == 'YYYY-MM-DDThh:mm:ssZ'
    Then match response //earliestDatestamp == '1970-01-01T00:00:00Z'

    #OAI-PMH is accepting GET only, POST test is for EDGE
  Scenario: post Identify with empty json
    And param verb = 'Identify'
    And request
    """
    {
    }
    """
    When method GET
    Then status 200
    Then match response //protocolVersion == '2.0'
    Then match response //granularity == 'YYYY-MM-DDThh:mm:ssZ'
    Then match response //earliestDatestamp == '1970-01-01T00:00:00Z'