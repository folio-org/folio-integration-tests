Feature: Reference data management

  # Controlled-vocabulary categories: CRUD plus the domain/property lookup the
  # UI uses to populate pickers.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)

  Scenario: List categories with their values expanded
    Given path 'servint', 'refdata'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    And match each response contains { id: '#string', desc: '#string', values: '#array' }
    # The seeded access vocabulary is internal (module-owned, not user data).
    * def access = karate.filter(response, function (c) { return c.desc == 'DashboardAccess.Access' })[0]
    * match access.internal == true
    * match access.values[*].value contains only ['manage', 'edit', 'view']

  Scenario: Create, read, update and delete a category
    * def desc = 'Karate.Custom' + suffix

    Given path 'servint', 'refdata'
    And headers actor
    And request { desc: '#(desc)', values: [{ label: 'First' }, { label: 'Second', value: 'second_custom' }] }
    When method POST
    Then status 201
    * def categoryId = response.id
    And match response.desc == desc
    And match response.values[*].label contains only ['First', 'Second']
    # A submitted label is normalised into the machine value when none is given.
    * def first = karate.filter(response.values, function (v) { return v.label == 'First' })[0]
    * def second = karate.filter(response.values, function (v) { return v.label == 'Second' })[0]
    * match first.value == 'first'
    * match second.value == 'second_custom'

    Given path 'servint', 'refdata', categoryId
    And headers actor
    When method GET
    Then status 200
    And match response.desc == desc
    And match response.values == '#[2]'

    # PUT with an extra value adds it to the category.
    Given path 'servint', 'refdata', categoryId
    And headers actor
    And request { values: [{ label: 'First' }, { label: 'Second', value: 'second_custom' }, { label: 'Third' }] }
    When method PUT
    Then status 200
    And match response.values[*].label contains 'Third'

    Given path 'servint', 'refdata', categoryId
    And headers actor
    When method DELETE
    Then status 204

    Given path 'servint', 'refdata'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].desc !contains desc

  Scenario: Fetching an unknown category answers 404
    Given path 'servint', 'refdata', uuid()
    And headers actor
    When method GET
    Then status 404

  Scenario: Look up values by domain and property
    Given path 'servint', 'refdata', 'NumberGeneratorSequence', 'CheckDigitAlgo'
    And headers actor
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].value contains only
      """
      [
        'none', 'ean13', '1793_ltr_mod10_r', '12_ltr_mod10_r',
        'isbn10checkdigit', 'issncheckdigit', 'luhncheckdigit'
      ]
      """
    # A standalone value render carries its owning category as a reference.
    And match each response contains { id: '#string', value: '#string', label: '#string', owner: '#object' }
    And match response[0].owner.desc == 'NumberGeneratorSequence.CheckDigitAlgo'

  Scenario: The lookup honours term, match and the stats envelope
    Given path 'servint', 'refdata', 'NumberGeneratorSequence', 'CheckDigitAlgo'
    And headers actor
    And param term = 'Luhn'
    And param match = 'label'
    And param stats = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.results[0].value == 'luhncheckdigit'

  Scenario: An unregistered domain and property answers 404
    Given path 'servint', 'refdata', 'No', 'Such'
    And headers actor
    When method GET
    Then status 404
