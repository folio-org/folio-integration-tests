Feature: Sender - message delivery

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def recipientId = call uuid1

  Scenario: Should return 422 when body is invalid
    Given path 'message-delivery'
    And request "{}"
    When method POST
    Then status 422

  Scenario: Should return 400 when user is not found
    Given path 'message-delivery'
    * def deliveryChannel = 'email'
    And request read('classpath:vega/mod-sender/features/samples/message-delivery.json')
    When method POST
    Then status 400

  Scenario: Should fail when notification contains additional properties
    Given path 'users'
    * def userName = 'firstUserName'
    * def barcode = '12345678'
    And request read('classpath:vega/mod-sender/features/samples/create-recipient.json')
    When method POST
    Then status 201

    Given path 'message-delivery'
    And request read('classpath:vega/mod-sender/features/samples/message-delivery-additional-property.json')
    When method POST
    Then status 422

  Scenario: Should return no content and send email when request is valid
    Given path 'users'
    * def userName = 'recipientName'
    * def barcode = '123456789'
    And request read('classpath:vega/mod-sender/features/samples/create-recipient.json')
    When method POST
    Then status 201

    Given path 'message-delivery'
    * def deliveryChannel = 'email'
    And request read('classpath:vega/mod-sender/features/samples/message-delivery.json')
    When method POST
    Then status 204

  Scenario: Should return 400 when delivery channel is not supported
    Given path 'message-delivery'
    * def deliveryChannel = 'sms'
    And request read('classpath:vega/mod-sender/features/samples/message-delivery.json')
    When method POST
    Then status 400
    And match response contains "Delivery channel 'sms' is not supported"
