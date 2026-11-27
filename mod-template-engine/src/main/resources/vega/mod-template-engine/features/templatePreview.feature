Feature: Template preview requests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }

  Scenario: Post preview should return 200 and rendered header and body
    * def requestEntity = read('samples/template-preview-request-entity.json')

    Given path 'template-request', 'preview'
    And request requestEntity
    When method POST
    Then status 200
    And match response == { header: 'Hello message for Alex', body: 'Hello Alex' }

  Scenario: Post preview should not persist a template
    * def requestEntity = read('samples/template-preview-request-entity.json')

    Given path 'templates'
    When method GET
    Then status 200
    * def totalRecordsBefore = response.totalRecords

    Given path 'template-request', 'preview'
    And request requestEntity
    When method POST
    Then status 200

    Given path 'templates'
    When method GET
    Then status 200
    And match response.totalRecords == totalRecordsBefore

  Scenario: Post preview should render nested context and escape HTML unless triple braces are used
    * def requestEntity = read('samples/template-preview-request-entity.json')
    * requestEntity.body = 'Hi {{user.name}}, your {{user.pet.type}} {{user.pet.name}} says: {{{user.pet.hint}}} / {{user.pet.hint}}'
    * requestEntity.context.user.pet = { type: 'cat', name: 'Whiskers', hint: '<b>Feed me NOW.</b>' }

    Given path 'template-request', 'preview'
    And request requestEntity
    When method POST
    Then status 200
    And match response.body contains 'Hi Alex, your cat Whiskers says: <b>Feed me NOW.</b> / '
    And match response.body !contains '/ <b>'
    And match response.body contains '&lt;b&gt;'

  Scenario: Post preview should format date tokens using the tenant locale
    * def requestEntity = read('samples/template-preview-request-entity.json')
    * requestEntity.header = 'Request created on {{request.creationDate}}'
    * requestEntity.body = 'Due date is {{loan.dueDateTime}}'
    * requestEntity.context = { request: { creationDate: '2019-06-10T18:32:31.000+0100' }, loan: { dueDateTime: '2019-06-18T14:04:33.205Z' } }

    Given path 'template-request', 'preview'
    And request requestEntity
    When method POST
    Then status 200
    And match response.header == 'Request created on 6/10/19'
    # newer JDKs put a narrow no-break space (U+202F) before AM/PM, so do not match the separator exactly
    And match response.body == '#regex Due date is 6/18/19, 2:04.PM'

  Scenario: Post preview should return 200 with empty strings if header and body are omitted
    Given path 'template-request', 'preview'
    And request {}
    When method POST
    Then status 200
    And match response == { header: '', body: '' }

  Scenario: Post preview should render missing tokens as empty strings
    * def requestEntity = read('samples/template-preview-request-entity.json')
    * remove requestEntity $.context

    Given path 'template-request', 'preview'
    And request requestEntity
    When method POST
    Then status 200
    And match response == { header: 'Hello message for ', body: 'Hello ' }

  Scenario: Post preview should return 400 if template is malformed
    * def requestEntity = read('samples/template-preview-request-entity.json')
    * requestEntity.body = '{{#unclosed}}'

    Given path 'template-request', 'preview'
    And request requestEntity
    When method POST
    Then status 400
    And match response contains 'Template could not be rendered'
