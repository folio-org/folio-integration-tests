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
    * def username1 = 'username1'
    * def username2 = 'username2'
    * def itemId = call uuid1
    * def recipientBarcode = '222'
    * def patronGroupId = call uuid1

  Scenario: POST patron notice should create multiple loans notice
    * def template = read('samples/template-entity.json')
    * def patronNotice = read('samples/patron-notice-entity.json')
    * def recipient = read('samples/recipient-entity.json')
    * def sender = read('samples/sender-entity.json')
    * def group = read('samples/group-entity.json')
    * def emailBody = read('samples/email-body.json')
    * print emailBody

    * group.group = 'fat-33 group'
    * template.localizedTemplates.en.header = 'Hello to Mykyta Varenyk'

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

    Given path 'patron-notice'
    And request patronNotice
    When method POST
    Then status 200

    Given path 'email'
    And param query = 'to=' + recipientEmail + '=header=' + template.localizedTemplates.en.header
    When method GET
    Then status 200
    And match $.emailEntity[0].to == recipientEmail
    And match $.emailEntity[0].body == emailBody.body