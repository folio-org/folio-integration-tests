Feature: Sender - message delivery

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def validRq = read('classpath:domain/mod-sender/features/samples/message-delivery-valid.json')
    * def validRqWithAdditionalProperty = read('classpath:domain/mod-sender/features/samples/message-delivery-valid-additional-property.json')
    * def notSupportedChannelRq = read('classpath:domain/mod-sender/features/samples/message-delivery-not-supported-channel.json')
    * def userNotFoundRq = read('classpath:domain/mod-sender/features/samples/message-delivery-user-not-found.json')
    * def createFirstUserRq = read('classpath:domain/mod-sender/features/samples/create-first-user.json')
    * def createSecondUserRq = read('classpath:domain/mod-sender/features/samples/create-second-user.json')

  Scenario: Should return 422 when body is invalid
    Given path 'message-delivery'
    And request "{}"
    When method POST
    Then status 422

  Scenario: Should return 400 when user is not found
    Given path 'message-delivery'
    And request userNotFoundRq
    When method POST
    Then status 400

  Scenario: Should fail when notification contains additional properties
    Given path 'users'
    And request createFirstUserRq
    When method POST
    Then status 201

    Given path 'message-delivery'
    And request validRqWithAdditionalProperty
    When method POST
    Then status 422

  Scenario: Should return no content and send email when request is valid
    Given path 'users'
    And request createSecondUserRq
    When method POST
    Then status 201

    Given path 'message-delivery'
    And request validRq
    When method POST
    Then status 204

  Scenario: Should return 400 when delivery channel is not supported
    Given path 'message-delivery'
    And request notSupportedChannelRq
    When method POST
    Then status 400
    And match response contains "Delivery channel 'sms' is not supported"
