Feature: Error handling matrix

  # Cross-cutting failure modes. Several of these are registered deviations:
  # the legacy module answers an uncaught 500 (or silently accepts bad input)
  # where the port answers a deterministic error envelope. Legacy 500s on
  # malformed input are defects the port deliberately does not reproduce, so a
  # parity run is EXPECTED to differ here — and only here.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)

  Scenario: A request without a tenant header is refused
    # Deviation D-23: the port answers folio-spring's 400 text/plain; the
    # legacy tenant resolver throws and surfaces a 500-class error. Only the
    # port side is pinned exactly — the legacy side asserts "an error", since
    # Okapi always injects the header in production.
    Given path 'servint', 'numberGenerators'
    And headers { 'Content-Type': 'application/json', 'X-Okapi-Token': 'DUMMY' }
    And param perPage = 10
    When method GET
    Then assert responseStatus >= 400
    * if (impl != 'port') karate.abort()
    * match responseStatus == 400
    * match response contains 'x-okapi-tenant'

  Scenario: A malformed JSON body is refused
    # Deviation D-22: the port answers 400 with a malformed.json envelope; the
    # legacy behaviour was never pinned to a status, so only "an error" is
    # asserted there.
    Given path 'servint', 'numberGenerators'
    And headers actor
    And request '{"code":"broken"'
    When method POST
    Then assert responseStatus >= 400
    * if (impl != 'port') karate.abort()
    * match responseStatus == 400
    * match response.errors[0].code == 'malformed.json'

  Scenario: A duplicate generator code conflicts
    # Deviation D-24: the unique index fires either way, and no row is written;
    # legacy surfaces it as an uncaught 500, the port as a sanitized 409 that
    # never leaks constraint names or SQL state.
    * def code = 'dup' + suffix
    * call read(setupPath + 'numgen.feature@generator') { code: '#(code)', name: 'Original' }

    Given path 'servint', 'numberGenerators'
    And headers actor
    And request { code: '#(code)', name: 'Duplicate' }
    When method POST
    Then match responseStatus == (impl == 'legacy' ? 500 : 409)
    * if (impl != 'port') karate.abort()
    * match response.errors[0].code == 'integrity.violation'
    * def body = karate.toString(response)
    * match body !contains 'duplicate key'
    * match body !contains 'ng_code'

    # Either way exactly one row exists.
    Given path 'servint', 'numberGenerators'
    And headers actor
    And param filters = 'code==' + code
    When method GET
    Then status 200
    And match response == '#[1]'

  Scenario: An unknown refdata value in a body
    # Deviation D-25: legacy binds an unresolvable refdata reference to null
    # and saves anyway — silently dropping the check digit the caller asked
    # for; the port refuses the write.
    * def code = 'unknownrefdata' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(code)', name: 'Unknown refdata' }
    * def generatorId = created.generatorId

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And request { owner: { id: '#(generatorId)' }, code: 'nope', name: 'nope', format: '000', checkDigitAlgo: { value: 'nope' } }
    When method POST
    Then match responseStatus == (impl == 'legacy' ? 201 : 400)
    * if (impl != 'port') karate.abort()
    * match response.errors[0].code == 'unknown.refdata'

  Scenario: A validation failure answers 422
    # The status and the trigger are identical on both sides; only the body
    # shape differs (deviation D-6), so only the status is asserted.
    Given path 'servint', 'refdata'
    And headers actor
    And request { values: [{ label: 'No category descriptor' }] }
    When method POST
    Then status 422

  Scenario: An unknown widget instance id
    # Deviation D-3: legacy dereferences the null read and answers 500; the
    # port answers 404.
    Given path 'servint', 'widgets', 'instances', uuid()
    And headers actor
    When method GET
    Then match responseStatus == (impl == 'legacy' ? 500 : 404)

  Scenario: Unknown ids on the CRUD surfaces answer 404
    Given path 'servint', 'numberGenerators', uuid()
    And headers actor
    When method GET
    Then status 404

    Given path 'servint', 'numberGeneratorSequences', uuid()
    And headers actor
    And request { nextValue: 5 }
    When method PUT
    Then status 404

    Given path 'servint', 'settings', 'appSettings', uuid()
    And headers actor
    When method DELETE
    Then status 404

    # Dashboards gate on access before existence, so an unknown id is a 403
    # for an ordinary caller and a 404 only for the admin override.
    Given path 'servint', 'dashboard', uuid()
    And headers actor
    When method GET
    Then status 403

    Given path 'servint', 'dashboard', uuid()
    And headers asAdmin(uuid())
    When method GET
    Then status 404
