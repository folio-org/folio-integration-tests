Feature: FAT-21032 - Instance updatedBy is changed after single record import for overlay

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')
    * configure retry = { interval: 5000, count: 30 }

  @C353539
  Scenario: FAT-21032 Verify Instance updatedBy is changed after single record import for instance overlay
    * def profileId = 'f26df83c-aa25-40b6-876e-96852c3d4fd4'
    * def externalIdentifierType = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef'

    # Precondition: Ensure single record import OCLC WorldCat profile with credentials
    Given path 'copycat/profiles', profileId
    And headers headersUser
    And request
      """
      {
        "id": "#(profileId)",
        "name": "OCLC WorldCat",
        "url": "zcat.oclc.org/OLUCWorldCat",
        "authentication": "100481406/PAOLF",
        "externalIdQueryMap": "@attr 1=1211 $identifier",
        "internalIdEmbedPath": "999ff$i",
        "createJobProfileId": "d0ebb7b0-2f0f-11eb-adc1-0242ac120002",
        "updateJobProfileId": "91f9b8d6-d80e-4727-9783-73fb53e3c786",
        "allowedCreateJobProfileIds": ["d0ebb7b0-2f0f-11eb-adc1-0242ac120002"],
        "allowedUpdateJobProfileIds": ["91f9b8d6-d80e-4727-9783-73fb53e3c786"],
        "targetOptions": {
          "charset": "utf-8"
        },
        "externalIdentifierType": "#(externalIdentifierType)",
        "enabled": true
      }
      """
    When method PUT
    Then status 204

    # Run record import to create instance
    * def res = call read(utilFeature+'@ImportRecord') { fileName:'marcBib', jobName:'createInstance' }
    * match res.jobExecution.status == 'COMMITTED'
    * def jobExecutionId = res.jobExecution.id

    # Retrieve instance Id from job log entries
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And def instanceId = response.entries[0].relatedInstanceInfo.idList[0]

    # Login as testUser2 to run single record import for instance overlay/update
    * call login testUser2
    * def okapitokenTestUser2 = okapitoken
    * def headersTestUser2 = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenTestUser2)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    # Run single record import for instance overlay using OCLC WorldCat profile as testUser2
    Given path 'copycat/imports'
    And headers headersTestUser2
    And request
      """
      {
        "externalIdentifier": "1232123",
        "internalIdentifier": "#(instanceId)",
        "profileId": "#(profileId)"
      }
      """
    When method POST
    Then status 200

    # Verify import job triggered by single record import is finished with status COMMITTED
    Given path 'metadata-provider/jobExecutions'
    And headers headersTestUser2
    And param fileName = 'No file name'
    And param sortBy = 'started_date,desc'
    And retry until response.jobExecutions[0].status == 'COMMITTED' || response.jobExecutions[0].status == 'ERROR' || response.jobExecutions[0].status == 'DISCARDED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMMITTED'

    # Retrieve testUser2 details for comparison
    Given path 'users'
    And headers headersTestUser2
    And param query = 'username==' + testUser2.name
    And param limit = 1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def testUserId = response.users[0].id
    * def testUserFirstName = response.users[0].personal.firstName
    * def testUserLastName = response.users[0].personal.lastName

    # Verify instance metadata.updatedByUserId reflect testUser2
    Given path 'inventory/instances', instanceId
    And headers headersTestUser2
    When method GET
    Then status 200
    And match response.metadata.updatedDate == '#present'
    And match response.metadata.updatedByUserId == testUserId

    # Verify through quick-marc editor that Marc-Bibliographic record updateinfo.updatedBy fields reflect testUser2
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersTestUser2
    When method GET
    Then status 200
    And match response.updateInfo.updatedBy.userId == testUserId
    And match response.updateInfo.updatedBy.firstName == testUserFirstName
    And match response.updateInfo.updatedBy.lastName == testUserLastName
    And match response.updateInfo.updatedBy.username == testUser2.name
