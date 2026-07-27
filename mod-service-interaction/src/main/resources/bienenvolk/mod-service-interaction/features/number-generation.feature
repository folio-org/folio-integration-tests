Feature: Number generation

  # getNextNumber parity corpus. Every expected value below is a fixture of the
  # legacy module's own specification suite: formats, prefixes/postfixes,
  # output and pre-checksum templates, and all six check-digit algorithms.
  # A difference here means the two implementations disagree on the wire.

  Background:
    * url baseUrl
    * def actor = asUser(uuid())
    * def suffix = uuid().replace('-', '').substring(0, 8)
    * def createSequence =
      """
      function (body) {
        body.owner = { id: generatorId };
        return karate.call(setupPath + 'numgen.feature@sequence', { sequence: body }).sequenceId;
      }
      """
    * def next =
      """
      function (generatorCode, sequenceCode) {
        return karate.call(setupPath + 'numgen.feature@next',
          { generator: generatorCode, sequence: sequenceCode }).envelope;
      }
      """
    * def nextValue =
      """
      function (generatorCode, sequenceCode) {
        var envelope = next(generatorCode, sequenceCode);
        if (envelope.status == 'ERROR') {
          karate.fail('generation failed: ' + karate.toString(envelope));
        }
        return envelope.nextValue;
      }
      """

  Scenario: A missing generator and sequence are created on first use
    * def generatorCode = 'wibble' + suffix
    * def envelope = next(generatorCode, 'dibble')
    * match envelope.generator == generatorCode
    * match envelope.sequence == 'dibble'
    * match envelope.status == 'OK'
    # Library defaults: nine-digit zero padded, no prefix, no check digit.
    * match envelope.nextValue == '000000001'
    * match nextValue(generatorCode, 'dibble') == '000000002'

    # The auto-created rows are real and listable.
    Given path 'servint', 'numberGenerators'
    And headers actor
    And param filters = 'code==' + generatorCode
    When method GET
    Then status 200
    And match response == '#[1]'
    And match response[0].sequences[*].code contains 'dibble'

    # A second sequence under the same generator is created independently.
    * match nextValue(generatorCode, 'notdef') == '000000001'

  Scenario: Prefix, postfix and format render through the default template
    * def generatorCode = 'fixtures1' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Default template fixtures' }
    * def generatorId = created.generatorId

    * createSequence({ code: 'patron', name: 'patron', prefix: 'user', format: '000000000' })
    * createSequence({ code: 'staff', name: 'staff', prefix: 'staff', postfix: 'test', format: '000,000,000' })
    * createSequence({ code: 'noformat', name: 'noformat', prefix: 'nf' })
    * createSequence({ code: 'highinit', name: 'highinit', prefix: 'hi', format: '000000000', nextValue: 100000 })

    * match nextValue(generatorCode, 'patron') == 'user-000000001'
    * match nextValue(generatorCode, 'patron') == 'user-000000002'
    * match nextValue(generatorCode, 'patron') == 'user-000000003'
    * match nextValue(generatorCode, 'staff') == 'staff-000,000,001-test'
    # No format at all renders the raw value.
    * match nextValue(generatorCode, 'noformat') == 'nf-1'
    * match nextValue(generatorCode, 'highinit') == 'hi-000100000'

  Scenario: Check digits append through the default template
    * def generatorCode = 'fixtures2' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Check digit fixtures' }
    * def generatorId = created.generatorId

    * createSequence({ code: 'mod11test', name: 'mod11test', format: '000000000', nextValue: 100000, checkDigitAlgo: { value: 'isbn10checkdigit' } })
    * createSequence({ code: 'e069', name: 'e069', prefix: '069', postfix: '1', format: '000000000', checkDigitAlgo: { value: 'ean13' } })

    * match nextValue(generatorCode, 'mod11test') == '000100000-4'
    * match nextValue(generatorCode, 'e069') == '069-000000001-1-7'

  Scenario: Custom output templates place the number, the checksum and its input
    * def generatorCode = 'fixtures3' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Custom template fixtures' }
    * def generatorId = created.generatorId

    * createSequence({ code: 't0698', name: 't0698', format: '000000000', outputTemplate: '0698${generated_number}${checksum}', checkDigitAlgo: { value: 'ean13' } })
    * createSequence({ code: 't0699', name: 't0699', format: '000000000', outputTemplate: '0699-${generated_number}-${checksum}-post', checkDigitAlgo: { value: 'ean13' } })
    * createSequence({ code: 't0700', name: 't0700', format: '000000000', outputTemplate: '0700-${generated_number.substring(0,4)}-${checksum}-${generated_number.substring(4,9)}-post', checkDigitAlgo: { value: 'ean13' } })
    * createSequence({ code: 't0800', name: 't0800', format: '000000000', preChecksumTemplate: '100${generated_number}001', outputTemplate: '0700-${checksum_input_template}-${checksum}-post', checkDigitAlgo: { value: 'ean13' } })

    * match nextValue(generatorCode, 't0698') == '06980000000017'
    * match nextValue(generatorCode, 't0699') == '0699-000000001-7-post'
    # substring() slices the formatted number inside the template.
    * match nextValue(generatorCode, 't0700') == '0700-0000-7-00001-post'
    # A pre-checksum template feeds the check-digit input and is re-usable in
    # the output through ${checksum_input_template}.
    * match nextValue(generatorCode, 't0800') == '0700-100000000001001-3-post'

  Scenario: Every check-digit algorithm reproduces its legacy fixture
    * def generatorCode = 'fixtures5' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Checksum use cases' }
    * def generatorId = created.generatorId
    * def appendChecksum = '${checksum_input_template}${checksum}'

    * createSequence({ code: 'luhnTest', name: 'luhnTest', format: '00000000', nextValue: 117707, preChecksumTemplate: '22356${generated_number}', outputTemplate: appendChecksum, checkDigitAlgo: { value: 'luhncheckdigit' } })
    * createSequence({ code: 'eanTest', name: 'eanTest', format: '0000000', nextValue: 254, preChecksumTemplate: '0017${generated_number}', outputTemplate: appendChecksum, checkDigitAlgo: { value: 'ean13' } })
    * createSequence({ code: 'm1793', name: 'm1793', format: '00000000', nextValue: 771962, outputTemplate: '${generated_number}${checksum}077', checkDigitAlgo: { value: '1793_ltr_mod10_r' } })
    * createSequence({ code: 'm12', name: 'm12', format: '0000000', nextValue: 7298, preChecksumTemplate: '05${generated_number}01', outputTemplate: appendChecksum, checkDigitAlgo: { value: '12_ltr_mod10_r' } })
    * createSequence({ code: 'isbn10test', name: 'isbn10test', format: '000000000', nextValue: 30640615, outputTemplate: '${generated_number.substring(0,1)}-${generated_number.substring(1,4)}-${generated_number.substring(4,9)}-${checksum}', checkDigitAlgo: { value: 'isbn10checkdigit' } })
    * createSequence({ code: 'issntest', name: 'issntest', format: '0000000', nextValue: 317847, outputTemplate: '${generated_number.substring(0,4)}-${generated_number.substring(4,7)}${checksum}', checkDigitAlgo: { value: 'issncheckdigit' } })
    * createSequence({ code: 'issntestx', name: 'issntestx', format: '0000000', nextValue: 1050124, outputTemplate: '${generated_number.substring(0,4)}-${generated_number.substring(4,7)}${checksum}', checkDigitAlgo: { value: 'issncheckdigit' } })

    * match nextValue(generatorCode, 'luhnTest') == '22356001177070'
    * match nextValue(generatorCode, 'eanTest') == '001700002547'
    * match nextValue(generatorCode, 'm1793') == '007719628077'
    * match nextValue(generatorCode, 'm12') == '050007298013'
    * match nextValue(generatorCode, 'isbn10test') == '0-306-40615-2'
    * match nextValue(generatorCode, 'issntest') == '0317-8471'
    # The ISSN algorithm yields X for a remainder of 10.
    * match nextValue(generatorCode, 'issntestx') == '1050-124X'

  Scenario: A successful generation stamps the sequence's last used year
    * def generatorCode = 'lastused' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Last used year' }
    * def generatorId = created.generatorId
    * def sequenceId = createSequence({ code: 'stamped', name: 'stamped', format: '000' })

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    When method GET
    Then status 200
    And match response.lastUsedYear == '##null'

    * match nextValue(generatorCode, 'stamped') == '001'

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers actor
    When method GET
    Then status 200
    And match response.lastUsedYear == currentYear
    And match response.nextValue == 2

  Scenario: Repeated generation is gapless and never repeats a number
    # Sequential draws through the HTTP surface; the module takes a
    # pessimistic row lock per draw, so the values are consecutive and the
    # stored nextValue advances exactly once per request. (A true race needs
    # parallel clients — run this feature with a higher thread count to turn
    # it into a concurrency probe.)
    * def generatorCode = 'repeated' + suffix
    * def created = call read(setupPath + 'numgen.feature@generator') { code: '#(generatorCode)', name: 'Repeated draws' }
    * def generatorId = created.generatorId
    * createSequence({ code: 'drawn', name: 'drawn', format: '00000' })

    * def draw = function (i) { return nextValue(generatorCode, 'drawn') }
    * def drawn = karate.repeat(20, draw)
    * match drawn[0] == '00001'
    * match drawn[19] == '00020'
    * match drawn contains '00013'

    Given path 'servint', 'numberGeneratorSequences'
    And headers actor
    And param filters = 'owner.code==' + generatorCode
    When method GET
    Then status 200
    And match response[0].nextValue == 21
