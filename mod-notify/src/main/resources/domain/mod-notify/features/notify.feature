Feature: Notify

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def notifyId = call uuid1
    * def senderId = call uuid1
    * def recipientId = call uuid1
    * def eventConfigName = 'event-config-name'
    * def eventId = call uuid1
    * def patronGroupId = call uuid1
    * def recipientEmail = 'mv@mail.com'
    * def senderEmail = 'mv1@mail.com'
    * def templateId = call uuid1
    * def configId = call uuid1

  Scenario: Get all notify entries
    Given path 'notify'
    When method GET
    Then status 200

  Scenario: POST notify should create notification with 3 required fields
    * def requestEntity = read('samples/notify-entity-without-event-config.json')

    Given path 'notify'
    And request requestEntity
    When method POST
    Then status 201

    Given path 'notify/' + notifyId
    When method GET
    Then status 200
    And match response.id == notifyId
    And match $.recipientId == requestEntity.recipientId
    And match $.senderId == requestEntity.senderId

  Scenario: POST notify should create template request and notification with event config
    * def eventConfigEntity = read('samples/event-config-entity.json')
    * def templateEntity = read('samples/template-entity.json')
    * def notifyEntity = read('samples/notify-entity.json')
    * def recipient = read('samples/recipient.json')
    * def sender = read('samples/sender.json')
    * def groupEntity = read('samples/group-entity.json')

    Given path 'groups'
    And request groupEntity
    When method POST
    Then status 201

    Given path 'users'
    And request recipient
    When method POST
    Then status 201

    Given path 'users'
    And request sender
    When method POST
    Then status 201

    Given path 'templates'
    And request templateEntity
    When method POST
    Then status 201

    Given path 'eventConfig'
    And request eventConfigEntity
    When method POST
    Then status 201

    Given path 'notify'
    And request notifyEntity
    When method POST
    Then status 201

    Given path 'email'
    And param query = 'to=' + recipientEmail
    When method GET
    Then status 200
    And match $.emailEntity[0].status == 'DELIVERED'
    And match $.emailEntity[0].to == recipientEmail

  @Undefined
  Scenario: POST returns 422 when request validation fails
    * print 'undefined'

  @Undefined
  Scenario: POST returns 422 when ID in request is invalid
    * print 'undefined'

  @Undefined
  Scenario: POST returns 201 when event config name in request is null
    * print 'undefined'

  @Undefined
  Scenario: POST returns 201 when message delivery is successful
    * print 'undefined'

  @Undefined
  Scenario: GET returns 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET by ID returns 422 when requested ID is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET by ID returns 404 when notification is not found
    * print 'undefined'

  @Undefined
  Scenario: GET by ID returns 200 when notification is found
    * print 'undefined'

  @Undefined
  Scenario: DELETE returns 422 when requested ID is invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE returns 404 when notification is not found
    * print 'undefined'

  @Undefined
  Scenario: DELETE returns 204 on success
    * print 'undefined'

  Scenario: PUT returns 422 when requested ID is invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT returns 422 when requested requested ID does not match ID in the body
    * print 'undefined'

  @Undefined
  Scenario: PUT returns 422 when recipient ID in the body is empty
    * print 'undefined'

  @Undefined
  Scenario: PUT returns 404 when notification is not found by ID
    * print 'undefined'

  @Undefined
  Scenario: POST by username returns 400 when user is not found
    * print 'undefined'

  @Undefined
  Scenario: POST by username returns 201 on success
    * print 'undefined'

  @Undefined
  Scenario: GET for self returns 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST for self always returns 500
    * print 'undefined'

  @Undefined
  Scenario: DELETE for self returns 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE for self returns 404 when no notifications are found
    * print 'undefined'