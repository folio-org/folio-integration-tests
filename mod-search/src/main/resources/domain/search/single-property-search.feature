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
