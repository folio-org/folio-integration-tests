Feature: Patron notice

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def senderId = call uuid1
    * def recipientId = call uuid1
    * def recipientEmail = 'vb@mail.com'
    * def senderEmail = 'vb1@mail.com'
    * def templateId = call uuid1
    * def username1 = call uuid1
    * def username2 = call uuid1
    * def itemId = call uuid1
    * def recipientBarcode = call uuid1

  Scenario: POST patron notice should create multiple loans notice
    * def templateEntity = read('samples/template-entity.json')
    * def patronNoticeEntity = read('samples/patron-notice-entity.json')
    * def recipient = read('samples/recipient.json')
    * def sender = read('samples/sender.json')
    * def groupEntity = read('features/samples/group-entity.json')

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

    Given path 'patron-notice'
    And request patronNoticeEntity
    When method POST
    Then status 200

    Given path 'email'
    And param query = 'to=' + recipientEmail
    When method GET
    Then status 200
   # And match $.emailEntity[0].status == 'DELIVERED'
    And match $.emailEntity[0].to == recipientEmail
    And match $.emailEntity[0].body == '2021-08-172021-08-17T00:00:00.205Z2021-08-172021-08-17T01:00:00.205Z'
