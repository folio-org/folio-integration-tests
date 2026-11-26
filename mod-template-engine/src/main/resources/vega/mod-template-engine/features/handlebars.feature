Feature: Handlebars template resolver tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * def templateId = call uuid1

  # Preview

  Scenario: Post preview with handlebars resolver should render if/else blocks
    * def header = '{{#if user.pet}}News from {{user.pet.name}}{{else}}Welcome back{{/if}}, {{user.name}}!'

    Given path 'template-request', 'preview'
    And request { header: '#(header)', templateResolver: 'handlebars', context: { user: { name: 'Alex', pet: { name: 'Whiskers' } } } }
    When method POST
    Then status 200
    And match response.header == 'News from Whiskers, Alex!'

    Given path 'template-request', 'preview'
    And request { header: '#(header)', templateResolver: 'handlebars', context: { user: { name: 'Alex' } } }
    When method POST
    Then status 200
    And match response.header == 'Welcome back, Alex!'

  Scenario: Post preview should default to mustache if template resolver is omitted
    # valid in both engines: mustache renders {{else}} as a missing variable, handlebars as the inverse branch
    * def body = '{{#user}}Hi {{name}}{{else}}nobody{{/user}}'
    * def context = { user: { name: 'Alex' } }

    Given path 'template-request', 'preview'
    And request { body: '#(body)', templateResolver: 'handlebars', context: '#(context)' }
    When method POST
    Then status 200
    And match response.body == 'Hi Alex'

    Given path 'template-request', 'preview'
    And request { body: '#(body)', context: '#(context)' }
    When method POST
    Then status 200
    And match response.body == 'Hi Alexnobody'

    Given path 'template-request', 'preview'
    And request { body: '#(body)', templateResolver: 'mustache', context: '#(context)' }
    When method POST
    Then status 200
    And match response.body == 'Hi Alexnobody'

  Scenario: Post preview should return 400 if template resolver is not supported
    Given path 'template-request', 'preview'
    And request { body: 'Hello {{user.name}}', templateResolver: 'foo', context: { user: { name: 'Alex' } } }
    When method POST
    Then status 400
    And match response == "Template resolver 'foo' is not supported"

  Scenario: Post preview should return 400 if handlebars template is malformed
    Given path 'template-request', 'preview'
    And request { body: '{{#if user.name}}never closed', templateResolver: 'handlebars', context: { user: { name: 'Alex' } } }
    When method POST
    Then status 400
    And match response contains 'Template could not be rendered'

    Given path 'template-request', 'preview'
    And request { body: '{{noSuchHelper user.name}}', templateResolver: 'handlebars', context: { user: { name: 'Alex' } } }
    When method POST
    Then status 400
    And match response contains 'Template could not be rendered'

  Scenario: Post preview should render module helpers
    * def body = '{{#equalsAny user.pet.type "cat" "dog"}}pet{{else}}other{{/equalsAny}}|{{nl2br notes}}|{{numberFormat amount locale="de-DE" minDecimals=2 maxDecimals=2}}'

    Given path 'template-request', 'preview'
    And request { body: '#(body)', templateResolver: 'handlebars', context: { user: { pet: { type: 'cat' } }, notes: 'a\nb', amount: 1234.5 } }
    When method POST
    Then status 200
    And match response.body == 'pet|a<br>b|1.234,50'

  # Stored templates

  Scenario: Post template request should render a stored handlebars template
    * def templateEntity = read('samples/template-handlebars-entity.json')

    Given path 'templates'
    And request templateEntity
    When method POST
    Then status 201
    And match response.templateResolver == 'handlebars'

    Given path 'template-request'
    And request { templateId: '#(templateId)', lang: 'en', outputFormat: 'text/plain', context: { user: { name: 'Alex', pet: { name: 'Whiskers' } }, items: [ { name: 'A' }, { name: 'B' } ] } }
    When method POST
    Then status 200
    And match response.templateId == templateId
    And match response.meta.lang == 'en'
    And match response.result.header == 'News from Whiskers, Alex!'
    And match response.result.body == 'Hi Alex, A, B'

    Given path 'templates', templateId
    When method DELETE
    Then status 204

  Scenario: Post template request should return 400 if stored handlebars template is malformed
    * def templateEntity = read('samples/template-handlebars-entity.json')
    * templateEntity.localizedTemplates.en.body = '{{#if user.name}}never closed'

    Given path 'templates'
    And request templateEntity
    When method POST
    Then status 201

    Given path 'template-request'
    And request { templateId: '#(templateId)', lang: 'en', outputFormat: 'text/plain', context: { user: { name: 'Alex' } } }
    When method POST
    Then status 400
    And match response contains 'Failed to process template'

    Given path 'templates', templateId
    When method DELETE
    Then status 204
