Feature: number generator helpers

  Background:
    * url baseUrl
    * def actor = asUser(__arg.user ? __arg.user : uuid())

  @generator
  Scenario: create a number generator
    Given path 'servint', 'numberGenerators'
    And headers actor
    And request { code: '#(__arg.code)', name: '#(__arg.name ? __arg.name : __arg.code)' }
    When method POST
    Then status 201
    * def generatorId = response.id

  @sequence
  Scenario: create a sequence from a full payload (owner included by the caller)
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And request __arg.sequence
    When method POST
    Then status 201
    * def sequenceId = response.id
    * def sequence = response

  @next
  Scenario: draw the next number from a sequence
    # HTTP status is always 200 — the outcome (OK / WARNING / ERROR) travels in
    # the envelope, so callers assert on `status`, never on the HTTP code.
    Given path 'servint', 'numberGenerators', 'getNextNumber'
    And headers actor
    And param generator = __arg.generator
    And param sequence = __arg.sequence
    When method GET
    Then status 200
    * def envelope = response
