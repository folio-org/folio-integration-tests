Feature: Listing grammar

  # Every collection endpoint speaks the web-toolkit (kiwt) listing grammar:
  # filters/match/term/sort/perPage/max/page/offset/stats. The corpus below
  # runs it against the number generator listings, where the semantics are
  # easiest to pin with known rows.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)
    * def generatorCode = 'lg' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Listing grammar rows' }
    * def generatorId = created.generatorId
    * def createSequence =
      """
      function (body) {
        body.owner = { id: generatorId };
        return karate.call(setupPath + 'numgen.feature@sequence', { sequence: body }).sequenceId;
      }
      """
    # Twelve rows so paging is observable, with distinct nextValues for the
    # comparison operators and one check-digit reference for the null tests.
    * createSequence({ code: 's01', name: 'alpha one', nextValue: 2, checkDigitAlgo: { value: 'ean13' } })
    * createSequence({ code: 's02', name: 'alpha two', nextValue: 6 })
    * createSequence({ code: 's03', name: 'beta three', nextValue: 9 })
    * createSequence({ code: 's04', name: 'beta four', nextValue: 2147483649 })
    # Zero padded so lexical sorting is unambiguous: s05 .. s12.
    * def filler =
      """
      function (i) {
        var n = i + 5;
        var code = (n < 10 ? 's0' : 's') + n;
        return createSequence({ code: code, name: 'filler ' + code, nextValue: 1 });
      }
      """
    * karate.repeat(8, filler)
    * def mine = 'owner.code==' + generatorCode

  Scenario: Comparison operators filter the listing
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'nextValue>5']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s02', 's03', 's04']

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'nextValue==6']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s02']

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'nextValue<=2']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains 's01'
    And match response[*].code !contains 's03'

  Scenario: is null and is not null work on association paths
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'checkDigitAlgo is not null']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s01']

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'checkDigitAlgo is null']
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[11]'
    And match response[*].code !contains 's01'

  Scenario: Compound expressions combine with && and ||
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'code==s01||code==s02']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s01', 's02']

    # Repeated filters parameters are ANDed together.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, '(code==s01||code==s02)&&nextValue>5']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s02']

    # A same-level chain of three terms is a flat disjunction.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'code==s01||code==s02||code==s03']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s01', 's02', 's03']

  Scenario: An empty right hand side drops the clause instead of failing
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'nextValue==']
    And param perPage = 100
    When method GET
    Then status 200
    # The clause is dropped; the remaining parameter still scopes the listing.
    And match response == '#[12]'

  Scenario: Operator spellings inside a value are absorbed as literal text
    # A leaf whose remainder carries further operator spellings collapses into
    # ONE comparison against the raw remainder — so this matches only a row
    # whose code literally contains the operator.
    * def literalCode = 'a==b' + suffix
    * call read(setupPath + 'numgen.feature@generator') { code: '#(literalCode)', name: 'Literal operator code' }

    Given path 'servint', 'numberGenerators'
    And headers actor
    And param filters = 'code==' + literalCode
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[1]'
    And match response[0].code == literalCode

  Scenario: Paging clamps silently and honours the legacy aliases
    # Absent perPage means the default page size of ten.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    When method GET
    Then status 200
    And match response == '#[10]'

    # Zero is treated as absent, not as an empty page.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param perPage = 0
    When method GET
    Then status 200
    And match response == '#[10]'

    # Above the cap the page size is clamped, never rejected.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param perPage = 101
    And param stats = true
    When method GET
    Then status 200
    And match response.pageSize == 100
    And match response.results == '#[12]'

    # max is the legacy alias for perPage.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param max = 5
    When method GET
    Then status 200
    And match response == '#[5]'

    # page is 1-based.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param perPage = 10
    And param page = 2
    When method GET
    Then status 200
    And match response == '#[2]'

  Scenario: The stats envelope carries the legacy fields
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param perPage = 100
    And param stats = true
    When method GET
    Then status 200
    And match response contains { results: '#array', pageSize: '#number', page: '#number', totalPages: '#number', totalRecords: '#number', total: '#number', meta: '#object' }
    And match response.totalRecords == 12
    * assert response.total == response.totalRecords
    * match response.meta == {}

  Scenario: Term matching searches the named properties
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param term = 'alpha'
    And param match = 'name'
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s01', 's02']

    # Several match properties are ORed, and the text block ANDs with filters.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param term = 's03'
    And param match = ['name', 'code']
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only ['s03']

  Scenario: Sorting is applied, and an unknown sort property is tolerated
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param sort = 'code;desc'
    And param perPage = 100
    When method GET
    Then status 200
    And match response[0].code == 's12'

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param sort = 'noSuchProperty;asc'
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[12]'

  Scenario: A filter naming an unknown property is refused
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'noSuchProperty==1']
    And param perPage = 100
    When method GET
    Then status 400

  Scenario: Unparseable paging and stats values behave as if absent
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param perPage = 'abc'
    When method GET
    Then status 200
    And match response == '#[10]'

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = mine
    And param stats = 'notabool'
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#array'

  Scenario: Malformed and uncoercible filter input
    # Registered deviations D-28 and D-30: the legacy module answers 500 on
    # these (an uncaught conversion/parse failure), while the port drops the
    # offending clause and answers 200 — legacy 500s on malformed input are
    # defects the port deliberately does not reproduce. A parity run should
    # show exactly this difference and nothing else.
    * def malformedStatus = impl == 'legacy' ? 500 : 200

    # A boolean property compared to garbage.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'enabled==notabool']
    And param perPage = 100
    When method GET
    Then match responseStatus == malformedStatus

    # An unbalanced parenthesis.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, '(code==s01']
    And param perPage = 100
    When method GET
    Then match responseStatus == malformedStatus

    # A numeric property compared to a non-number.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = [mine, 'nextValue>notanumber']
    And param perPage = 100
    When method GET
    Then match responseStatus == malformedStatus
