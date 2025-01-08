Feature: authorities and archives retrieval tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * configure retry = { count: 10, interval: 2000 }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples'
    * def utilPath = 'classpath:spitfire/mod-entities-links/features/samples/util/base.feature'
    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'

    # create authority source files and authorities
    * def sourceFileId1 = '5e519563-ca9e-4511-abb6-b9e03f8f8ec9'
    * def sourceFileId2 = '95ac6c1f-ce56-487b-81e4-f3fae6105f5a'
    * def toBeDeletedAuthorityId = 'fb9a4c6c-ba92-4a25-8868-a1bbf58baa4f'
    * def corporateAuthorityId = 'fd0b6ed1-d6af-4738-ac44-e99dbf561720'
    * def genreAuthorityId = '0b25ae57-9710-4c45-9789-2ee065699dcb'
    * def meetingAuthorityId = 'cd3eee4e-5edd-11ec-bf63-0242ac130002'
    * def personalAuthorityId1 = 'c73e6f60-5edd-11ec-bf63-0242ac130002'
    * def personalAuthorityId2 = 'ea2f2765-a2c7-40ff-88ea-8895def3d12c'
    * def geographicAuthorityId = '7c8474e3-f764-4bb8-8cbe-ecc52947460b'
    * def sourceFileDtoPath1 = '/setup-records/authority/source-files/authority-source-file2.json'
    * def sourceFileDtoPath2 = '/setup-records/authority/source-files/authority-source-file3.json'
    * def dtoPath1 = '/setup-records/authority/corporate-authority.json'
    * def dtoPath2 = '/setup-records/authority/genre-authority.json'
    * def dtoPath3 = '/setup-records/authority/meeting-authority.json'
    * def dtoPath4 = '/setup-records/authority/personal-authority1.json'
    * def dtoPath5 = '/setup-records/authority/geographic-authority.json'
    * def dtoPath6 = '/setup-records/authority/personal-authority2.json'

  Scenario: Create authority test data
    * call read(utilPath + '@PostSnapshot')
    # source files
    * call read(utilPath + '@PostAuthoritySourceFile') {extSourceFileId: #(sourceFileId1), filePath: #(sourceFileDtoPath1)}
    * call read(utilPath + '@PostAuthoritySourceFile') {extSourceFileId: #(sourceFileId2), filePath: #(sourceFileDtoPath2)}
    # authorities for source file 1
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(toBeDeletedAuthorityId), extSourceFileId: #(sourceFileId1)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(corporateAuthorityId), authorityPath: #(dtoPath1), extSourceFileId: #(sourceFileId1)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(genreAuthorityId), authorityPath: #(dtoPath2), extSourceFileId: #(sourceFileId1)}
    # authorities for source file 2
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(meetingAuthorityId), authorityPath: #(dtoPath3), extSourceFileId: #(sourceFileId2)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(personalAuthorityId1), authorityPath: #(dtoPath4), extSourceFileId: #(sourceFileId2)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(personalAuthorityId2), authorityPath: #(dtoPath6), extSourceFileId: #(sourceFileId2)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(geographicAuthorityId), authorityPath: #(dtoPath5), extSourceFileId: #(sourceFileId2)}


  Scenario: Delete authority record
    * call read(utilPath + '@CreateMarcAuthority') { extAuthority: #(toBeDeletedAuthorityId)}

    Given path 'authority-storage/authorities', toBeDeletedAuthorityId
    When method DELETE
    Then status 204

    Given path 'authority-storage/authorities', toBeDeletedAuthorityId
    When method GET
    Then status 404

    Given path '/source-storage/records', recordId
    And retry until response.state == "DELETED"
    When method GET
    Then status 200
    And match response.externalIdsHolder.authorityId == toBeDeletedAuthorityId
    And match response.recordType == 'MARC_AUTHORITY'
    And match response.deleted == true
    And match response.leaderRecordStatus == "d"

  Scenario: Attempt to delete non-existing authority record
    * def id = call uuid
    Given path 'authority-storage/authorities', id
    When method DELETE
    Then status 404
    Then match response.errors[0].message == 'Authority with ID [' + id + '] was not found'
    Then match response.errors[0].code == 'not-found'
    Then match response.errors[0].type == 'AuthorityNotFoundException'


  Scenario: Get Authorities filtered by source file
    Given path 'authority-storage/authorities'
    And param query = 'authoritySourceFile.id=' + sourceFileId1
    When method GET
    Then status 200
    Then match response.totalRecords == 2
    Then match response.authorities[*].sourceFileId == [#(sourceFileId1), #(sourceFileId1)]

  Scenario: Get Authorities filtered by heading type
    Given path 'authority-storage/authorities'
    And param query = 'headingType=corporateName'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[*].id == [#(corporateAuthorityId)]

  Scenario: Get Authorities filtered by created date
    Given path 'authority-storage/authorities'
    When method GET
    Then status 200
    And def total = response.totalRecords
    And def createdAt = response.authorities[0].metadata.createdDate

    * def createdBefore = datePlusDays(createdAt, 1)
    * def createdAfter = datePlusDays(createdAt, -1)

    Given path 'authority-storage/authorities'
    And param query = 'createdDate>' + createdAfter + ' and createdDate<=' + createdBefore
    When method GET
    Then status 200
    Then match response.totalRecords == total

  Scenario: Get Authorities filtered by updated date
    Given path 'authority-storage/authorities', corporateAuthorityId
    When method GET
    Then status 200
    And def authorityDto = response
    And def updatedAt = response.metadata.updatedDate

    * authorityDto.corporateName = authorityDto.corporateName + ' updated'
    * sleep(2)

    Given path 'authority-storage/authorities', corporateAuthorityId
    And request authorityDto
    When method PUT
    Then status 204

    Given path 'authority-storage/authorities', corporateAuthorityId
    When method GET
    Then status 200
    And toLocalDateTime(updatedAt) < toLocalDateTime(response.metadata.updatedDate)
    And def updatedDateAfter = response.metadata.updatedDate

    * def beforeDate = datePlusSeconds(updatedDateAfter, 1)
    * def afterDate = datePlusSeconds(updatedDateAfter, -1)

    Given path 'authority-storage/authorities'
    And param query = 'updatedDate>' + afterDate + ' and updatedDate<=' + beforeDate
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[*].id == [#(corporateAuthorityId)]
    Then match response.authorities[*].corporateName == ['a corporate name updated']


  Scenario: Get Authorities filtered by a combination of fields
    Given path 'authority-storage/authorities'
    And param query = 'authoritySourceFile.name="LC Subject Headings (LCSH)" and headingType=personalName'
    When method GET
    Then status 200
    Then match response.totalRecords == 2
    Then match response.authorities[*].sourceFileId == [#(sourceFileId2), #(sourceFileId2)]
    Then match response.authorities[*].personalName == ['a personal name 1', 'a personal name 2']

    Given path 'authority-storage/authorities', personalAuthorityId1
    When method GET
    Then status 200
    And def authorityDto = response
    And def updatedAt = response.metadata.updatedDate

    * authorityDto.personalName = authorityDto.personalName + ' updated'

    * sleep(2)

    Given path 'authority-storage/authorities', personalAuthorityId1
    And request authorityDto
    When method PUT
    Then status 204

    Given path 'authority-storage/authorities', personalAuthorityId1
    When method GET
    Then status 200
    Then toLocalDateTime(updatedAt) < toLocalDateTime(response.metadata.updatedDate)
    And def updatedDateAfter = response.metadata.updatedDate

    * def beforeDate = datePlusSeconds(updatedDateAfter, 2)
    * def afterDate = datePlusSeconds(updatedDateAfter, -1)
    * def queryUpdatePart = 'updatedDate>' + afterDate + ' and updatedDate<' + beforeDate

    Given path 'authority-storage/authorities'
    And param query = 'authoritySourceFile.name="LC Subject Headings (LCSH)" and headingType=personalName and ' + queryUpdatePart
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.authorities[*].sourceFileId == [#(sourceFileId2)]
    Then match response.authorities[*].personalName == ['a personal name 1 updated']

  Scenario: Retrieve Archived Authorities with multiple filters
    Given path 'authority-storage/authorities'
    And param deleted = true
    When method GET
    Then status 200
    And def totalBefore = response.totalRecords

    Given path 'authority-storage/authorities', personalAuthorityId1
    When method DELETE
    Then status 204

    Given path 'authority-storage/authorities', corporateAuthorityId
    When method DELETE
    Then status 204

    Given path 'authority-storage/authorities', genreAuthorityId
    When method DELETE
    Then status 204

    * def totalDeleted = totalBefore + 3
    * def deletedIds = [{id: #(personalAuthorityId1)}, {id: #(corporateAuthorityId)}, {id: #(genreAuthorityId)}]

    Given path 'authority-storage/authorities'
    And param deleted = true
    And param idOnly = true
    When method GET
    Then status 200
    Then match response.totalRecords == totalDeleted
    Then match response.authorities contains deletedIds

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'text/plain'  }
    Given path 'authority-storage/authorities'
    And param deleted = true
    And param idOnly = true
    When method GET
    Then status 200
    Then match response contains personalAuthorityId1
    Then match response contains corporateAuthorityId
    Then match response contains genreAuthorityId
    Then match header Content-type == 'text/plain'

    Given path 'authority-storage/authorities'
    And param deleted = true
    And param idOnly = true
    And param query = 'headingType=personalName and authoritySourceFile.id=' + sourceFileId2
    When method GET
    Then status 200
    Then match response == personalAuthorityId1
    Then match header Content-type == 'text/plain'

    Given path 'authority-storage/authorities'
    And param deleted = true
    And param query = 'headingType=personalName and authoritySourceFile.id=' + sourceFileId2
    When method GET
    Then status 400
    Then match response contains 'message: It is not allowed to retrieve authorities in text/plain format'
    Then match response contains 'parameters: [(key: Accept, value: text/plain),(key: idOnly, value: false)]'