Feature: Query dynamic MARC fields

  # Exercises the dynamic MARC field grammar against the composite_instance_srs_bib entity type.
  # MARC fields are not declared columns; they are referenced by name and recognized at query time.

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure retry = { count: 30, interval: 2000 }
    * def marcBibEntityTypeId = 'bce8ea43-1271-54ca-99ad-aa185e8b5b1b'
    * def marcInstanceId = 'aa000000-0000-4000-8000-0000000000a1'
    * def marcTitle = 'Integration MARC title'
    * def marcStatement = 'an integration statement'

  Scenario: Tag-only MARC field returns every subfield value for the tag
    * def fqlQuery = '{"marc_bib.marc_245":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_245'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_245'] contains marcTitle
    And match response.content[0]['marc_bib.marc_245'] contains marcStatement

  Scenario: Subfield MARC field returns only the targeted subfield
    * def fqlQuery = '{"marc_bib.marc_245_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_245_a'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_245_a'] contains marcTitle
    And match response.content[0]['marc_bib.marc_245_a'] !contains marcStatement

  Scenario: Indicator-target MARC field returns the indicator value
    * def fqlQuery = '{"marc_bib.marc_245_ind1":{"$eq":"1"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_245_ind1'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_245_ind1'] contains '1'

  Scenario: Constrained-subfield MARC field (one indicator) returns the subfield when the indicator matches
    * def fqlQuery = '{"marc_bib.marc_245_ind1_1_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_245_ind1_1_a'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_245_ind1_1_a'] contains marcTitle

  Scenario: Dual-indicator subfield MARC field returns the subfield when both indicators match
    * def fqlQuery = '{"marc_bib.marc_245_ind1_1_ind2_0_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_245_ind1_1_ind2_0_a'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_245_ind1_1_ind2_0_a'] contains marcTitle

  Scenario: Constrained indicator-target MARC field returns the target indicator when the other matches
    * def fqlQuery = '{"marc_bib.marc_245_ind2_0_ind1":{"$eq":"1"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_245_ind2_0_ind1'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_245_ind2_0_ind1'] contains '1'

  Scenario: Tag-only MARC field on a control field returns the control-field value
    * def fqlQuery = '{"marc_bib.marc_001":{"$eq":"marcbibinttest01"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(fqlQuery)', fields: ['instance.id', 'marc_bib.marc_001'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.content[0]['instance.id'] == marcInstanceId
    And match response.content[0]['marc_bib.marc_001'] contains 'marcbibinttest01'

  Scenario: Indicator constraints actually filter (no match when a constrained indicator differs)
    # First confirm the record is indexed via a query known to match, so the negative checks below are not
    # false passes caused by indexing lag.
    * def presentQuery = '{"marc_bib.marc_245_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(presentQuery)', fields: ['instance.id'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # One indicator constrained: seeded 245 has ind1=1, so constraining ind1=3 must exclude it.
    * def missOneIndicator = '{"marc_bib.marc_245_ind1_3_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(missOneIndicator)', fields: ['instance.id'] }
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Dual-indicator: seeded 245 is ind1=1/ind2=0. A wrong ind2 must exclude it even though ind1 matches -
    # guards against ind2 being dropped from the SQL, which the positive scenario (matching on ind1) can't catch.
    * def missDualIndicator = '{"marc_bib.marc_245_ind1_1_ind2_9_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(missDualIndicator)', fields: ['instance.id'] }
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Constrained indicator-target: constrain ind2=9 (seeded is ind2=0) while targeting ind1 - must exclude,
    # proving the constraint is applied to the indicator-target query shape too.
    * def missIndicatorTarget = '{"marc_bib.marc_245_ind2_9_ind1":{"$eq":"1"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(missIndicatorTarget)', fields: ['instance.id'] }
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Value and tag predicates exclude non-matching records
    * def presentQuery = '{"marc_bib.marc_245_a":{"$eq":"' + marcTitle + '"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(presentQuery)', fields: ['instance.id'] }
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # Wrong value: the value predicate must exclude a value the 245 $a does not hold.
    * def missValue = '{"marc_bib.marc_245_a":{"$eq":"No such MARC value"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(missValue)', fields: ['instance.id'] }
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Tag scoping: "Integration MARC variant" is the 246 $a, not the 245 $a - a 245 query must not match 246
    # content, proving field_no is enforced.
    * def missTag = '{"marc_bib.marc_245_a":{"$eq":"Integration MARC variant"}}'
    Given path 'query'
    And params { entityTypeId: '#(marcBibEntityTypeId)', query: '#(missTag)', fields: ['instance.id'] }
    When method GET
    Then status 200
    And match response.totalRecords == 0
