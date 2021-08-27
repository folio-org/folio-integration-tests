Feature: Notify

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def notificationId = call uuid1
    * def senderId = call uuid1
    * def recipientId = call uuid1
    * def eventId = call uuid1
    * def recipientEmail = 'mv@mail.com'
    * def senderEmail = 'mv1@mail.com'
    * def templateId = call uuid1
    * def configId = call uuid1
    * def patronGroupId = call uuid1
    * def eventConfigName = 'event-config-name'

  Scenario: Get all notify entries
    Given path 'notify'
    When method GET
    Then status 200

  Scenario: POST notify should create notification with 3 required fields without event config
    * def notification = read('samples/notification-entity.json')
    * notification.eventConfigName = null

    Given path 'notify'
    And request notification
    When method POST
    Then status 201

    Given path 'notify/' + notificationId
    When method GET
    Then status 200
    And match $.recipientId == notification.recipientId
    And match $.senderId == notification.senderId

  Scenario: POST notify should create template request and notification with event config
    * def eventConfig = read('samples/event-config-entity.json')
    * def template = read('samples/template-entity.json')
    * def notification = read('samples/notification-entity.json')
    * def recipient = read('samples/recipient-entity.json')
    * def sender = read('samples/sender-entity.json')
    * def group = read('samples/group-entity.json')

    Given path 'groups'
    And request group
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
    And request template
    When method POST
    Then status 201

    Given path 'eventConfig'
    And request eventConfig
    When method POST
    Then status 201

    Given path 'notify'
    And request notification
    When method POST
    Then status 201

    Given path 'notify/' + notificationId
    When method GET
    Then status 200
    And match $.recipientId == notification.recipientId
    And match $.senderId == notification.senderId
    And match $.text == notification.text

    Given path 'email'
    And param query = 'to==' + recipientEmail + ' and header==' + template.localizedTemplates.en.header
    When method GET
    Then status 200
    And match $.emailEntity[0].to == recipientEmail