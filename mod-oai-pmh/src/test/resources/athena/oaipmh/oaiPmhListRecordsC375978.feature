@parallel=false
Feature: ListRecords: SRS & Inventory - Verify that deleted SRS and FOLIO Holdings are harvested (marc21_withholdings)

  # TestRail Case ID: C375978
  # JIRA: MODOAIPMH-138, MODOAIPMH-471, MODINVSTOR-1048, MODOAIPMH-479
  # Priority: Low
  # Test Group: Regression
  # Description: Verify that deleted SRS and FOLIO Holdings are harvested via ListRecords with marc21_withholdings

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

    # Current date function for date range filtering
    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    * def currentDate = currentOnlyDate()

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }


  @Positive @C375978
  Scenario: C375978 - Verify deleted SRS and FOLIO Holdings are harvested via ListRecords

    # Preconditions verification: Ensure "Record source" is set to "Source record storage and Inventory"
    # Preconditions verification: Ensure "Deleted records processing" setting is set to "Persistent"

    # Use instances from srs_init_data that have holdings
    * def srsInstanceId = '1640f178-f243-4e4a-bf1c-9e1e62b3171d'
    * def folioInstanceId = '8be05cf5-fb4f-4752-8094-8e179d08fb99'

    # Step 1-4: Create and delete MARC Holdings for SRS instance
    # Create a MARC holdings record for SRS instance
    * def srsHoldingId = '680bc49a-9845-4f08-a326-35c9ca7e6b1d'
    * def marcHolding =
      """
      {
        "id": "#(srsHoldingId)",
        "instanceId": "#(srsInstanceId)",
        "permanentLocationId": "f55d27c6-a8eb-461b-acd6-5dea81771e70",
        "holdingsTypeId": "996f93e2-5b5e-4cf2-9168-33ced1f95eed",
        "sourceId": "036ee84a-6afd-4c3c-9ad3-4a12ab875f59",
        "hrid": "hol000000000C375978111"
      }
      """

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request marcHolding
    When method POST
    Then status 201

    # Note the instance UUID before deletion
    * print 'SRS Instance UUID:', srsInstanceId

    * call sleep 1000

    # Delete the SRS MARC Holdings
    Given url baseUrl
    And path 'holdings-storage/holdings', srsHoldingId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    * call sleep 2000

    # Step 5-9: Create and delete FOLIO Holdings for FOLIO instance
    # Create a FOLIO holdings record
    * def folioHoldingId = '9a98e9a2-d4eb-4ad3-8555-e2a1469e06e8'
    * def folioHolding =
      """
      {
        "id": "#(folioHoldingId)",
        "instanceId": "#(folioInstanceId)",
        "permanentLocationId": "f55d27c6-a8eb-461b-acd6-5dea81771e70",
        "holdingsTypeId": "996f93e2-5b5e-4cf2-9168-33ced1f95eed",
        "sourceId": "f32d531e-df79-46b3-8932-cdd35f7a2264",
        "hrid": "hol000000000C375978222"
      }
      """

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioHolding
    When method POST
    Then status 201

    # Note the instance UUID before deletion
    * print 'FOLIO Instance UUID:', folioInstanceId

    * call sleep 1000

    # Delete the FOLIO Holdings
    Given url baseUrl
    And path 'holdings-storage/holdings', folioHoldingId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    * call sleep 2000

    # Step 10: Send GET request to ListRecords endpoint with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200

    # Verify both SRS and FOLIO records associated with deleted holdings are in response
    # The deleted Holdings record is treated as update of Instance record
    * def srsIdentifier = 'oai:folio.org:' + testUser.tenant + '/' + srsInstanceId
    * def folioIdentifier = 'oai:folio.org:' + testUser.tenant + '/' + folioInstanceId

    # Convert response to string for easier searching
    * def responseText = karate.toString(response)

    # Check that both instances appear in the response (as updated, not deleted, because only holdings were deleted)
    * assert responseText.contains(srsInstanceId)
    * assert responseText.contains(folioInstanceId)

    # Parse the XML and extract records
    * def records = karate.xmlPath(response, '//record')
    * print 'Total records found:', records.length

    # Verify both identifiers are present in the response
    * def srsFound = false
    * def folioFound = false

    * def checkIdentifier =
      """
      function(record) {
        var identifierNode = karate.xmlPath(record, '/record/header/identifier');
        if (identifierNode) {
          var identifier = identifierNode.textContent || identifierNode;
          karate.log('Checking identifier:', identifier);
          if (identifier.indexOf(srsInstanceId) > -1) {
            srsFound = true;
            karate.log('Found SRS instance');
          }
          if (identifier.indexOf(folioInstanceId) > -1) {
            folioFound = true;
            karate.log('Found FOLIO instance');
          }
        }
      }
      """

    * karate.forEach(records, checkIdentifier)

    * assert srsFound == true
    * assert folioFound == true

    * print 'Test completed - Both instances with deleted holdings were found in response'