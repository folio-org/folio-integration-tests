Feature: Number generator management

  # CRUD for generators and their sequences: wire shape (expanded sequences,
  # owner snippet, expanded refdata), the stats envelope, and cascade delete.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)

  Scenario: Create a generator with embedded sequences
    * def code = 'orders' + suffix
    Given path 'servint', 'numberGenerators'
    And headers actor
    And request
      """
      {
        code: '#(code)',
        name: 'Orders',
        description: 'Order numbering',
        sequences: [
          { code: 'purchase', name: 'Purchase', format: '00000', nextValue: 1 },
          { code: 'renewal', name: 'Renewal', format: '00000', nextValue: 7 }
        ]
      }
      """
    When method POST
    Then status 201
    And match response.code == code
    And match response.id == '#string'
    And match response.sequences == '#[2]'
    And match response.sequences[*].code contains only ['purchase', 'renewal']
    * def renewal = karate.filter(response.sequences, function (s) { return s.code == 'renewal' })[0]
    * match renewal.nextValue == 7
    * match renewal.format == '00000'

  Scenario: List generators with the stats envelope and a filter
    * def code = 'listed' + suffix
    * call read(setupPath + 'numgen.feature@generator') { code: '#(code)', name: 'Listed generator' }

    Given path 'servint', 'numberGenerators'
    And headers actor
    And param filters = 'code==' + code
    And param stats = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.results[0].code == code

    # Without stats the same listing is a plain array.
    Given path 'servint', 'numberGenerators'
    And headers actor
    And param filters = 'code==' + code
    When method GET
    Then status 200
    And match response == '#[1]'
    And match response[0].code == code

  Scenario: Fetch, update and delete a generator, cascading to its sequences
    * def code = 'crud' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(code)', name: 'Before rename' }
    * def generatorId = created.generatorId

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And request { owner: { id: '#(generatorId)' }, code: 'cascade', name: 'Cascade', format: '00000', nextValue: 1 }
    When method POST
    Then status 201
    * def sequenceId = response.id
    And match response.owner == { id: '#(generatorId)', name: 'Before rename', code: '#(code)' }

    Given path 'servint', 'numberGenerators', generatorId
    And headers actor
    When method GET
    Then status 200
    And match response.sequences == '#[1]'
    And match response.sequences[0].code == 'cascade'

    Given path 'servint', 'numberGenerators', generatorId
    And headers actor
    And request { name: 'After rename' }
    When method PUT
    Then status 200
    And match response.name == 'After rename'
    And match response.code == code

    Given path 'servint', 'numberGenerators', generatorId
    And headers actor
    When method DELETE
    Then status 204

    Given path 'servint', 'numberGenerators', generatorId
    And headers actor
    When method GET
    Then status 404

    # The owned sequence went with it.
    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    When method GET
    Then status 404

  Scenario: Sequences render the owner snippet and expanded refdata
    * def code = 'snippet' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(code)', name: 'Snippet generator' }
    * def generatorId = created.generatorId

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And request
      """
      {
        owner: { id: '#(generatorId)' },
        code: 'checked',
        name: 'Checked',
        format: '000000000',
        nextValue: 1,
        checkDigitAlgo: { value: 'ean13' },
        maximumNumber: 1000,
        maximumNumberThreshold: 900
      }
      """
    When method POST
    Then status 201
    * def sequenceId = response.id

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = 'owner.code==' + code
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[1]'
    * def listed = response[0]
    # Rendered outside the generator context, a sequence carries its owner as
    # an {id, name, code} snippet and its refdata associations expanded.
    * match listed.owner == { id: '#(generatorId)', name: 'Snippet generator', code: '#(code)' }
    * match listed.checkDigitAlgo.value == 'ean13'
    * match listed.checkDigitAlgo.label == '31-RTL-mod10-I (EAN)'
    # maximumCheck is derived at save time from nextValue against the bounds.
    * match listed.maximumCheck.value == 'below_threshold'

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    And request { nextValue: 950 }
    When method PUT
    Then status 200
    And match response.nextValue == 950
    And match response.maximumCheck.value == 'over_threshold'

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    And request { nextValue: 1000 }
    When method PUT
    Then status 200
    And match response.maximumCheck.value == 'at_maximum'

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    When method DELETE
    Then status 204

    Given path 'servint', 'numberGenerators', generatorId
    And headers actor
    When method GET
    Then status 200
    And match response.sequences == '#[0]'

  Scenario: Fetching an unknown generator or sequence answers 404
    Given path 'servint', 'numberGenerators', uuid()
    And headers actor
    When method GET
    Then status 404

    Given path 'servint', 'numberGeneratorSequences', uuid()
    And headers actor
    When method GET
    Then status 404

  Scenario: Sequence values above 32 bits survive the wire
    # The columns are BIGINT; values beyond Integer.MAX_VALUE must neither be
    # rejected on write nor wrap on read.
    * def code = 'bigvalues' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(code)', name: 'Big values' }
    * def generatorId = created.generatorId

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And request
      """
      {
        owner: { id: '#(generatorId)' },
        code: 'big',
        name: 'Big',
        nextValue: 2147483648,
        maximumNumber: 4294967296,
        maximumNumberThreshold: 3000000000
      }
      """
    When method POST
    Then status 201
    * def sequenceId = response.id

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    When method GET
    Then status 200
    And match response.nextValue == 2147483648
    And match response.maximumNumber == 4294967296
    And match response.maximumNumberThreshold == 3000000000
