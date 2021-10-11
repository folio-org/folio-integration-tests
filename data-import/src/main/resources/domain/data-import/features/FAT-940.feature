Feature: Data Import integration tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * def randomNumber = callonce random

  Scenario: FAT-940 Match MARC-to-MARC and update Instances, Holdings, and Items 2
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    ## Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
{
  "profile": {
    "name": "FAT-940: MARC-to-Instance",
    "incomingRecordType": "MARC_BIBLIOGRAPHIC",
    "existingRecordType": "INSTANCE",
    "description": "",
    "mappingDetails": {
      "name": "instance",
      "recordType": "INSTANCE",
      "mappingFields": [
        {
          "name": "discoverySuppress",
          "enabled": true,
          "path": "instance.discoverySuppress",
          "value": "",
          "subfields": []
        },
        {
          "name": "staffSuppress",
          "enabled": true,
          "path": "instance.staffSuppress",
          "value": "",
          "subfields": [],
          "booleanFieldAction": "ALL_TRUE"
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
          "value": "\"Circulation\"",
          "subfields": [],
          "acceptedValues": {
            "7cc3837e-c4f1-4584-a3ae-b0c0bfce4bb2" : "Cataloging complete",
            "8cc1fe28-81b1-4460-9131-381ca8010cf4" : "Table of Contents from BNA",
            "52a2ff34-2a12-420d-8539-21aa8d3cf5d8" : "Batch Loaded",
            "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41" : "Not yet assigned",
            "2a340d34-6b70-443a-bb1b-1b8d1c65d862" : "Other",
            "3afd9bfc-2f89-48e4-9287-a5380199ccec" : "Circulation",
            "70fb1135-735f-443c-94b2-19fe47fe8a9d" : "DDA e-title discovery record",
            "d23ef064-17cc-4bd6-b822-a8b1ee293b99" : "Access level records for Internet resources",
            "9634a5ab-9228-4703-baf2-4d12ebc77d56" : "Cataloged",
            "28847832-59b0-4b99-b663-959dabb3d85f" : "Short cataloged",
            "817c1978-7389-47d3-87e0-f13ff3dfa50a" : "Electronic resource temporary",
            "f1bb3a40-ad7c-497a-bd89-4e23c756569d" : "xxx - SYSTEMSONLY",
            "daf2681c-25af-4202-a3fa-e58fdf806183" : "Temporary",
            "2e86f583-e62c-4d4f-879b-959b08893ef0" : "Mono class sep set record",
            "311cfaba-8c3c-40a7-8003-92a54197c10f" : "East Asia recon records",
            "382a51d4-ea50-4f17-bfd8-22a3edebebdb" : "User fast-added",
            "56d4661a-8b09-46f5-8577-cf3b689638ae" : "Batch record load no export permited",
            "742aa6b8-f5dd-4748-9518-de8830c401e1" : "Temporary category",
            "319fefa7-92bd-4d45-9746-4614555955c6" : "OCLC Retrocon records",
            "7141660c-a8c2-4bb0-bf68-1110059275a2" : "Uncataloged",
            "8cb22a5d-a8cc-4440-8896-07fb003fa5ce" : "Electronic resource",
            "69764108-31c0-4fcf-a376-9b2f6cfdf0cf" : "East Asia Cataloging complete",
            "cdf2016b-5a4f-4b42-846d-2f093b7d87c9" : "OCLC Collection Manager",
            "5f1bccf4-4694-4830-8a1c-38e77a833933" : "TALX DLL recon"
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
                  "value": "\"ARL (Collection stats): books - Book, print (books)\"",
                  "acceptedValues": {
                    "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                    "bb76b1c1-c9df-445c-8deb-68bb3580edc2": "ARL (Collection stats): compfiles - Computer files, CDs, etc (compfiles)",
                    "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)",
                    "ecab577d-a050-4ea2-8a86-ea5a234283ea": "ARL (Collection stats): emusic - Music scores, electronic",
                    "97e91f57-fad7-41ea-a660-4031bf8d4ea8": "ARL (Collection stats): maps - Maps, print (maps)",
                    "16f2d65e-eb68-4ab1-93e3-03af50cb7370": "ARL (Collection stats): mfiche - Microfiche (mfiche)",
                    "1c622d0f-2e91-4c30-ba43-2750f9735f51": "ARL (Collection stats): mfilm - Microfilm (mfilm)",
                    "2850630b-cd12-4379-af57-5c51491a6873": "ARL (Collection stats): mmedia - Mixed media (mmedia)",
                    "30b5400d-0b9e-4757-a3d0-db0d30a49e72": "ARL (Collection stats): music - Music scores, print (music)",
                    "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings",
                    "91b8f0b4-0e13-4270-9fd6-e39203d0f449": "ARL (Collection stats): rnonmusic - Non-music sound recordings (rnonmusic)",
                    "775b6ad4-9c35-4d29-bf78-8775a9b42226": "ARL (Collection stats): serials - Serials, print (serials)",
                    "972f81d5-9f8f-4b56-a10e-5c05419718e6": "ARL (Collection stats): visual - Visual materials, DVDs, etc. (visual)",
                    "e10796e0-a594-47b7-b748-3a81b69b3d9b": "DISC (Discovery): audstream - Streaming audio (audstream)",
                    "b76a3088-8de6-46c8-a130-c8e74b8d2c5b": "DISC (Discovery): emaps - Maps, electronic (emaps)",
                    "a5ccf92e-7b1f-4990-ac03-780a6a767f37": "DISC (Discovery): eserials - Serials, electronic (eserials)",
                    "b2c0e100-0485-43f2-b161-3c60aac9f68a": "DISC (Discovery): evisual - Visual, static, electronic",
                    "6d584d0e-3dbc-46c4-a1bd-e9238dd9a6be": "DISC (Discovery): vidstream - Streaming video (vidstream)",
                    "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                    "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                    "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)",
                    "38249f9e-13f8-48bc-a010-8023cd194af5": "RECM (Record management): its - Information Technology Services (its)",
                    "d82c025e-436d-4006-a677-bd2b4cdb7692": "RECM (Record management): mss - Manuscripts (mss)",
                    "950d3370-9a3c-421e-b116-76e7511af9e9": "RECM (Record management): polsky - Polsky TECHB@R (polsky)",
                    "c4073462-6144-4b69-a543-dd131e241799": "RECM (Record management): withdrawn - Withdrawn (withdrawn)",
                    "c7a32c50-ea7c-43b7-87ab-d134c8371330": "SERM (Serial management): ASER - Active serial",
                    "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                    "0e516e54-bf36-4fc2-a0f7-3fe89a61c9c0": "SERM (Serial management): ISER - Inactive serial"
                  }
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

    * def marcToInstanceMappingProfileId = $.id

    ## Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
{
  "id": "484e9624-6308-4ff6-98e4-6609ba185782",
  "profile": {
    "id": "484e9624-6308-4ff6-98e4-6609ba185782",
    "name": "FAT-940: MARC-to-Holdings",
    "description": "",
    "incomingRecordType": "MARC_BIBLIOGRAPHIC",
    "existingRecordType": "HOLDINGS",
    "deleted": false,
    "marcFieldProtectionSettings": [],
    "parentProfiles": [],
    "childProfiles": [],
    "mappingDetails": {
      "name": "holdings",
      "recordType": "HOLDINGS",
      "mappingFields": [
        {
          "name": "discoverySuppress",
          "enabled": "true",
          "path": "holdings.discoverySuppress",
          "value": "",
          "subfields": []
        },
        {
          "name": "hrid",
          "enabled": "false",
          "path": "holdings.discoverySuppress",
          "value": "",
          "subfields": []
        },
        {
          "name": "formerIds",
          "enabled": "true",
          "path": "holdings.formerIds[]",
          "value": "",
          "repeatableFieldAction": "EXCHANGE_EXISTING",
          "subfields": [
            {
              "order": 0,
              "path": "holdings.formerIds[]",
              "fields": [
                {
                  "name": "formerId",
                  "enabled": "true",
                  "path": "holdings.formerIds[]",
                  "value": "\"Holdings ID 2\"",
                  "subfields": []
                }
              ]
            }
          ]
        },
        {
          "name": "holdingsTypeId",
          "enabled": "true",
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
          "enabled": "true",
          "path": "holdings.statisticalCodeIds[]",
          "value": "",
          "subfields": [
            {
              "order": 0,
              "path": "holdings.statisticalCodeIds[]",
              "fields": [
                {
                  "name": "statisticalCodeId",
                  "enabled": true,
                  "path": "holdings.statisticalCodeIds[]",
                  "value": "\"ARL (Collection stats): books - Book, print (books)\"",
                  "acceptedValues": {
                    "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                    "bb76b1c1-c9df-445c-8deb-68bb3580edc2": "ARL (Collection stats): compfiles - Computer files, CDs, etc (compfiles)",
                    "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)",
                    "ecab577d-a050-4ea2-8a86-ea5a234283ea": "ARL (Collection stats): emusic - Music scores, electronic",
                    "97e91f57-fad7-41ea-a660-4031bf8d4ea8": "ARL (Collection stats): maps - Maps, print (maps)",
                    "16f2d65e-eb68-4ab1-93e3-03af50cb7370": "ARL (Collection stats): mfiche - Microfiche (mfiche)",
                    "1c622d0f-2e91-4c30-ba43-2750f9735f51": "ARL (Collection stats): mfilm - Microfilm (mfilm)",
                    "2850630b-cd12-4379-af57-5c51491a6873": "ARL (Collection stats): mmedia - Mixed media (mmedia)",
                    "30b5400d-0b9e-4757-a3d0-db0d30a49e72": "ARL (Collection stats): music - Music scores, print (music)",
                    "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings",
                    "91b8f0b4-0e13-4270-9fd6-e39203d0f449": "ARL (Collection stats): rnonmusic - Non-music sound recordings (rnonmusic)",
                    "775b6ad4-9c35-4d29-bf78-8775a9b42226": "ARL (Collection stats): serials - Serials, print (serials)",
                    "972f81d5-9f8f-4b56-a10e-5c05419718e6": "ARL (Collection stats): visual - Visual materials, DVDs, etc. (visual)",
                    "e10796e0-a594-47b7-b748-3a81b69b3d9b": "DISC (Discovery): audstream - Streaming audio (audstream)",
                    "b76a3088-8de6-46c8-a130-c8e74b8d2c5b": "DISC (Discovery): emaps - Maps, electronic (emaps)",
                    "a5ccf92e-7b1f-4990-ac03-780a6a767f37": "DISC (Discovery): eserials - Serials, electronic (eserials)",
                    "b2c0e100-0485-43f2-b161-3c60aac9f68a": "DISC (Discovery): evisual - Visual, static, electronic",
                    "6d584d0e-3dbc-46c4-a1bd-e9238dd9a6be": "DISC (Discovery): vidstream - Streaming video (vidstream)",
                    "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                    "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                    "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)",
                    "38249f9e-13f8-48bc-a010-8023cd194af5": "RECM (Record management): its - Information Technology Services (its)",
                    "d82c025e-436d-4006-a677-bd2b4cdb7692": "RECM (Record management): mss - Manuscripts (mss)",
                    "950d3370-9a3c-421e-b116-76e7511af9e9": "RECM (Record management): polsky - Polsky TECHB@R (polsky)",
                    "c4073462-6144-4b69-a543-dd131e241799": "RECM (Record management): withdrawn - Withdrawn (withdrawn)",
                    "c7a32c50-ea7c-43b7-87ab-d134c8371330": "SERM (Serial management): ASER - Active serial",
                    "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                    "0e516e54-bf36-4fc2-a0f7-3fe89a61c9c0": "SERM (Serial management): ISER - Inactive serial"
                  }
                }
              ]
            }
          ],
          "repeatableFieldAction": "EXTEND_EXISTING"
        },
        {
          "name": "permanentLocationId",
          "enabled": "true",
          "path": "holdings.permanentLocationId",
          "value": "\"Main Library (KU/CC/DI/M)\"",
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
          "enabled": "true",
          "path": "holdings.temporaryLocationId",
          "value": "",
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
          "enabled": "true",
          "path": "holdings.shelvingOrder",
          "value": "",
          "subfields": []
        },
        {
          "name": "shelvingTitle",
          "enabled": "true",
          "path": "holdings.shelvingTitle",
          "value": "\"TEST2\"",
          "subfields": []
        },
        {
          "name": "copyNumber",
          "enabled": "true",
          "path": "holdings.copyNumber",
          "value": "",
          "subfields": []
        },
        {
          "name": "callNumberTypeId",
          "enabled": "true",
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
          "enabled": "true",
          "path": "holdings.callNumberPrefix",
          "value": "\"PREF2\"",
          "subfields": []
        },
        {
          "name": "callNumber",
          "enabled": "true",
          "path": "holdings.callNumber",
          "value": "",
          "subfields": []
        },
        {
          "name": "callNumberSuffix",
          "enabled": "true",
          "path": "holdings.callNumberSuffix",
          "value": "\"SUF2\"",
          "subfields": []
        },
        {
          "name": "numberOfItems",
          "enabled": "true",
          "path": "holdings.numberOfItems",
          "value": "",
          "subfields": []
        },
        {
          "name": "holdingsStatements",
          "enabled": "true",
          "path": "holdings.holdingsStatements[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "holdingsStatementsForSupplements",
          "enabled": "true",
          "path": "holdings.holdingsStatementsForSupplements[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "holdingsStatementsForIndexes",
          "enabled": "true",
          "path": "holdings.holdingsStatementsForIndexes[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "illPolicyId",
          "enabled": "true",
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
          "enabled": "true",
          "path": "holdings.digitizationPolicy",
          "value": "",
          "subfields": []
        },
        {
          "name": "retentionPolicy",
          "enabled": "true",
          "path": "holdings.retentionPolicy",
          "value": "\"300$a\"",
          "subfields": []
        },
        {
          "name": "notes",
          "enabled": "true",
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
                  "value": "\"Action note\"",
                  "acceptedValues": {
                    "d6510242-5ec3-42ed-b593-3585d2e48fd6": "Action note",
                    "e19eabab-a85c-4aef-a7b2-33bd9acef24e": "Binding",
                    "c4407cc7-d79f-4609-95bd-1cefb2e2b5c5": "Copy note",
                    "88914775-f677-4759-b57b-1a33b90b24e0": "Electronic bookplate",
                    "b160f13a-ddba-4053-b9c4-60ec5ea45d56": "Note",
                    "db9b4787-95f0-4e78-becf-26748ce6bdeb": "Provenance",
                    "6a41b714-8574-4084-8d64-a9373c3fbb59": "Reproduction"
                  }
                },
                {
                  "name": "note",
                  "enabled": true,
                  "path": "holdings.notes[].note",
                  "value": "\"test\""
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
          "enabled": "true",
          "path": "holdings.electronicAccess[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "receivingHistory.entries",
          "enabled": "true",
          "path": "holdings.receivingHistory.entries[]",
          "value": "",
          "subfields": []
        }
      ],
      "marcMappingDetails": []
    }
  },
  "addedRelations": [],
  "deletedRelations": []
}
    """
    When method POST
    Then status 201

    * def marcToHoldingsMappingProfileId = $.id

    ## Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
{
  "profile": {
    "name": "FAT-940: MARC-to-Item",
    "incomingRecordType": "MARC_BIBLIOGRAPHIC",
    "existingRecordType": "ITEM",
    "description": "",
    "mappingDetails": {
      "name": "item",
      "recordType": "ITEM",
      "mappingFields": [
        {
          "name": "discoverySuppress",
          "enabled": true,
          "path": "item.discoverySuppress",
          "value": null,
          "subfields": []
        },
        {
          "name": "hrid",
          "enabled": true,
          "path": "item.hrid",
          "value": "",
          "subfields": []
        },
        {
          "name": "barcode",
          "enabled": true,
          "path": "item.barcode",
          "value": "",
          "subfields": []
        },
        {
          "name": "accessionNumber",
          "enabled": true,
          "path": "item.accessionNumber",
          "value": "",
          "subfields": []
        },
        {
          "name": "itemIdentifier",
          "enabled": true,
          "path": "item.itemIdentifier",
          "value": "902$a",
          "subfields": []
        },
        {
          "name": "formerIds",
          "enabled": true,
          "path": "item.formerIds[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "statisticalCodeIds",
          "enabled": true,
          "path": "item.statisticalCodeIds[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "materialType.id",
          "enabled": true,
          "path": "item.materialType.id",
          "value": "",
          "subfields": [],
          "acceptedValues": {
            "1a54b431-2e4f-452d-9cae-9cee66c9a892": "book",
            "5ee11d91-f7e8-481d-b079-65d708582ccc": "dvd",
            "615b8413-82d5-4203-aa6e-e37984cb5ac3": "electronic resource",
            "fd6c6515-d470-4561-9c32-3e3290d4ca98": "microform",
            "dd0bf600-dbd9-44ab-9ff2-e2a61a6539f1": "sound recording",
            "d9acad2f-2aac-4b48-9097-e6ab85906b25": "text",
            "71fbd940-1027-40a6-8a48-49b44d795e46": "unspecified",
            "30b3e36a-d3b2-415e-98c2-47fbdf878862": "video recording"
          }
        },
        {
          "name": "copyNumber",
          "enabled": true,
          "path": "item.copyNumber",
          "value": "###REMOVE###",
          "subfields": []
        },
        {
          "name": "itemLevelCallNumberTypeId",
          "enabled": true,
          "path": "item.itemLevelCallNumberTypeId",
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
          "name": "itemLevelCallNumberPrefix",
          "enabled": true,
          "path": "item.itemLevelCallNumberPrefix",
          "value": "",
          "subfields": []
        },
        {
          "name": "itemLevelCallNumber",
          "enabled": true,
          "path": "item.itemLevelCallNumber",
          "value": "",
          "subfields": []
        },
        {
          "name": "itemLevelCallNumberSuffix",
          "enabled": true,
          "path": "item.itemLevelCallNumberSuffix",
          "value": "",
          "subfields": []
        },
        {
          "name": "numberOfPieces",
          "enabled": true,
          "path": "item.numberOfPieces",
          "value": "",
          "subfields": []
        },
        {
          "name": "descriptionOfPieces",
          "enabled": true,
          "path": "item.descriptionOfPieces",
          "value": "",
          "subfields": []
        },
        {
          "name": "enumeration",
          "enabled": true,
          "path": "item.enumeration",
          "value": "",
          "subfields": []
        },
        {
          "name": "chronology",
          "enabled": true,
          "path": "item.chronology",
          "value": "",
          "subfields": []
        },
        {
          "name": "volume",
          "enabled": true,
          "path": "item.volume",
          "value": "",
          "subfields": []
        },
        {
          "name": "yearCaption",
          "enabled": true,
          "path": "item.yearCaption[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "numberOfMissingPieces",
          "enabled": true,
          "path": "item.numberOfMissingPieces",
          "value": "",
          "subfields": []
        },
        {
          "name": "missingPieces",
          "enabled": true,
          "path": "item.missingPieces",
          "value": "",
          "subfields": []
        },
        {
          "name": "missingPiecesDate",
          "enabled": true,
          "path": "item.missingPiecesDate",
          "value": "",
          "subfields": []
        },
        {
          "name": "itemDamagedStatusId",
          "enabled": true,
          "path": "item.itemDamagedStatusId",
          "value": "",
          "subfields": [],
          "acceptedValues": {
            "54d1dd76-ea33-4bcb-955b-6b29df4f7930": "Damaged",
            "516b82eb-1f19-4a63-8c48-8f1a3e9ff311": "Not Damaged"
          }
        },
        {
          "name": "itemDamagedStatusDate",
          "enabled": true,
          "path": "item.itemDamagedStatusDate",
          "value": "",
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
                  "value": "\"Action note\"",
                  "acceptedValues": {
                    "0e40884c-3523-4c6d-8187-d578e3d2794e": "Action note",
                    "87c450be-2033-41fb-80ba-dd2409883681": "Binding",
                    "1dde7141-ec8a-4dae-9825-49ce14c728e7": "Copy note",
                    "f3ae3823-d096-4c65-8734-0c1efd2ffea8": "Electronic bookplate",
                    "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note",
                    "c3a539b9-9576-4e3a-b6de-d910200b2919": "Provenance",
                    "acb3a58f-1d72-461d-97c3-0e7119e8d544": "Reproduction"
                  }
                },
                {
                  "name": "note",
                  "enabled": true,
                  "path": "item.notes[].note",
                  "value": "\"some note\""
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
          "name": "permanentLoanType.id",
          "enabled": true,
          "path": "item.permanentLoanType.id",
          "value": "",
          "subfields": [],
          "acceptedValues": {
            "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
            "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
            "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
            "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
          }
        },
        {
          "name": "temporaryLoanType.id",
          "enabled": true,
          "path": "item.temporaryLoanType.id",
          "value": "###REMOVE###",
          "subfields": [],
          "acceptedValues": {
            "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
            "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
            "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
            "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
          }
        },
        {
          "name": "status.name",
          "enabled": true,
          "path": "item.status.name",
          "value": "",
          "subfields": []
        },
        {
          "name": "circulationNotes",
          "enabled": true,
          "path": "item.circulationNotes[]",
          "value": "",
          "subfields": []
        },
        {
          "name": "permanentLocation.id",
          "enabled": true,
          "path": "item.permanentLocation.id",
          "value": "",
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
          "name": "temporaryLocation.id",
          "enabled": true,
          "path": "item.temporaryLocation.id",
          "value": "",
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
          "name": "electronicAccess",
          "enabled": true,
          "path": "item.electronicAccess[]",
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

    * def marcToItemMappingProfileId = $.id

    ## Create action profile for update Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: Update Instance",
    "description": "",
    "action": "UPDATE",
    "folioRecord": "INSTANCE"
  },
  "addedRelations": [
    {
      "masterProfileId": null,
      "masterProfileType": "ACTION_PROFILE",
      "detailProfileId": "#(marcToInstanceMappingProfileId)",
      "detailProfileType": "MAPPING_PROFILE"
    }
  ],
  "deletedRelations": []
}
"""
    When method POST
    Then status 201

    * def instanceActionProfileId = $.id

    ## Create action profile for update Holdings
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: Update Holdings",
    "description": "",
    "action": "UPDATE",
    "folioRecord": "HOLDINGS"
  },
  "addedRelations": [
    {
      "masterProfileId": null,
      "masterProfileType": "ACTION_PROFILE",
      "detailProfileId": "#(marcToHoldingsMappingProfileId)",
      "detailProfileType": "MAPPING_PROFILE"
    }
  ],
  "deletedRelations": []
}
"""
    When method POST
    Then status 201

    * def holdingsActionProfileId = $.id

    ## Create action profile for update Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: Update item",
    "description": "",
    "action": "UPDATE",
    "folioRecord": "ITEM"
  },
  "addedRelations": [
    {
      "masterProfileId": null,
      "masterProfileType": "ACTION_PROFILE",
      "detailProfileId": "#(marcToItemMappingProfileId)",
      "detailProfileType": "MAPPING_PROFILE"
    }
  ],
  "deletedRelations": []
}
"""
    When method POST
    Then status 201

    * def itemActionProfileId = $.id

## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: MARC-to-MARC 001 to 001",
    "description": "",
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
          "dataValueType": "VALUE_FROM_RECORD"
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

    * def marcToMarcMatchProfileId = $.id

    ## Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: MARC-to-Holdings 901a to Holdings HRID",
    "description": "",
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

    * def marcToHoldingsMatchProfileId = $.id

    ## Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: MARC-to-Item 902a to Item HRID",
    "description": "",
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

    * def marcToItemMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
"""
{
  "profile": {
    "name": "FAT-940: Job profile",
    "description": "",
    "dataType": "MARC"
  },
  "addedRelations": [
    {
      "masterProfileId": null,
      "masterProfileType": "JOB_PROFILE",
      "detailProfileId": "#(marcToMarcMatchProfileId)",
      "detailProfileType": "MATCH_PROFILE",
      "order": 0
    },
    {
      "masterProfileId": "#(marcToMarcMatchProfileId)",
      "masterProfileType": "MATCH_PROFILE",
      "detailProfileId": "#(instanceActionProfileId)",
      "detailProfileType": "ACTION_PROFILE",
      "order": 0,
      "reactTo": "MATCH"
    },
    {
      "masterProfileId": null,
      "masterProfileType": "JOB_PROFILE",
      "detailProfileId": "#(marcToHoldingsMatchProfileId)",
      "detailProfileType": "MATCH_PROFILE",
      "order": 1
    },
    {
      "masterProfileId": "#(marcToHoldingsMatchProfileId)",
      "masterProfileType": "MATCH_PROFILE",
      "detailProfileId": "#(holdingsActionProfileId)",
      "detailProfileType": "ACTION_PROFILE",
      "order": 0,
      "reactTo": "MATCH"
    },
    {
      "masterProfileId": null,
      "masterProfileType": "JOB_PROFILE",
      "detailProfileId": "#(marcToItemMatchProfileId)",
      "detailProfileType": "MATCH_PROFILE",
      "order": 2
    },
    {
      "masterProfileId": "#(marcToItemMatchProfileId)",
      "masterProfileType": "MATCH_PROFILE",
      "detailProfileId": "#(itemActionProfileId)",
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

    ## Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
  """
  {
     "size": 2,
     "fileName": "FAT-940.csv",
     "uploadFormat": "csv"
  }
  """
    When method POST
    Then status 201
    And match $.status == 'NEW'

    * def fileDefinitionId = $.id

    ## Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:domain/data-import/samples/csv-files/FAT-940.csv')
    When method POST
    Then status 200
    And match $.status == 'COMPLETED'

    * def exportJobExecutionId = $.jobExecutionId
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

    ## Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    ## Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    ##should export instances and return 204
    Given path 'data-export/export'
    And headers headersUser
    And request
"""
{
"fileDefinitionId": "#(fileDefinitionId)",
"jobProfileId": "#(defaultJobProfileId)"
}
"""
    When method POST
    Then status 204

    ## Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 1000

    ## Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200

    * def downloadLink = $.link

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200