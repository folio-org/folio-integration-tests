Feature: sample data driven example

  Background:
    * url 'http://localhost:9130'
    * def admin = { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * call login admin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

  Scenario Outline: create fiscal year <id> and <code>
    Given path 'finance/fiscal-years'
    And request
    """
    {
        "id": <id>,
        "code": <code>,
        "name": "Test fiscal year",
        "periodStart": "2019-01-01T00:00:00Z",
        "periodEnd": "2025-12-30T23:59:59Z"
    }
    """
    When method POST
    Then status 201
    Examples:
      | id                                     | code           |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca61' | 'codetest2019' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca69' | 'codetest2020' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca60' | 'codetest2021' |

  Scenario Outline: get fiscal year by <id>
    Given path 'finance/fiscal-years', <id>
    When method GET
    Then status 200
    And match response.code == <code>
    Examples:
      | id                                     | code           |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca61' | 'codetest2019' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca69' | 'codetest2020' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca60' | 'codetest2021' |


  Scenario Outline: update fiscal year codes for <id> to <code>
    Given path 'finance/fiscal-years', <id>
    When method GET
    Then status 200
    And match response.code == <before>

    * def rq = response
    * set rq.code = <code>

    Given path 'finance/fiscal-years', <id>
    And request rq
    When method PUT
    Then status 204

    Given path 'finance/fiscal-years', <id>
    When method GET
    Then status 200
    And match response.code == <code>

    Examples:
      | id                                     | before         | code            |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca61' | 'codetest2019' | 'codetestu2019' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca69' | 'codetest2020' | 'codetestu2020' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca60' | 'codetest2021' | 'codetestu2021' |

  Scenario Outline: delete fiscal year by <id>
    Given path 'finance/fiscal-years', <id>
    When method DELETE
    Then status 204
    Examples:
      | id                                     |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca61' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca69' |
      | '1477d5b9-0818-4c34-86d7-45b81b8cca60' |
