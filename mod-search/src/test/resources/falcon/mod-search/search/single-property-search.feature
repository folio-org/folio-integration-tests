Feature: Tests that searches by a single property

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

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
      | alternativeTitles | alternative title                                       | webSemanticInstance   |
      | indexTitle        | web of metaphor :studies in the imagery of Montaigne\'s | webOfMetaphorInstance |
      | series            | Cooperative information systems                         | webSemanticInstance   |

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
      | indexTitle        | web of metaphor :studies in the imagery of Montaigne\'s | webOfMetaphorInstance |
      | series            | Cooperative information systems                         | webSemanticInstance   |
      | identifiers       | 0917058062                                              | webOfMetaphorInstance |
      | contributors      | Clark Carol                                             | webOfMetaphorInstance |

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
      | indexTitle        | web of metaphor :studies in the imagery of Montaigne\'s | webOfMetaphorInstance |
      | series            | Cooperative information systems                         | webSemanticInstance   |
      | identifiers       | 0917058062                                              | webOfMetaphorInstance |
      | contributors      | Clark Carol                                             | webOfMetaphorInstance |

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
      | contributors      | Clark Carol                     | webOfMetaphorInstance |

  @Ignore
  Scenario Outline: Can search by date with operators
    Given path '/search/instances'
    And param query = 'metadata.<field> <operator> "<value>"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field       | operator | value      | expectedInstanceId    |
      | createdDate | <=       | 2020-12-10 | webSemanticInstance   |
      | createdDate | >        | 2020-12-10 | webOfMetaphorInstance |
      | updatedDate | <        | 2021-03-20 | webSemanticInstance   |
      | updatedDate | >=       | 2021-03-10 | webOfMetaphorInstance |

  @Ignore
  Scenario Outline: Can search by wildcard
    Given path '/search/instances'
    And param query = '<field> = <value>'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(<expectedInstanceId>)'
    Examples:
      | field             | value                | expectedInstanceId    |
      | title             | web*                 | webSemanticInstance   |
      | alternativeTitles | alterna*             | webSemanticInstance   |
      | indexTitle        | *metaphor*           | webOfMetaphorInstance |
      | series            | *information systems | webSemanticInstance   |
      | identifiers       | *058062              | webOfMetaphorInstance |
      | contributors      | *Carol               | webOfMetaphorInstance |

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
    And param query = 'hrid <> "falconTestInstance1"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == webSemanticInstance
