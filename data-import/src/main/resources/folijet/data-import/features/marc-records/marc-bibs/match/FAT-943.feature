Feature: FAT-943

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-943 Match MARC-to-MARC and update Instances, Holdings, and Items 5
    * print 'FAT-943 Match MARC-to-MARC and update Instance, Holdings, and Items'

    # Create mapping profile for Instance
    # MARC-to-Instance (Checks Suppress from discovery, changes the statistical code (PTF5), changes status to Uncataloged)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943_New: MARC-to-Instance",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "FAT-943_New: MARC-to-Instance",
          "mappingDetails": {
            "name": "instance",
            "recordType": "INSTANCE",
            "mappingFields": [
              {
                "name": "discoverySuppress",
                "enabled": true,
                "path": "instance.discoverySuppress",
                "value": "",
                "subfields": [],
                "booleanFieldAction": "ALL_TRUE"
              },
              {
                "name": "staffSuppress",
                "enabled": true,
                "path": "instance.staffSuppress",
                "value": "",
                "subfields": []
              },
              {
                "name": "previouslyHeld",
                "enabled": true,
                "path": "instance.previouslyHeld",
                "value": "",
                "subfields": []
              },
              {
                "name": "hrid",
                "enabled": false,
                "path": "instance.hrid",
                "value": "",
                "subfields": []
              },
              {
                "name": "source",
                "enabled": false,
                "path": "instance.source",
                "value": "",
                "subfields": []
              },
              {
                "name": "catalogedDate",
                "enabled": true,
                "path": "instance.catalogedDate",
                "value": "",
                "subfields": []
              },
              {
                "name": "statusId",
                "enabled": true,
                "path": "instance.statusId",
                "value": "\"Uncataloged\"",
                "subfields": [],
                "acceptedValues": {
                  "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                  "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged",
                  "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41": "Not yet assigned",
                  "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other",
                  "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary",
                  "26f5208e-110a-4394-be29-1569a8c84a65": "Uncataloged"
                }
              },
              {
                "name": "modeOfIssuanceId",
                "enabled": false,
                "path": "instance.modeOfIssuanceId",
                "value": "",
                "subfields": []
              },
              {
                "name": "statisticalCodeIds",
                "enabled": true,
                "path": "instance.statisticalCodeIds[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "instance.statisticalCodeIds[]",
                    "fields": [
                      {
                        "name": "statisticalCodeId",
                        "enabled": true,
                        "path": "instance.statisticalCodeIds[]",
                        "value": "\"PTF: PTF5 - PTF5\""
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "title",
                "enabled": false,
                "path": "instance.title",
                "value": "",
                "subfields": []
              },
              {
                "name": "alternativeTitles",
                "enabled": false,
                "path": "instance.alternativeTitles[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "indexTitle",
                "enabled": false,
                "path": "instance.indexTitle",
                "value": "",
                "subfields": []
              },
              {
                "name": "series",
                "enabled": false,
                "path": "instance.series[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "precedingTitles",
                "enabled": false,
                "path": "instance.precedingTitles[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "succeedingTitles",
                "enabled": false,
                "path": "instance.succeedingTitles[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "identifiers",
                "enabled": false,
                "path": "instance.identifiers[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "contributors",
                "enabled": false,
                "path": "instance.contributors[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "publication",
                "enabled": false,
                "path": "instance.publication[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "editions",
                "enabled": false,
                "path": "instance.editions[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "physicalDescriptions",
                "enabled": false,
                "path": "instance.physicalDescriptions[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "instanceTypeId",
                "enabled": false,
                "path": "instance.instanceTypeId",
                "value": "",
                "subfields": []
              },
              {
                "name": "natureOfContentTermIds",
                "enabled": true,
                "path": "instance.natureOfContentTermIds[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "instanceFormatIds",
                "enabled": false,
                "path": "instance.instanceFormatIds[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "languages",
                "enabled": false,
                "path": "instance.languages[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "publicationFrequency",
                "enabled": false,
                "path": "instance.publicationFrequency[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "publicationRange",
                "enabled": false,
                "path": "instance.publicationRange[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "notes",
                "enabled": false,
                "path": "instance.notes[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "electronicAccess",
                "enabled": false,
                "path": "instance.electronicAccess[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "subjects",
                "enabled": false,
                "path": "instance.subjects[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "classifications",
                "enabled": false,
                "path": "instance.classifications[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "parentInstances",
                "enabled": true,
                "path": "instance.parentInstances[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "childInstances",
                "enabled": true,
                "path": "instance.childInstances[]",
                "value": "",
                "subfields": []
              }
            ]
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Instance
    * def folioRecord = 'INSTANCE'
    * def folioRecordNameAndDescription = 'FAT-943_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileInstanceId = $.id

    # MARC-to-Holdings (Only mapped field is Holdings statement staff note, from 300$a. Deletes former holdings ID and replaces it with Holdings ID 5. Same for stat codes - delete and replace with PTF5. Adds a new temp location. Add 5 to Shelving title, Prefix, and Suffix. Adds a holding statement with a public and staff note. Adds another Holdings note)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943_New - MARC-to-Holdings",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "FAT-943_New - MARC-to-Holdings",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "discoverySuppress",
                "enabled": true,
                "path": "holdings.discoverySuppress",
                "value": "",
                "subfields": [],
                "booleanFieldAction": "ALL_TRUE"
              },
              {
                "name": "hrid",
                "enabled": false,
                "path": "holdings.discoverySuppress",
                "value": "",
                "subfields": []
              },
              {
                "name": "formerIds",
                "enabled": true,
                "path": "holdings.formerIds[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "holdings.formerIds[]",
                    "fields": [
                      {
                        "name": "formerId",
                        "enabled": true,
                        "path": "holdings.formerIds[]",
                        "value": "\"5\""
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "holdingsTypeId",
                "enabled": true,
                "path": "holdings.holdingsTypeId",
                "value": "",
                "subfields": [],
                "acceptedValues": {
                  "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                  "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                  "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                  "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                  "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
                }
              },
              {
                "name": "statisticalCodeIds",
                "enabled": true,
                "path": "holdings.statisticalCodeIds[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "permanentLocationId",
                "enabled": true,
                "path": "holdings.permanentLocationId",
                "value": "\"Annex (KU/CC/DI/A)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
                }
              },
              {
                "name": "temporaryLocationId",
                "enabled": true,
                "path": "holdings.temporaryLocationId",
                "value": "\"Online (E)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
                }
              },
              {
                "name": "shelvingOrder",
                "enabled": true,
                "path": "holdings.shelvingOrder",
                "value": "",
                "subfields": []
              },
              {
                "name": "shelvingTitle",
                "enabled": true,
                "path": "holdings.shelvingTitle",
                "value": "\"5\"",
                "subfields": []
              },
              {
                "name": "copyNumber",
                "enabled": true,
                "path": "holdings.copyNumber",
                "value": "",
                "subfields": []
              },
              {
                "name": "callNumberTypeId",
                "enabled": true,
                "path": "holdings.callNumberTypeId",
                "value": "",
                "subfields": [],
                "acceptedValues": {
                  "03dd64d0-5626-4ecd-8ece-4531e0069f35": "Dewey Decimal classification",
                  "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                  "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification",
                  "828ae637-dfa3-4265-a1af-5279c436edff": "MOYS",
                  "054d460d-d6b9-4469-9e37-7a78a2266655": "National Library of Medicine classification",
                  "6caca63e-5651-4db6-9247-3205156e9699": "Other scheme",
                  "cd70562c-dd0b-42f6-aa80-ce803d24d4a1": "Shelved separately",
                  "28927d76-e097-4f63-8510-e56f2b7a3ad0": "Shelving control number",
                  "827a2b64-cbf5-4296-8545-130876e4dfc0": "Source specified in subfield $2",
                  "fc388041-6cd0-4806-8a74-ebe3b9ab4c6e": "Superintendent of Documents classification",
                  "5ba6b62e-6858-490a-8102-5b1369873835": "Title",
                  "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f": "UDC"
                }
              },
              {
                "name": "callNumberPrefix",
                "enabled": true,
                "path": "holdings.callNumberPrefix",
                "value": "\"PRE5\"",
                "subfields": []
              },
              {
                "name": "callNumber",
                "enabled": true,
                "path": "holdings.callNumber",
                "value": "\"Number2\"",
                "subfields": []
              },
              {
                "name": "callNumberSuffix",
                "enabled": true,
                "path": "holdings.callNumberSuffix",
                "value": "\"SUF5\"",
                "subfields": []
              },
              {
                "name": "numberOfItems",
                "enabled": true,
                "path": "holdings.numberOfItems",
                "subfields": []
              },
              {
                "name": "holdingsStatements",
                "enabled": true,
                "path": "holdings.holdingsStatements[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "holdings.holdingsStatements[]",
                    "fields": [
                      {
                        "name": "statement",
                        "enabled": true,
                        "path": "holdings.holdingsStatements[].statement",
                        "value": "\"holding statement\""
                      },
                      {
                        "name": "note",
                        "enabled": true,
                        "path": "holdings.holdingsStatements[].note",
                        "value": "\"public note\""
                      },
                      {
                        "name": "staffNote",
                        "enabled": true,
                        "path": "holdings.holdingsStatements[].staffNote",
                        "value": "\"staff note\""
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "holdingsStatementsForSupplements",
                "enabled": true,
                "path": "holdings.holdingsStatementsForSupplements[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "holdingsStatementsForIndexes",
                "enabled": true,
                "path": "holdings.holdingsStatementsForIndexes[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "illPolicyId",
                "enabled": true,
                "path": "holdings.illPolicyId",
                "value": "",
                "subfields": [],
                "acceptedValues": {
                  "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy",
                  "37fc2702-7ec9-482a-a4e3-5ed9a122ece1": "Unknown lending policy",
                  "c51f7aa9-9997-45e6-94d6-b502445aae9d": "Unknown reproduction policy",
                  "46970b40-918e-47a4-a45d-b1677a2d3d46": "Will lend",
                  "2b870182-a23d-48e8-917d-9421e5c3ce13": "Will lend hard copy only",
                  "b0f97013-87f5-4bab-87f2-ac4a5191b489": "Will not lend",
                  "6bc6a71f-d6e2-4693-87f1-f495afddff00": "Will not reproduce",
                  "2a572e7b-dfe5-4dee-8a62-b98d26a802e6": "Will reproduce"
                }
              },
              {
                "name": "digitizationPolicy",
                "enabled": true,
                "path": "holdings.digitizationPolicy",
                "value": "",
                "subfields": []
              },
              {
                "name": "retentionPolicy",
                "enabled": true,
                "path": "holdings.retentionPolicy",
                "value": "",
                "subfields": []
              },
              {
                "name": "notes",
                "enabled": true,
                "path": "holdings.notes[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "holdings.notes[]",
                    "fields": [
                      {
                        "name": "noteType",
                        "enabled": true,
                        "path": "holdings.notes[].holdingsNoteTypeId",
                        "acceptedValues": {
                          "d6510242-5ec3-42ed-b593-3585d2e48fd6": "Action note",
                          "e19eabab-a85c-4aef-a7b2-33bd9acef24e": "Binding",
                          "c4407cc7-d79f-4609-95bd-1cefb2e2b5c5": "Copy note",
                          "88914775-f677-4759-b57b-1a33b90b24e0": "Electronic bookplate",
                          "b160f13a-ddba-4053-b9c4-60ec5ea45d56": "Note",
                          "db9b4787-95f0-4e78-becf-26748ce6bdeb": "Provenance",
                          "6a41b714-8574-4084-8d64-a9373c3fbb59": "Reproduction"
                        },
                        "value": "\"Note\""
                      },
                      {
                        "name": "note",
                        "enabled": true,
                        "path": "holdings.notes[].note",
                        "value": "\"Another Holding\""
                      },
                      {
                        "name": "staffOnly",
                        "enabled": true,
                        "path": "holdings.notes[].staffOnly",
                        "value": null,
                        "booleanFieldAction": "ALL_TRUE"
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "electronicAccess",
                "enabled": true,
                "path": "holdings.electronicAccess[]",
                "value": "",
                "subfields": []
              },
              {
                "name": "receivingHistory.entries",
                "enabled": true,
                "path": "holdings.receivingHistory.entries[]",
                "value": "",
                "subfields": []
              }
            ]
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Holdings
    * def folioRecord = 'HOLDINGS'
    * def folioRecordNameAndDescription = 'FAT-943_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileHoldingId = $.id

    # MARC-to-Item (Removes the Item HRID as the copy number and adds it as the item identifier (902$a); Adds volume number from 300$c and removes it from number of pieces. Adds an item note (5). Removes temp loan type. Changes status to missing)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943_New: MARC-to-Item",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "ITEM",
          "description": "",
          "mappingDetails": {
            "name": "item",
            "recordType": "ITEM",
            "mappingFields": [
              {
                "name": "accessionNumber",
                "enabled": true,
                "path": "item.accessionNumber",
                "subfields": [],
                "value": "##REMOVE##"
              },
              {
                "name": "copyNumber",
                "enabled": true,
                "path": "item.copyNumber",
                "value": "902$a",
                "subfields": []
              },
              {
                "name": "numberOfPieces",
                "enabled": true,
                "path": "item.numberOfPieces",
                "value": "300$c",
                "subfields": []
              },
              {
                "name": "descriptionOfPieces",
                "enabled": true,
                "path": "item.descriptionOfPieces",
                "value": "##REMOVE##",
                "subfields": []
              },
              {
                "name": "notes",
                "enabled": true,
                "path": "item.notes[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "item.notes[]",
                    "fields": [
                      {
                        "name": "itemNoteTypeId",
                        "enabled": true,
                        "path": "item.notes[].itemNoteTypeId",
                        "value": "\"Note\"",
                        "acceptedValues": {
                          "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note"
                        }
                      },
                      {
                        "name": "note",
                        "enabled": true,
                        "path": "item.notes[].note",
                        "value": "\"4\""
                      },
                      {
                        "name": "staffOnly",
                        "enabled": true,
                        "path": "item.notes[].staffOnly",
                        "value": null,
                        "booleanFieldAction": "ALL_TRUE"
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "temporaryLoanType.id",
                "enabled": true,
                "path": "item.temporaryLoanType.id",
                "value": "\"Reading room\"",
                "subfields": [],
                "acceptedValues": {
                  "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room"
                }
              }
            ]
          }
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Item
    * def folioRecord = 'ITEM'
    * def folioRecordNameAndDescription = 'FAT-943_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileItemsId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943 MARC-to-MARC 001 to 001",
          "description": "FAT-943 MARC-to-MARC 001 to 001",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "001"
                  },
                  {
                    "label": "indicator1",
                    "value": ""
                  },
                  {
                    "label": "indicator2",
                    "value": ""
                  },
                  {
                    "label": "recordSubfield",
                    "value": ""
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "MARC_BIBLIOGRAPHIC",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "001"
                  },
                  {
                    "label": "indicator1",
                    "value": ""
                  },
                  {
                    "label": "indicator2",
                    "value": ""
                  },
                  {
                    "label": "recordSubfield",
                    "value": ""
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD",
                "qualifier": {
                  "qualifierType": null,
                  "qualifierValue": null
                }
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "MARC_BIBLIOGRAPHIC"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileIdMarcToMarc = $.id

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943 MARC-to-Holdings 901a to Holdings HRID",
          "description": "FAT-943 MARC-to-Holdings 901a to Holdings HRID",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "901"
                  },
                  {
                    "label": "indicator1"
                  },
                  {
                    "label": "indicator2"
                  },
                  {
                    "label": "recordSubfield",
                    "value": "a"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "HOLDINGS",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "holdingsrecord.hrid"
                  }
                ],
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "HOLDINGS"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileIdMarcToHoldings = $.id

    # Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943 MARC-to-Item 902a to Item HRID",
          "description": "FAT-943 MARC-to-Item 902a to Item HRID",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "902"
                  },
                  {
                    "label": "indicator1",
                    "value": ""
                  },
                  {
                    "label": "indicator2",
                    "value": ""
                  },
                  {
                    "label": "recordSubfield",
                    "value": "a"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "ITEM",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "item.hrid"
                  }
                ],
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "ITEM"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileIdMarcToItem = $.id

    # Create job profile - Implement 'Match MARC-to-MARC and update Instances, Holdings, and Items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-943_Implement Match MARC-to-MARC and update Instances, Holdings, and Items",
          "description": "FAT-943_Implement Match MARC-to-MARC and update Instances, Holdings, and Items 5 scenario_INTEGRATION",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileIdMarcToMarc)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(matchProfileIdMarcToMarc)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(actionProfileInstanceId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileIdMarcToHoldings)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 1
          },
          {
            "masterProfileId": "#(matchProfileIdMarcToHoldings)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(actionProfileHoldingId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileIdMarcToItem)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 2
          },
          {
            "masterProfileId": "#(matchProfileIdMarcToItem)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(actionProfileItemsId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    # Preparation: import instance, holding and item basing on FAT-937 scenario which is a precondition for FAT-943 scenario
    * print 'Preparation: import Instance, Holding, Item'
    * def result = call read(importHoldingFeature) { testIdentifier: "FAT-943" }
    * def instanceId = result.instanceId

    # Create job and mapping profiles for data export
    * def exportMappingProfileName = 'FAT-943 Mapping instance, holding, item for export'
    * def dataExportMappingProfile = read('classpath:folijet/data-import/samples/profiles/data-export-mapping-profile.json')
    * def result = call createExportMappingProfile { mappingProfile: "#(dataExportMappingProfile)" }
    * def exportJobProfileName = 'FAT-943 Data export job profile'
    * def result = call createExportJobProfile { jobProfileName: "#(exportJobProfileName)", dataExportMappingProfileId: "#(result.dataExportMappingProfileId)" }
    * def dataExportJobProfileId = result.dataExportJobProfileId

    # Export MARC record by instance id
    * def fileName = 'FAT-943-1.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(dataExportJobProfileId)", fileName: "#(fileName)" }
    * javaWriteData.writeByteArrayToFile(result.exportedBinaryMarcRecord, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-943-1.mrc file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read(commonImportFeature) {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#("file:" + fileName)'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And request
      """
      {
        "uploadDefinition": "#(result.uploadDefinition)",
        "jobProfileInfo": {
          "id": "#(jobProfileId)",
          "name": "FAT-943: Job profile",
          "dataType": "MARC"
        }
      }
      """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
    And def importJobExecutionId = jobExecution.id

    # Verify that needed entities updated
    Given path 'metadata-provider/jobLogEntries', importJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null && karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedItemInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'UPDATED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'UPDATED'
    And assert response.entries[0].relatedHoldingsInfo[0].actionStatus == 'UPDATED'
    And assert response.entries[0].relatedItemInfo[0].actionStatus == 'UPDATED'
    And match response.entries[0].error == ''
