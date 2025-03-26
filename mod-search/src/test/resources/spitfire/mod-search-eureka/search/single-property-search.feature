Feature: Tests that searches by a single property

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}

  Scenario Outline: Can search by title that matches '<field>' component
    Given path '/search/instances'
    And param query = 'title all "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field             | value                                                   | expectedInstanceId    |
      | title             | web semantic                                            | webSemanticInstance   |
      | alternativeTitles | Der Préis der Verfuhrung                                | webOfMetaphorInstance |
      | alternativeTitles | *Préis*                                                 | webOfMetaphorInstance |
      | indexTitle        | web of métaphor                                         | webOfMetaphorInstance |
      | series            | Electric ünicycle one                                   | webOfMetaphorInstance |

  Scenario Outline: Can search by keyword that matches '<field>' component
    Given path '/search/instances'
    And param query = 'keyword all "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field             | value                                                   | expectedInstanceId    |
      | title             | web semantic                                            | webSemanticInstance   |
      | alternativeTitles | alternative title                                       | webSemanticInstance   |
      | indexTitle        | web of metaphör                                         | webOfMetaphorInstance |
      | series            | Cooperative information systems                         | webSemanticInstance   |
      | identifiers       | 0917058062                                              | webOfMetaphorInstance |
      | contributors      | Clàrk Càrol                                             | webOfMetaphorInstance |

  Scenario Outline: Can search by keyword that matches '<field>' component with order match
    Given path '/search/instances'
    And param query = 'keyword == "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field             | value                                                   | expectedInstanceId    |
      | alternativeTitles | alternative title                                       | webSemanticInstance   |
      | indexTitle        | web of metaphör                                         | webOfMetaphorInstance |
      | series            | Cooperative information systems                         | webSemanticInstance   |
      | identifiers       | 0917058062                                              | webOfMetaphorInstance |
      | contributors      | Clàrk Càrol                                             | webOfMetaphorInstance |

  Scenario Outline: Can search by keyword that matches '<field>' component with any of values
    Given path '/search/instances'
    And param query = 'keyword any "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field             | value                           | expectedInstanceId    |
      | alternativeTitles | alternative title               | webSemanticInstance   |
      | series            | Cooperative information systems | webSemanticInstance   |
      | identifiers       | 0917058062                      | webOfMetaphorInstance |
      | contributors      | Clàrk Càrol                     | webOfMetaphorInstance |

  Scenario Outline: Can search by date with operators
    Given path '/search/instances'
    And param query = '<field> <operator> "<value>"'
    And param expandAll = true
    When method GET
    Then status 200
    Then match response.totalRecords == <totalRecords>
    Examples:
      | field                | operator | value      | totalRecords |
      | metadata.createdDate | >=       | 2020-12-10 | 17           |
      | metadata.updatedDate | >        | 2021-03-20 | 17           |
      | normalizedDate1      | >        | 2021       | 11           |
      | normalizedDate1      | <        | 2021       | 2            |
      | normalizedDate1      | >=       | 2022       | 11           |

  Scenario Outline: Can search by wildcard
    Given path '/search/instances'
    And param query = '<field> = <value>'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field             | value                | expectedInstanceId    |
      | title             | web*                 | webOfMetaphorInstance |
      | indexTitle        | *métapho*            | webOfMetaphorInstance |
      | series            | *information systems | webSemanticInstance   |
      | identifiers.value | *058062              | webOfMetaphorInstance |
      | contributors      | Clark*               | webOfMetaphorInstance |
      | subjects          | Montà*               | webOfMetaphorInstance |

  Scenario Outline: Can search by isbn
    Given path '/search/instances'
    And param query = 'isbn="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(webSemanticInstance)'
    Examples:
      | value            |
      # ISBN 10
      | 047144250X       |
      | 04714*           |
      | 0471-4*          |
      # ISBN 13
      | 9780471442509    |
      | 978-0471-44250-9 |
      | paper            |
      | 978-0471*        |
      | 9780471*         |

  Scenario: Can search by hrid that NOT matches value
    Given path '/search/instances'
    And param query = 'hrid <> "falconTestInstance1" sortby title'
    When method GET
    Then status 200
    Then match response.totalRecords == 16
    Then match response.instances[0].id == webSemanticInstance

  Scenario Outline: Can search instances by lccn
    Given path '/search/instances'
    And param query = 'lccn="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | value            | expectedInstanceId    |
      | no2003065165     | webSemanticInstance   |
      | NO 2003065165    | webSemanticInstance   |
      | 77093404         | webOfMetaphorInstance |
      | 97802*           | webSemanticInstance   |
      | *65165           | webSemanticInstance   |

  Scenario: Can search by subjects
    Given path '/search/instances'
    And param query = 'subjects all Montàigné, Michél'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == webOfMetaphorInstance

  Scenario Outline: Can search instances by normalized classification number
    Given path '/search/instances'
    And param query = 'normalizedClassificationNumber="<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | value       | expectedInstanceId    |
      | PQ1645 .C55 | webOfMetaphorInstance |
      | PQ1645*     | webOfMetaphorInstance |
      | PQ1645C55   | webOfMetaphorInstance |
      | PQ-1645!C55 | webOfMetaphorInstance |
