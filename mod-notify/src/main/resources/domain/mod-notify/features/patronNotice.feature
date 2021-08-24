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
    And match $.emailEntity[0].body == '<div>James</div><div></div><div>Rodwell</div><div>6430530304</div><div></div><div>Nod</div><div></div><div>Barnes, Adrian</div><div>565578437802</div><div>123456</div><div>PREFIX</div><div>SUFFIX</div><div></div><div></div><div></div><div></div><div>Book</div><div></div><div></div><div></div><div>3rd Floor</div><div>Djanogly Learning Resource Centre</div><div>Jubilee Campus</div><div>Nottingham University</div><div>unlimited</div><div>0</div><div>unlimited</div><div></div><div>Interesting Times</div><div></div><div>Pratchett, Terry</div><div>56454543534</div><div>123456</div><div>PREFIX</div><div>SUFFIX</div><div></div><div></div><div></div><div></div><div>Book</div><div></div><div></div><div></div><div>3rd Floor</div><div>Djanogly Learning Resource Centre</div><div>Jubilee Campus</div><div>Nottingham University</div><div>unlimited</div><div>0</div><div>unlimited</div><div></div>'
