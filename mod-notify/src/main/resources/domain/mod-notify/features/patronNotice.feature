Feature: Patron notice

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def senderId = call uuid1
    * def recipientId = call uuid1
    * def patronGroupId = call uuid1
    * def recipientEmail = 'mv@mail.com'
    * def senderEmail = 'mv1@mail.com'
    * def templateId = call uuid1
    * def username1 = call uuid1
    * def username2 = call uuid1

  Scenario: POST patron notice should create template request and notification
    * def templateEntity = read('samples/template-entity.json')
    * def patronNoticeEntity = read('samples/patron-notice-entity.json')
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

  Scenario: POST patron notice should create template request and notification
    * def templateEntity = read('samples/template-entity.json')
    * def patronNoticeEntity = read('samples/patron-notice-entity.json')
    * def recipient = read('samples/recipient.json')
    * def sender = read('samples/sender.json')
    * def groupEntity = read('samples/group-entity-2.json')

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
    And match $.emailEntity[0].body == '<div></div><div>8/18/21</div><div>8/18/21, 11:45 AM</div><div></div><div>8/18/21</div><div>8/18/21, 12:38 PM</div><div></div>'

  @Undefined
  Scenario: POST returns 422 when mod-sender returns 400
    * print 'undefined'

  @Undefined
  Scenario: POST returns 500 when mod-sender returns non-400 error
    * print 'undefined'

  @Undefined
  Scenario: POST returns 200 on success
    * print 'undefined'