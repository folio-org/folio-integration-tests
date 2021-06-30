Feature: Check various failure scenarios

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers =
    """
    {
      "X-Okapi-Tenant": "#(testTenant)",
      "X-Okapi-Token": "#(okapitoken)"
    }
    """

  # This test is taken from the rest-assured test. Presumably we don't want to allow XHR requests to this endpoint.
  Scenario: Login with AJAX header and stripes fails with 401 response
    Given path "saml/login"
    And header X-Requested-With = "XmlHttpRequest"
    And header Content-Type = "application/json"
    And header Accept = "application/json, text/plain"
    And request
    """
    {
      "stripesUrl": "http://localhost:3000/test/path"
    }
    """
    When method POST
    Then status 401

  #
  # These next two are also taken from the rest assured tests but they return different error codes there.
  # I suspect this is because the karate tests are running through okapi. These responses seem correct though.
  #

  Scenario: Options request without origin fails with 404
    Given path "saml/login"
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 404

  Scenario: Options request with invalid fails with 403 bad request
    Given path "saml/login"
    And header Origin = "*"
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 403

