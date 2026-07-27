Feature: Year-based sequence reset

  # Year-scoped numbering: the ${current_year} token renders the current UTC
  # year, and a sequence flagged resetOnYearChange restarts at 1 on its first
  # use in a new year — either lazily on generation, or in bulk through the
  # timer-driven sweep Okapi calls every 24 hours.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)
    * def generatorCode = 'yearreset' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Year reset fixtures' }
    * def generatorId = created.generatorId
    * def createSequence =
      """
      function (body) {
        body.owner = { id: generatorId };
        return karate.call(setupPath + 'numgen.feature@sequence', { sequence: body }).sequenceId;
      }
      """
    * def nextValue =
      """
      function (sequenceCode) {
        return karate.call(setupPath + 'numgen.feature@next',
          { generator: generatorCode, sequence: sequenceCode }).envelope.nextValue;
      }
      """

  Scenario: The year token renders the current UTC year
    * createSequence({ code: 'ytAbc', name: 'ytAbc', format: '000', outputTemplate: '${current_year}-ABC ${generated_number}' })
    * createSequence({ code: 'yt01a', name: 'yt01a', format: '0000', outputTemplate: '01A-${current_year}-${generated_number}' })

    * match nextValue('ytAbc') == currentYear + '-ABC 001'
    * match nextValue('yt01a') == '01A-' + currentYear + '-0001'

  Scenario: A stale year restarts the sequence when the reset flag is set
    * createSequence({ code: 'ytReset', name: 'ytReset', format: '000', nextValue: 150, outputTemplate: '${current_year}-${generated_number}', resetOnYearChange: true, lastUsedYear: '2020' })

    * match nextValue('ytReset') == currentYear + '-001'
    * match nextValue('ytReset') == currentYear + '-002'

  Scenario: A stale year keeps counting when the reset flag is not set
    * createSequence({ code: 'ytNoReset', name: 'ytNoReset', format: '000', nextValue: 150, outputTemplate: '${current_year}-${generated_number}', lastUsedYear: '2020' })

    * match nextValue('ytNoReset') == currentYear + '-150'
    * match nextValue('ytNoReset') == currentYear + '-151'

  Scenario: An unpadded format resets the same way
    * createSequence({ code: 'ytUnpadded', name: 'ytUnpadded', format: '###', nextValue: 150, outputTemplate: '${current_year}-${generated_number}', resetOnYearChange: true, lastUsedYear: '2020' })

    * match nextValue('ytUnpadded') == currentYear + '-1'
    * match nextValue('ytUnpadded') == currentYear + '-2'

  Scenario: The reset flag requires the year token in the output template
    # Without ${current_year} the reset would silently re-issue numbers already
    # handed out, so the save is refused.
    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And request
      """
      {
        owner: { id: '#(generatorId)' },
        code: 'ytInvalid',
        name: 'ytInvalid',
        format: '000',
        outputTemplate: '${generated_number}',
        resetOnYearChange: true
      }
      """
    When method POST
    Then status 422

  Scenario: The timer sweep resets only stale year-scoped sequences
    * def resetId = createSequence({ code: 'timerReset', name: 'timerReset', format: '000', nextValue: 5, outputTemplate: '${current_year}-${generated_number}', resetOnYearChange: true, lastUsedYear: '2020' })
    * def controlId = createSequence({ code: 'timerControl', name: 'timerControl', format: '000', nextValue: 5, lastUsedYear: '2020' })

    Given path 'servint', 'numberGenerators', 'resetYearSequences'
    And headers actor
    When method POST
    Then status 200
    And match response.currentYear == currentYear
    And match response.sequencesReset == '#number'

    Given path 'servint', 'numberGeneratorSequences', resetId
    And headers actor
    When method GET
    Then status 200
    And match response.nextValue == 1
    And match response.lastUsedYear == currentYear

    # The control sequence never opted in: untouched.
    Given path 'servint', 'numberGeneratorSequences', controlId
    And headers actor
    When method GET
    Then status 200
    And match response.nextValue == 5
    And match response.lastUsedYear == '2020'

    # The sweep is idempotent — a second run has nothing left to reset here.
    Given path 'servint', 'numberGenerators', 'resetYearSequences'
    And headers actor
    When method POST
    Then status 200

    Given path 'servint', 'numberGeneratorSequences', resetId
    And headers actor
    When method GET
    Then status 200
    And match response.nextValue == 1
