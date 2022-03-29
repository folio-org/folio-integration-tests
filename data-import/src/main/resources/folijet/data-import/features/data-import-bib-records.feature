Feature: Test Data-Import bib records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def samplesPath = 'classpath:folijet/data-import/samples/'

    * def testInstanceRecordId = karate.properties['instanceRecordId']

  Scenario: Record should update record by matching on a repeatable MARC field
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile" : {
        "name" : "FAT-1523 mapping",
        "incomingRecordType" : "MARC_BIBLIOGRAPHIC",
        "existingRecordType" : "MARC_BIBLIOGRAPHIC",
        "description" : "",
        "marcFieldProtectionSettings" : [ ],
        "mappingDetails" : {
          "name" : "marcBib",
          "recordType" : "MARC_BIBLIOGRAPHIC",
          "mappingFields" : [ ],
          "marcMappingDetails" : [ {
            "order" : 0,
            "field" : {
              "field" : "260",
              "indicator1" : "*",
              "indicator2" : "*",
              "subfields" : [ {
                "subfield" : "a"
              } ]
            }
          } ],
          "marcMappingOption" : "UPDATE"
        }
      },
      "addedRelations" : [ ],
      "deletedRelations" : [ ]
    }
    """
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile" : {
        "name" : "FAT-1523 action",
        "description" : "",
        "action" : "UPDATE",
        "folioRecord" : "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations" : [ {
        "masterProfileId" : null,
        "masterProfileType" : "ACTION_PROFILE",
        "detailProfileId" : "#(mappingProfileId)",
        "detailProfileType" : "MAPPING_PROFILE",
        "order" : 0
      } ],
      "deletedRelations" : [ ]
    }
    """
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile" : {
        "name" : "FAT-1523 match profile",
        "description" : "",
        "incomingRecordType" : "MARC_BIBLIOGRAPHIC",
        "existingRecordType" : "MARC_BIBLIOGRAPHIC",
        "matchDetails" : [ {
          "matchCriterion" : "EXACTLY_MATCHES",
          "incomingRecordType" : "MARC_BIBLIOGRAPHIC",
          "incomingMatchExpression" : {
            "dataValueType" : "VALUE_FROM_RECORD",
            "fields" : [ {
              "label" : "field",
              "value" : "250"
            }, {
              "label" : "indicator1",
              "value" : ""
            }, {
              "label" : "indicator2",
              "value" : ""
            }, {
              "label" : "recordSubfield",
              "value" : "a"
            } ]
          },
          "existingRecordType" : "MARC_BIBLIOGRAPHIC",
          "existingMatchExpression" : {
            "dataValueType" : "VALUE_FROM_RECORD",
            "fields" : [ {
              "label" : "field",
              "value" : "250"
            }, {
              "label" : "indicator1",
              "value" : ""
            }, {
              "label" : "indicator2",
              "value" : ""
            }, {
              "label" : "recordSubfield",
              "value" : "a"
            } ]
          }
        } ],
      },
      "addedRelations" : [ ],
      "deletedRelations" : [ ]
    }
    """
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile" : {
        "name" : "FAT-1523 job profile",
        "description" : "",
        "dataType" : "MARC"
      },
      "addedRelations" : [ {
        "masterProfileId" : null,
        "masterProfileType" : "JOB_PROFILE",
        "detailProfileId" : "#(matchProfileId)",
        "detailProfileType" : "MATCH_PROFILE",
        "triggered" : false,
        "order" : 0
      }, {
        "masterProfileId" : "#(matchProfileId)",
        "masterProfileType" : "MATCH_PROFILE",
        "detailProfileId" : "#(actionProfileId)",
        "detailProfileType" : "ACTION_PROFILE",
        "reactTo" : "MATCH",
        "order" : 0
      } ],
      "deletedRelations" : [ ]
    }
    """
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import record
    Given call read(utilFeature+'@ImportRecord') { fileName:'marc-bib-matched', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

