Feature: Sequence maximum limits

  # Guard rails around the sequence ceiling: the module warns as a sequence
  # approaches its maximum, warns again on the last usable value, and refuses —
  # without consuming the value — beyond it. The HTTP status is always 200;
  # the outcome is the envelope's status/warningCode/errorCode.
  #
  # (The NoNextValue error path is not reachable through the API: it needs a
  # sequence whose next value cannot be resolved at all, which the write
  # surface will not create.)

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)
    * def generatorCode = 'limits' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Limit fixtures' }
    * def generatorId = created.generatorId
    * def createSequence =
      """
      function (body) {
        body.owner = { id: generatorId };
        return karate.call(setupPath + 'numgen.feature@sequence', { sequence: body }).sequenceId;
      }
      """
    * def next =
      """
      function (sequenceCode) {
        return karate.call(setupPath + 'numgen.feature@next',
          { generator: generatorCode, sequence: sequenceCode }).envelope;
      }
      """

  Scenario: Hitting the maximum still generates, with a HitMaximum warning
    * createSequence({ code: 'atMax', name: 'atMax', format: '000', nextValue: 5, maximumNumber: 5 })
    * def envelope = next('atMax')
    * match envelope.status == 'WARNING'
    * match envelope.warningCode == 'HitMaximum'
    * match envelope.nextValue == '005'

  Scenario: Passing the threshold generates with an OverThreshold warning
    * createSequence({ code: 'overThr', name: 'overThr', format: '000', nextValue: 5, maximumNumber: 10, maximumNumberThreshold: 3 })
    * def envelope = next('overThr')
    * match envelope.status == 'WARNING'
    * match envelope.warningCode == 'OverThreshold'
    * match envelope.nextValue == '005'

  Scenario: A threshold equal to the maximum warns HitMaximum at the maximum
    * createSequence({ code: 'thrEqMax', name: 'thrEqMax', format: '000', nextValue: 5, maximumNumber: 5, maximumNumberThreshold: 5 })
    * def envelope = next('thrEqMax')
    * match envelope.status == 'WARNING'
    * match envelope.warningCode == 'HitMaximum'

  Scenario: Exceeding the maximum is refused and consumes nothing
    * def sequenceId = createSequence({ code: 'exceeded', name: 'exceeded', format: '000', nextValue: 6, maximumNumber: 5 })

    * def envelope = next('exceeded')
    * match envelope.status == 'ERROR'
    * match envelope.errorCode == 'MaxReached'
    * match envelope.nextValue == '##null'

    # The transaction rolled back: the value was not consumed, so a second
    # attempt fails identically instead of creeping past the ceiling.
    * def again = next('exceeded')
    * match again.errorCode == 'MaxReached'

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    When method GET
    Then status 200
    And match response.nextValue == 6

  Scenario: Far below the threshold generates normally
    * createSequence({ code: 'farBelow', name: 'farBelow', format: '000', nextValue: 2, maximumNumber: 1000, maximumNumberThreshold: 900 })
    * def envelope = next('farBelow')
    * match envelope.status == 'OK'
    * match envelope.nextValue == '002'
    * match envelope.warningCode == '##null'
