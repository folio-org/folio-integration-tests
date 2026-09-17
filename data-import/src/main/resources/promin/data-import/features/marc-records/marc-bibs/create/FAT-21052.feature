Feature: FAT-21052 - Import to create open orders: Physical resource with Instances, Holdings

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')
    * configure retry = { interval: 5000, count: 30 }

    * def gobiVendorId = 'c6dace5d-4574-411e-8ba1-036102fcdc9b'
    * def locationName = 'Main Library (KU/CC/DI/M)'
    * def acquisitionMethodName = 'Purchase'

  @C380475
  Scenario: FAT-21052 Test physical resource open order with instance, holdings
    # Create mapping profile for order creation.
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def orderMappingProfileName = 'FAT-21052 Test Physical resource open order with instance, holdings ' + epoch
    And request
      """
      {
        "profile": {
          "name": "#(orderMappingProfileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "ORDER",
          "description": "",
          "mappingDetails": {
            "name": "order",
            "recordType": "ORDER",
            "mappingFields": [
              {
                "name": "workflowStatus",
                "enabled": "true",
                "path": "order.po.workflowStatus",
                "value": "\"Open\"",
                "subfields": []
              },
              {
                "name": "approved",
                "enabled": "true",
                "path": "order.po.approved",
                "booleanFieldAction": "ALL_TRUE",
                "subfields": []
              },
              {
                "name": "vendor",
                "enabled": "true",
                "path": "order.po.vendor",
                "value": "#('\"' + gobiVendorId + '\"')",
                "subfields": []
              },
              {
                "name": "title",
                "enabled": "true",
                "path": "order.poLine.titleOrPackage",
                "value": "245$a",
                "subfields": []
              },
              {
                "name": "acquisitionMethod",
                "enabled": "true",
                "path": "order.poLine.acquisitionMethod",
                "value": "#('\"' + acquisitionMethodName + '\"')",
                "subfields": []
              },
              {
                "name": "orderFormat",
                "enabled": "true",
                "path": "order.poLine.orderFormat",
                "value": "\"Physical Resource\"",
                "subfields": []
              },
              {
                "name": "checkinItems",
                "enabled": "true",
                "path": "order.poLine.checkinItems",
                "booleanFieldAction": "ALL_FALSE",
                "subfields": []
              },
              {
                "name": "listUnitPrice",
                "enabled": "true",
                "path": "order.poLine.cost.listUnitPrice",
                "value": "\"20\"",
                "subfields": []
              },
              {
                "name": "quantityPhysical",
                "enabled": "true",
                "path": "order.poLine.cost.quantityPhysical",
                "value": "\"1\"",
                "subfields": []
              },
              {
                "name": "currency",
                "enabled": "true",
                "path": "order.poLine.cost.currency",
                "value": "\"USD\"",
                "subfields": []
              },
              {
                "name": "electronicUnitPrice",
                "enabled": "true",
                "path": "order.poLine.cost.listUnitPriceElectronic",
                "subfields": []
              },
              {
                "name": "quantityElectronic",
                "enabled": "true",
                "path": "order.poLine.cost.quantityElectronic",
                "subfields": []
              },
              {
                "name": "createInventory",
                "enabled": "true",
                "path": "order.poLine.physical.createInventory",
                "subfields": []
              },
              {
                "name": "materialType",
                "enabled": "true",
                "path": "order.poLine.physical.materialType",
                "subfields": []
              },
              {
                "name": "createInventory",
                "enabled": "true",
                "path": "order.poLine.eresource.createInventory",
                "subfields": []
              },
              {
                "name": "materialType",
                "enabled": "true",
                "path": "order.poLine.eresource.materialType",
                "subfields": []
              },
              {
                "name": "locations",
                "enabled": "true",
                "path": "order.poLine.locations[]",
                "value": "",
                "repeatableFieldAction": "EXTEND_EXISTING",
                "subfields": [
                  {
                    "order": 0,
                    "path": "order.poLine.locations[]",
                    "fields": [
                      {
                        "name": "locationId",
                        "enabled": "true",
                        "path": "order.poLine.locations[].locationId",
                        "value": "#('\"' + locationName + '\"')"
                      },
                      {
                        "name": "quantityPhysical",
                        "enabled": "true",
                        "path": "order.poLine.locations[].quantityPhysical",
                        "value": "\"1\""
                      },
                      {
                        "name": "quantityElectronic",
                        "enabled": "true",
                        "path": "order.poLine.locations[].quantityElectronic",
                        "value": ""
                      }
                    ]
                  }
                ]
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
    * def orderMappingProfileId = $.id

    # Create mapping profile for holdings record creation.
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def holdingsMappingProfileName = 'FAT-21052 Create simple holdings for open order ' + epoch
    And request
      """
      {
        "profile": {
          "name": "#(holdingsMappingProfileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "permanentLocationId",
                "enabled": "true",
                "path": "holdings.permanentLocationId",
                "value": "#('\"' + locationName + '\"')",
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
    * def holdingsMappingProfileId = $.id

    # Create action profile for order creation.
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def folioRecordNameAndDescription = 'FAT-21052 Test Physical resource open order with instance, holdings'
    And def profileAction = 'CREATE'
    And def folioRecord = 'ORDER'
    And def mappingProfileEntityId = orderMappingProfileId
    And request read('classpath:promin/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def orderActionProfileId = $.id

    # Create action profile for holdings record creation.
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def folioRecordNameAndDescription = 'FAT-21052 Create simple holdings for open order'
    And def profileAction = 'CREATE'
    And def folioRecord = 'HOLDINGS'
    And def mappingProfileEntityId = holdingsMappingProfileId
    And request read('classpath:promin/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create job profile and attach action profiles in sequence:
    #   1) order action profile
    #   2) Default - create instance action profile (referenced via
    #      defaultCreateInstanceActionProfileId declared in common-functions.feature)
    #   3) holdings action profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'FAT-21052 Test Physical resource open order with instance, holdings ' + epoch
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(orderActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(defaultCreateInstanceActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(holdingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 2
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    # Import the prepared file using the job profile created above.
    * def res = call read(utilFeature+'@ImportRecord') { fileName: 'FAT-21052-TestOpenOrderAndInventory', jobName: 'customJob' }
    * match res.jobExecution.status == 'COMMITTED'

    # Check via job log entries that order, po line, instance and holding were created.
    Given path 'metadata-provider/jobLogEntries', res.jobExecutionId
    And headers headersUser
    And param limit = 1
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null && karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedPoLineInfo.actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And match response.entries[0].relatedHoldingsInfo[0].actionStatus == 'CREATED'
    And match response.entries[0].relatedPoLineInfo.actionStatus == 'CREATED'
    * def instanceId = response.entries[0].relatedInstanceInfo.idList[0]
    * def holdingsId = response.entries[0].relatedHoldingsInfo[0].id
    * def poLineId = response.entries[0].relatedPoLineInfo.idList[0]
    * def orderId = response.entries[0].relatedPoLineInfo.orderId

    # Fetch and verify order line
    Given path 'orders/order-lines', poLineId
    And headers headersUser
    When method GET
    Then status 200
    And match response.purchaseOrderId == orderId
    And match response.instanceId == instanceId
    And match response.orderFormat == "Physical Resource"
    And match response.physical.createInventory == 'Instance, Holding'

    # Fetch holdings record and verify instanceId.
    Given path 'holdings-storage/holdings', holdingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.instanceId == instanceId
