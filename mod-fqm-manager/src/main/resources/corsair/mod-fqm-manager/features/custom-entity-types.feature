Feature: Entity types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def customEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bb1'

  Scenario: Custom entity type CRUD
    * def customEntityType =
      """
        {
          "id": "#(customEntityTypeId)",
          "name": "custom_composite_user_details",
          "description": "test custom entity type! Yay!",
          "crossTenantQueriesEnabled": false,
          "defaultSort": [
            {
              "columnName": "\"users.user\".id",
              "direction": "ASC"
            }
          ],
          "sources": [
            {
              "type": "entity-type",
              "alias": "users",
              "name": "Users",
              "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2",
              "useIdColumns": true,
              "inheritCustomFields": true
            },
            {
              "type": "entity-type",
              "alias": "groups",
              "name": "Groups",
              "sourceField": "users.group_id",
              "targetId": "e7717b38-4ff3-4fb9-ae09-b3d0c8400710",
              "targetField": "id",
              "essentialOnly": true,
              "inheritCustomFields": true
            }
          ],
          "shared": true,
          "isCustom": true,
          "private": false
        }
      """
    # Create the custom entity  type
    Given path 'entity-types/custom'
    And request customEntityType
    When method POST
    Then status 201
    And match $.id == '#(customEntityTypeId)'
    And match $.name == 'custom_composite_user_details'
    And match $.owner == '#present'
    And match $.createdAt == '#present'
    And match $.updatedAt == '#present'

    # Retrieve the custom entity type and make sure it matches the created one
    Given path 'entity-types/custom', customEntityTypeId
    When method GET
    Then status 200
    And match $.id == '#(customEntityTypeId)'
    And match $.name == 'custom_composite_user_details'
    And match $.owner == '#present'
    And match $.createdAt == '#present'
    And match $.updatedAt == $.createdAt

    # Update the custom entity type
    * copy updatedCustomEntityType = customEntityType
    * set updatedCustomEntityType.description = 'Updated description for custom entity type'
    Given path 'entity-types/custom', customEntityTypeId
    And request updatedCustomEntityType
    When method PUT
    Then status 200

    # Retrieve the updated custom entity type and verify the changes were applied
    Given path 'entity-types/custom', customEntityTypeId
    When method GET
    Then status 200
    And match $.id == '#(customEntityTypeId)'
    And match $.description == 'Updated description for custom entity type'
    And match $.createdAt == '#present'
    And match $.updatedAt != $.createdAt

    # Delete the custom entity type
    Given path 'entity-types/custom', customEntityTypeId
    When method DELETE
    Then status 204

    # Verify the custom entity type has been deleted
    Given path 'entity-types/custom', customEntityTypeId
    When method GET
    Then status 200
    And match $.deleted == true

  Scenario: Create custom entity type and execute a query using it
    * def queryEntityTypeId = 'a1b2c3d4-e5f6-7890-abcd-ef0123456789'
    * def customEntityTypeForQuery =
      """
        {
          "id": "#(queryEntityTypeId)",
          "name": "custom_query_user_details",
          "description": "Entity type for query test",
          "crossTenantQueriesEnabled": false,
          "defaultSort": [
            {
              "columnName": "\"users.user\".id",
              "direction": "ASC"
            }
          ],
          "sources": [
            {
              "type": "entity-type",
              "alias": "users",
              "name": "Users",
              "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2",
              "useIdColumns": true,
              "inheritCustomFields": true
            },
            {
              "type": "entity-type",
              "alias": "groups",
              "name": "Groups",
              "sourceField": "users.group_id",
              "targetId": "e7717b38-4ff3-4fb9-ae09-b3d0c8400710",
              "targetField": "id",
              "essentialOnly": true,
              "inheritCustomFields": true
            }
          ],
          "shared": true,
          "isCustom": true,
          "private": false
        }
      """
    # Create the custom entity type for query
    Given path 'entity-types/custom'
    And request customEntityTypeForQuery
    When method POST
    Then status 201
    And match $.id == '#(queryEntityTypeId)'

    # Execute a query using the new custom entity type, querying fields from both sources
    * def fqlQuery = "{ \"$and\": [ { \"users.username\": { \"$eq\": \"integration_test_user_123\" } }, { \"groups.group\": { \"$eq\": \"test_group\" } } ] }"
    Given path 'query'
    And request { entityTypeId: '#(queryEntityTypeId)', fqlQuery: '#(fqlQuery)' }
    When method POST
    Then status 201
    And match $.queryId == '#present'
    * def queryId = $.queryId

    # Get query results with query id
    Given path 'query', queryId
    When method GET
    Then status 200
    And match $.queryId == queryId

    # Clean up: delete the custom entity type
    Given path 'entity-types/custom', queryEntityTypeId
    When method DELETE
    Then status 204



  # Validation: Creation - shared must be non-null
  Scenario: Custom entity type creation fails when shared is null
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_shared_null",
        "description": "shared is null",
        "shared": null,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: Update - owner must be non-null and valid UUID
  Scenario: Custom entity type update fails when owner is null
    * def etId = uuid()
    * def validEntityType =
      """
      {
        "id": "#(etId)",
        "name": "update_owner_null",
        "description": "owner null test",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request validEntityType
    When method POST
    Then status 201

    * copy invalidUpdate = validEntityType
    * set invalidUpdate.owner = null
    Given path 'entity-types/custom', 'update-owner-null'
    And request invalidUpdate
    When method PUT
    Then status 400

  Scenario: Custom entity type update fails when owner is not a valid UUID
    * def etId = uuid()
    * def validEntityType =
      """
      {
        "id": "#(etId)",
        "name": "update_owner_invalid_uuid",
        "description": "owner invalid uuid test",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request validEntityType
    When method POST
    Then status 201

    * copy invalidUpdate = validEntityType
    * set invalidUpdate.owner = "not-a-uuid"
    Given path 'entity-types/custom', 'update-owner-invalid-uuid'
    And request invalidUpdate
    When method PUT
    Then status 400

  # Validation: isCustom must be non-null and true
  Scenario: Custom entity type creation fails when isCustom is null or false
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_isCustom",
        "description": "isCustom is null",
        "shared": true,
        "isCustom": null,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 404

    * set invalidEntityType.isCustom = false
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 404

  # Validation: sources must be entity-type (targetId present, target absent)
  # Reasoning: "targetId" is for entity-type sources, "target" is for database sources. Custom entity types must use entity-type sources.
  Scenario: Custom entity type creation fails when sources object has target but not targetId
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_source_target",
        "description": "sources has target instead of targetId",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "target": "users_table"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  Scenario: Custom entity type creation fails when sources object missing targetId
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_source_missing_targetId",
        "description": "sources missing targetId",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: columns must be null or empty array
  Scenario: Custom entity type creation fails when columns is not null or empty array
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_columns",
        "description": "columns is not null or empty array",
        "shared": true,
        "isCustom": true,
        "private": true,
        "columns": ["bad_column"],
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: customFieldEntityTypeId must be null
  Scenario: Custom entity type creation fails when customFieldEntityTypeId is not null
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_customFieldEntityTypeId",
        "description": "customFieldEntityTypeId is not null",
        "shared": true,
        "isCustom": true,
        "private": true,
        "customFieldEntityTypeId": "some-id",
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: sourceView must be null
  Scenario: Custom entity type creation fails when sourceView is not null
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_sourceView",
        "description": "sourceView is not null",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sourceView": "some_view",
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: sourceViewExtractor must be null
  Scenario: Custom entity type creation fails when sourceViewExtractor is not null
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_sourceViewExtractor",
        "description": "sourceViewExtractor is not null",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sourceViewExtractor": "extractor",
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: crossTenantQueriesEnabled must be null or false
  Scenario: Custom entity type creation fails when crossTenantQueriesEnabled is true
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_crossTenantQueriesEnabled",
        "description": "crossTenantQueriesEnabled is true",
        "shared": true,
        "isCustom": true,
        "private": true,
        "crossTenantQueriesEnabled": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: private must be non-null
  Scenario: Custom entity type creation fails when private is null
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_private_null",
        "description": "private is null",
        "shared": true,
        "isCustom": true,
        "private": null,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: id must be non-null, and match URL on update
  Scenario: Custom entity type creation fails when id is null
    * def invalidEntityType =
      """
      {
        "id": null,
        "name": "invalid_id_null",
        "description": "id is null",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  Scenario: Custom entity type update fails when id does not match URL
    * def etId = uuid()
    * def validEntityType =
      """
      {
        "id": "#(etId)",
        "name": "update_id_mismatch",
        "description": "id mismatch test",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request validEntityType
    When method POST
    Then status 201

    * copy invalidUpdate = validEntityType
    * set invalidUpdate.id = uuid()
    Given path 'entity-types/custom', 'update-id-mismatch'
    And request invalidUpdate
    When method PUT
    Then status 400

  # Validation: name must be non-null and non-empty
  Scenario: Custom entity type creation fails when name is null or empty
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": null,
        "description": "name is null",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

    * set invalidEntityType.name = ""
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  # Validation: sources[].alias must be non-null and non-empty, type must be "entity-type"
  Scenario: Custom entity type creation fails when sources[].alias is null or empty
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_alias_null",
        "description": "alias is null",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "entity-type",
            "alias": null,
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

    * set invalidEntityType.sources[0].alias = ""
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400

  Scenario: Custom entity type creation fails when sources[].type is not "entity-type"
    * def etId = uuid()
    * def invalidEntityType =
      """
      {
        "id": "#(etId)",
        "name": "invalid_type_not_entity_type",
        "description": "type is not entity-type",
        "shared": true,
        "isCustom": true,
        "private": true,
        "sources": [
          {
            "type": "database",
            "alias": "users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2"
          }
        ]
      }
      """
    Given path 'entity-types/custom'
    And request invalidEntityType
    When method POST
    Then status 400



  Scenario: Test available joins API for custom entity types (nothing -> custom ET -> targetId -> targetField)
    # 1. Set the body to {} and make the request
    * def availableJoinsBody = {}
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    # 2. Verify that the response has a non-empty availableTargetIds property (array of objects)
    And assert response.availableTargetIds.length > 0

    # 3. Add a customEntityType property to the request body JSON object (with a users source)
    * def sourcesForJoins =
      """{
        "sources": [
          {
            "type": "entity-type",
            "alias": "users",
            "name": "Users",
            "targetId": "bb058933-cd06-4539-bd3a-6f248ff98ee2",
            "useIdColumns": true,
            "inheritCustomFields": true
          }
        ]
      }
      """
    * set availableJoinsBody.sources = sourcesForJoins.sources

    # 4. Do another POST with this updated body
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    # 5. Verify non-empty availableTargetIds and availableSourceFields
    And assert response.availableTargetIds.length > 0
    And assert response.availableSourceFields.length > 0

    # 6. Add a targetId property to the request body (groups targetId from above)
    * set availableJoinsBody.targetId = 'e7717b38-4ff3-4fb9-ae09-b3d0c8400710'

    # 7. Do another POST with this updated body
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    # 8. Verify availableSourceFields and availableTargetFields are non-empty
    And assert response.availableSourceFields.length > 0
    And assert response.availableTargetFields.length > 0

    # 9. Add a targetField property to the request body with value "id"
    * set availableJoinsBody.targetField = 'id'

    # 10. Do another POST with this updated body
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    # 11. Verify availableSourceFields is an array with a single element for 'users.group_id' (it's a value+label, but we only care about the label)
    And match $.availableSourceFields == '#[1]'
    And match $.availableSourceFields[0].value == 'users.group_id'

  Scenario: Test available joins API for custom entity types (users -> sourceField -> targetId -> targetField)
    # 1. Start with a custom entity type containing users
    * def availableJoinsBody =
      """{
        sources: [
          {
            type: "entity-type",
            alias: "users",
            name: "Users",
            targetId: "bb058933-cd06-4539-bd3a-6f248ff98ee2",
            useIdColumns: true,
            inheritCustomFields: true
          }
        ]
      }
      """

    # 2. POST to available-joins
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    And assert response.availableSourceFields.length > 0
    And assert response.availableTargetIds.length > 0

    # 3. Add "users.group_id" as the sourceField
    * set availableJoinsBody.sourceField = 'users.group_id'

    # 4. POST to available-joins again
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    And assert response.availableTargetIds.length > 0

    # 5. Set the targetId to the "groups" ID
    * set availableJoinsBody.targetId = 'e7717b38-4ff3-4fb9-ae09-b3d0c8400710'

    # 6. POST to available-joins again
    Given path 'entity-types/custom/available-joins'
    And request availableJoinsBody
    When method POST
    Then status 200
    And assert response.availableTargetFields.length > 0

    # 7. Look for "id" in the availableTargetFields
    And match response.availableTargetFields[*].value contains 'id'
