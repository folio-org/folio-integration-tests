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

  @Undefined
  Scenario: Should not fail when user contains additional properties
    Given path 'message-delivery'
    And header x-okapi-tenant = tenant
    And request
"""
{ "notificationId":"db300321-d75a-48ce-87b0-7a387b3b21b2",
   "recipientUserId":"userId",
   "messages":[
       { "deliveryChannel":"not_existing_channel",
         "from":"from","attachments":[]
       },
       { "deliveryChannel":"email",
         "from":"from",
       "attachments":[]
       }
   ]
}
"""
    When method POST
    Then status 400
    And match response contains "Delivery channel 'not_existing_channel' is not supported"

  @Undefined
  Scenario: Should return no content and send email when request is valid
    * print 'undefined'

  @Undefined
  Scenario: Should return bad request when delivery channel is not supported
    * print 'undefined'shouldReturnBadRequestWhenDeliveryChannelIsNotSupported
