Feature: Reference data seeding

  # Tenant seeding follows two buckets with different triggers: the baseline
  # vocabularies are materialised on EVERY enable, while the check-digit
  # vocabulary and the default number generators need the tenant parameter
  # loadReference="true" and the bundled widget types need loadSample="true".
  #
  # Each scenario enables its own throwaway tenant so the counts are exact.

  Background:
    * url baseUrl
    * def scratchTenant = 'krd' + uuid().replace('-', '').substring(0, 10)
    * def scratchHeaders =
      """
      {
        'Content-Type': 'application/json',
        'X-Okapi-Tenant': '#(scratchTenant)',
        'X-Okapi-Url': '#(okapiUrl)',
        'X-Okapi-Token': 'DUMMY',
        'X-Okapi-User-Id': '#(uuid())'
      }
      """
    * def categoryNamed =
      """
      function (categories, desc) {
        var hit = karate.filter(categories, function (c) { return c.desc == desc });
        return hit.length ? hit[0] : null;
      }
      """
    * def labelOf =
      """
      function (values, value) {
        var hit = karate.filter(values, function (v) { return v.value == value });
        return hit.length ? hit[0].label : null;
      }
      """
    * def defaultGeneratorCodes =
      """
      [
        'openAccess',
        'patronRequest',
        'users_patronBarcode',
        'organizations_vendorCode',
        'inventory_accessionNumber',
        'inventory_callNumber',
        'inventory_itemBarcode',
        'inventory_instanceIdentifier',
        'serialsManagement_patternNumber'
      ]
      """

  Scenario: Enable without parameters seeds only the baseline vocabularies
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)' }

    Given path 'servint', 'refdata'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    * def categories = response

    * def access = categoryNamed(categories, 'DashboardAccess.Access')
    * match access != null
    * match access.internal == true
    * match access.values[*].value contains only ['manage', 'edit', 'view']
    * assert labelOf(access.values, 'manage') == 'Manage'
    * assert labelOf(access.values, 'edit') == 'Edit'
    * assert labelOf(access.values, 'view') == 'View'

    * def maximumCheck = categoryNamed(categories, 'NumberGeneratorSequence.MaximumCheck')
    * match maximumCheck != null
    * match maximumCheck.values[*].value contains only ['below_threshold', 'over_threshold', 'at_maximum']

    # The loadReference bucket stayed shut.
    * def checkDigitAlgo = categoryNamed(categories, 'NumberGeneratorSequence.CheckDigitAlgo')
    * match checkDigitAlgo == null
    * match categories[*].desc contains only ['DashboardAccess.Access', 'NumberGeneratorSequence.MaximumCheck']

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    And match response == []

    # ... and so did the loadSample bucket.
    Given path 'servint', 'widgets', 'types'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    And match response == []

  Scenario: The check digit vocabulary is seeded on reference load
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)', loadReference: true }

    Given path 'servint', 'refdata'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    * def algo = categoryNamed(response, 'NumberGeneratorSequence.CheckDigitAlgo')
    * match algo != null
    * match algo.values[*].value contains only
      """
      [
        'none', 'ean13', '1793_ltr_mod10_r', '12_ltr_mod10_r',
        'isbn10checkdigit', 'issncheckdigit', 'luhncheckdigit'
      ]
      """
    # Exact legacy labels — these render in the UI's algorithm picker.
    * assert labelOf(algo.values, 'none') == 'None'
    * assert labelOf(algo.values, 'ean13') == '31-RTL-mod10-I (EAN)'
    * assert labelOf(algo.values, '1793_ltr_mod10_r') == '1793-LTR-mod10-R'
    * assert labelOf(algo.values, '12_ltr_mod10_r') == '12-LTR-mod10-R'
    * assert labelOf(algo.values, 'isbn10checkdigit') == '2345678910-RTL-mod11-I-X (ISBN10)'
    * assert labelOf(algo.values, 'issncheckdigit') == '8765432-LTR-mod11-I-X (ISSN)'
    * assert labelOf(algo.values, 'luhncheckdigit') == '21-RTL-mod10-I (Luhn)'

  Scenario: The default number generators are seeded on reference load
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)', loadReference: true }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    And param sort = 'code;asc'
    When method GET
    Then status 200
    * def generators = response
    * match generators[*].code contains only defaultGeneratorCodes

    * def generatorNamed =
      """
      function (code) {
        var hit = karate.filter(generators, function (g) { return g.code == code });
        return hit.length ? hit[0] : null;
      }
      """
    * def sequenceNamed =
      """
      function (generator, code) {
        var hit = karate.filter(generator.sequences, function (s) { return s.code == code });
        return hit.length ? hit[0] : null;
      }
      """

    # Every seeded sequence starts unconsumed.
    * def openAccess = generatorNamed('openAccess')
    * match openAccess.name == 'Open access: Publication request number'
    * def requestSequence = sequenceNamed(openAccess, 'requestSequence')
    * match requestSequence.format == '000000000'
    * match requestSequence.outputTemplate == 'oa-${generated_number}'
    * match requestSequence.nextValue == 1
    * match requestSequence.checkDigitAlgo.value == 'none'

    # Two sequences under one generator, both check-digited.
    * def patronBarcode = generatorNamed('users_patronBarcode')
    * match patronBarcode.sequences[*].code contains only ['patron', 'staff']
    * def patron = sequenceNamed(patronBarcode, 'patron')
    * def staff = sequenceNamed(patronBarcode, 'staff')
    * match patron.outputTemplate == 'P${generated_number}-${checksum}'
    * match patron.checkDigitAlgo.value == 'ean13'
    * match staff.outputTemplate == 'S${generated_number}-${checksum}'
    * match staff.checkDigitAlgo.value == 'ean13'

    # SI-171: the instance identifier generator, seeded alongside the rest.
    * def instanceIdentifier = generatorNamed('inventory_instanceIdentifier')
    * match instanceIdentifier.name == 'Inventory: Instance identifier'
    * def instanceSequence = sequenceNamed(instanceIdentifier, 'instanceIdentifier')
    * match instanceSequence.name == 'Instance identifier'
    * match instanceSequence.format == '0000000000'
    * match instanceSequence.outputTemplate == '${generated_number}'
    * match instanceSequence.nextValue == 1

    * def vendor = sequenceNamed(generatorNamed('organizations_vendorCode'), 'vendor')
    * def accession = sequenceNamed(generatorNamed('inventory_accessionNumber'), 'accessionNumber')
    * def pattern = sequenceNamed(generatorNamed('serialsManagement_patternNumber'), 'patternNumber')
    * match vendor.outputTemplate == 'K${generated_number}'
    * match accession.format == '00000'
    * match pattern.outputTemplate == 'pattern-${generated_number}'

  Scenario: Widget types are imported on sample load
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)', loadSample: true }

    Given path 'servint', 'widgets', 'types'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    And match response[*].name contains 'SimpleSearch'
    * def simpleSearch = karate.filter(response, function (t) { return t.name == 'SimpleSearch' })[0]
    * match simpleSearch.typeVersion == '1.0'
    * match simpleSearch.schema == '#string'

    # The sample bucket does not open the reference bucket.
    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    And match response == []

  Scenario: Reference loads are idempotent and keep advanced sequence state
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)', loadReference: true }

    Given path 'servint', 'numberGeneratorSequences'
    And headers scratchHeaders
    And param filters = 'owner.code==openAccess'
    And param perPage = 100
    When method GET
    Then status 200
    * def sequenceId = response[0].id

    # The tenant advances a seeded sequence...
    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers scratchHeaders
    And request { nextValue: 500 }
    When method PUT
    Then status 200
    And match response.nextValue == 500

    # ... and a repeat reference load must neither duplicate nor reset it.
    * call read(setupPath + 'tenant.feature@enable') { tenant: '#(scratchTenant)', loadReference: true }

    Given path 'servint', 'numberGenerators'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].code contains only defaultGeneratorCodes

    Given path 'servint', 'numberGeneratorSequences', sequenceId
    And headers scratchHeaders
    When method GET
    Then status 200
    And match response.nextValue == 500

    Given path 'servint', 'refdata'
    And headers scratchHeaders
    And param perPage = 100
    When method GET
    Then status 200
    And match response[*].desc contains only
      """
      [
        'DashboardAccess.Access',
        'NumberGeneratorSequence.MaximumCheck',
        'NumberGeneratorSequence.CheckDigitAlgo'
      ]
      """
