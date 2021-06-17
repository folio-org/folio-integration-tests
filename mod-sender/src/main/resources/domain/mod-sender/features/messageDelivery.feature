Feature: Sender - message delivery

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Should return 422 when body is invalid
    Given path 'message-delivery'
    And request "{}"
    When method POST
    Then status 422

  Scenario: Should not found user
    Given path 'message-delivery'
    And request
    """
    {
      "notificationId": "db300321-d75a-48ce-87b0-7a387b3b21b2",
      "recipientUserId": "1d413183-725d-45d5-a185-8c39916c5dd9",
      "messages":
          [
            {   "deliveryChannel": "email",
                "from":"from",
                "attachments":[]
            }
          ]
    }
    """
    When method POST
    Then status 400

  @Undefined
  Scenario: Should not fail when user contains additional properties
    * print 'undefined'

  @Undefined
  Scenario: Should return no content and send email when request is valid
    * print 'undefined'

  @Undefined
  Scenario: Should return bad request when delivery channel is not supported
    * print 'undefined'
