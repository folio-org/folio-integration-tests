Feature: authorities tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
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
    * def personalAuthorityId = 'c73e6f60-5edd-11ec-bf63-0242ac130002'
    * def sourceFileDtoPath1 = '/setup-records/authority/source-files/authority-source-file2.json'
    * def sourceFileDtoPath2 = '/setup-records/authority/source-files/authority-source-file3.json'
    * def dtoPath1 = '/setup-records/authority/corporate-authority.json'
    * def dtoPath2 = '/setup-records/authority/genre-authority.json'
    * def dtoPath3 = '/setup-records/authority/meeting-authority.json'
    * def dtoPath4 = '/setup-records/authority/personal-authority.json'

  Scenario: Create authority test data
    * call read(utilPath + '@PostSnapshot')
    * call read(utilPath + '@PostAuthoritySourceFile') {extSourceFileId: #(sourceFileId1), filePath: #(sourceFileDtoPath1)}
    * call read(utilPath + '@PostAuthoritySourceFile') {extSourceFileId: #(sourceFileId2), filePath: #(sourceFileDtoPath2)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(toBeDeletedAuthorityId), extSourceFileId: #(sourceFileId1)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(corporateAuthorityId), authorityPath: #(dtoPath1), extSourceFileId: #(sourceFileId1)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(genreAuthorityId), authorityPath: #(dtoPath2), extSourceFileId: #(sourceFileId1)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(meetingAuthorityId), authorityPath: #(dtoPath3), extSourceFileId: #(sourceFileId2)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(personalAuthorityId), authorityPath: #(dtoPath4), extSourceFileId: #(sourceFileId2)}


  Scenario: Delete authority record
    * call read(utilPath + '@CreateMarcAuthority') { extAuthority: #(toBeDeletedAuthorityId)}

    Given path 'authority-storage/authorities', toBeDeletedAuthorityId
    When method DELETE
    Then status 204

    Given path 'authority-storage/authorities', toBeDeletedAuthorityId
    When method GET
    Then status 404

    Given path '/source-storage/records', recordId
    When method GET
    Then status 200
    And match response.externalIdsHolder.authorityId == toBeDeletedAuthorityId
    And match response.recordType == 'MARC_AUTHORITY'
    And match response.deleted == true
    And match response.leaderRecordStatus == "d"
    And match response.state == "DELETED"


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

    * def createdPlusOneDay = datePlusDays(createdAt, 1)
    * def createdMinusOneDay = datePlusDays(createdAt, -1)
    * def createdBefore = fromDate(createdPlusOneDay)
    * def createdAfter = fromDate(createdMinusOneDay)

    Given path 'authority-storage/authorities'
    And param query = 'createdDate>' + createdAfter + ' and createdDate<=' + createdBefore
    When method GET
    Then status 200
    Then match response.totalRecords == total