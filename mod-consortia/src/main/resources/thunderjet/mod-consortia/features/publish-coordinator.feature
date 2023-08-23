Feature: Consortia publish coordinator tests

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure retry = { count: 10, interval: 1000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * def tagLabel = 'cons-test'
    * def tagDescription = 'consortia karate test tag'
    * def departmentId = '6b757b4c-202f-4187-a674-e16ab07f5e25'
    * def wrongConsortiumId = 'a051a9f0-3512-11ee-be56-0242ac120002'
    * def name = 'Accounting12345'
    * def updateName = 'Management1234'
    * def code = 'XX1'
    * def updateCode = 'YY1'
    * def source = 'System'

  @Positive
  Scenario: Verify publish coordinator has persisted requests:
    # 1. Publish requests to endpoint /tags
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          "url": "/tags",
          "method": "POST",
          "tenants": [
              "#(centralTenant)",
              "#(universityTenant)",
              "#(collegeTenant)"
          ],
          "payload": {
              "label": "cons-test",
              "description": "consortia karate test tag"
          }
      }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200

    # 3. Retrieve succeeded publication results and verify data from all tenant responses
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def centralResponse = karate.toString(response.publicationResults[0])
    * match centralResponse contains 'cons-test'
    * match centralResponse contains 'consortia karate test tag'
    * def universityResponse = karate.toString(response.publicationResults[1])
    * match universityResponse contains 'cons-test'
    * match universityResponse contains 'consortia karate test tag'
    * def collegeResponse = karate.toString(response.publicationResults[2])
    * match collegeResponse contains 'cons-test'
    * match collegeResponse contains 'consortia karate test tag'

  @Negative
  Scenario: Get error when publishing duplicate requests:
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
        "url": "/tags",
        "method": "POST",
        "tenants": [
            "#(centralTenant)",
            "#(universityTenant)",
            "#(collegeTenant)"
        ],
        "payload": {
            "label": "cons-test",
            "description": "consortia karate test tag"
        }
    }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def failedPublicationId = response.id

    # 2. Retrieve publication status with errors. expected status ERROR
    Given path 'consortia', consortiumId, 'publications', failedPublicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200

    # 3. Retrieve failed publication results
    Given path 'consortia', consortiumId, 'publications', failedPublicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # Negative case for send request with path non-existing consortiumId
    Given path 'consortia', wrongConsortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
        "url": "/tags",
        "method": "POST",
        "tenants": [
            "#(centralTenant)",
            "#(universityTenant)",
            "#(collegeTenant)"
        ],
        "payload": {
            "label": "cons-test",
            "description": "consortia karate test tag"
        }
    }
    """
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [a051a9f0-3512-11ee-be56-0242ac120002] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

  @Positive
  Scenario: Sending GET request and check the results
    # 1. Publish requests to endpoint /departments
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
        "url": "/departments",
        "method": "POST",
        "tenants": [
            "#(centralTenant)",
            "#(universityTenant)",
            "#(collegeTenant)"

        ],
        "payload": {
            "id": "#(departmentId)",
            "name": "#(name)",
            "code": "#(code)",
            "usageNumber": 10,
            "source": "#(source)"
        }
    }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200

    # 3. Publish requests to endpoint /departments with GET request
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          "url": "/departments",
          "method": "GET",
          "tenants": [
              "#(centralTenant)",
              "#(universityTenant)",
              "#(collegeTenant)"
          ]
      }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 4. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200

    # 5. Retrieve succeeded publication results and check previous created department are returned
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def centralResponse = karate.toString(response.publicationResults[0])
    * match centralResponse contains '6b757b4c-202f-4187-a674-e16ab07f5e25'
    * match centralResponse contains 'Accounting12345'
    * match centralResponse contains 'XX1'
    * def universityResponse = karate.toString(response.publicationResults[1])
    * match universityResponse contains '6b757b4c-202f-4187-a674-e16ab07f5e25'
    * match universityResponse contains 'Accounting12345'
    * match universityResponse contains 'XX1'
    * def collegeResponse = karate.toString(response.publicationResults[2])
    * match collegeResponse contains '6b757b4c-202f-4187-a674-e16ab07f5e25'
    * match collegeResponse contains 'Accounting12345'
    * match collegeResponse contains 'XX1'

  @Positive
  Scenario: Sending PUT request to update and check results
    # 1. Publish requests to endpoint /departments with PUT request to update department name and code
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          "url": "/departments/6b757b4c-202f-4187-a674-e16ab07f5e25",
          "method": "PUT",
          "tenants": [
              "#(centralTenant)",
              "#(universityTenant)",
              "#(collegeTenant)"
          ],
          "payload": {
            "id": "#(departmentId)",
            "name": "#(updateName)",
            "code": "#(updateCode)",
            "usageNumber": 10,
            "source": "#(source)"
        }
      }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200

    # 3. Retrieve succeeded publication results
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.publicationResults[0].tenantId == centralTenant
    And match response.publicationResults[1].tenantId == universityTenant
    And match response.publicationResults[2].tenantId == collegeTenant

    # 4.1 Check from tags endpoint that tag is created in central tenant
    Given path 'departments', departmentId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == updateName
    And match response.code == updateCode

    # 4.2 Check from tags endpoint that tag is created in university tenant
    Given path 'departments', departmentId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == updateName
    And match response.code == updateCode

#   4.3 Check from tags endpoint that tag is created in college tenant
    Given path 'departments', departmentId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 200
    And match response.id == departmentId
    And match response.name == updateName
    And match response.code == updateCode

  @Positive
  Scenario: Sending DELETE request to delete departments
    # 1. Publish requests to endpoint /departments with DELETE request to delete department which already exists
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
      {
          "url": "/departments/6b757b4c-202f-4187-a674-e16ab07f5e25",
          "method": "DELETE",
          "tenants": [
              "#(centralTenant)",
              "#(universityTenant)",
              "#(collegeTenant)"
          ]
      }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 2. Retrieve succeeded publication status. expected status COMPLETE
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'COMPLETE'
    When method GET
    Then status 200

    # 3. Retrieve succeeded publication results
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200

    # 4.1 Check from tags endpoint that department is created in central tenant
    Given path 'departments', departmentId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 404

    # 4.2 Check from tags endpoint that department is created in university tenant
    Given path 'departments', departmentId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # 4.3 Check from tags endpoint that department is created in college tenant
    Given path 'departments', departmentId
    And header x-okapi-tenant = collegeTenant
    When method GET
    Then status 404

  @Negative
  Scenario: Verify publication status to Error, in case of publication request fails for one of three tenants
    # In order to create this situation, we create a department object in universityTenant,
    # and then, it throw 422 exception (because of having same name, code), when we save object for this tenant.
    # As a result, one of them will fail and others will completed. Last status should be ERROR

    # 1. We will create department object in second tenant
    Given path 'departments'
    And header x-okapi-tenant = universityTenant
    And request
    """
    {
        "id": "#(departmentId)",
        "name": "#(name)",
        "code": "#(code)",
        "usageNumber": 10,
        "source": "#(source)"
    }
    """
    When method POST
    Then status 201

    # 1. Publish requests to endpoint /departments
    Given path 'consortia', consortiumId, 'publications'
    And header x-okapi-tenant = centralTenant
    And request
    """
    {
        "url": "/departments",
        "method": "POST",
        "tenants": [
            "#(centralTenant)",
            "#(universityTenant)",
            "#(collegeTenant)"
        ],
        "payload": {
            "id": "#(departmentId)",
            "name": "#(name)",
            "code": "#(code)",
            "usageNumber": 10,
            "source": "#(source)"
        }
    }
    """
    When method POST
    Then status 201
    And match response.status == "IN_PROGRESS"
    * def publicationId = response.id

    # 2. Retrieve error publication status. expected status ERROR
    Given path 'consortia', consortiumId, 'publications', publicationId
    And header x-okapi-tenant = centralTenant
    And retry until response.status == 'ERROR'
    When method GET
    Then status 200

    # 3. Retrieve publication results and verify response of universityTenant should have error relate to 422
    Given path 'consortia', consortiumId, 'publications', publicationId, 'results'
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    * def centralResponse = karate.toString(response.publicationResults[0])
    * match centralResponse contains '6b757b4c-202f-4187-a674-e16ab07f5e25'
    * match centralResponse contains 'Accounting12345'
    * match centralResponse contains 'XX1'
    * def universityResponse = karate.toString(response.publicationResults[1])
    * match karate.toString(universityResponse) contains '422'
    * match response.publicationResults[1].statusCode == 400
    * def collegeResponse = karate.toString(response.publicationResults[2])
    * match collegeResponse contains '6b757b4c-202f-4187-a674-e16ab07f5e25'
    * match collegeResponse contains 'Accounting12345'
    * match collegeResponse contains 'XX1'
