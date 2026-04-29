Feature: Test authority record leader status on delete

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * configure readTimeout = 300000
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def utilPath = 'classpath:spitfire/mod-entities-links/features/samples/util/base.feature'
    * def sourceFileDtoPath = '/setup-records/authority/source-files/authority-source-file1.json'

  @C399060
  Scenario: LDR position 05 replaced with ""d"" when ""MARC Authority"" record deleted
    * def snapshotId = uuid()
    * def authorityId = uuid()
    * def sourceFileId = 'c95e6fa1-f3b1-4db6-ba05-1fb6e6c80599'
    # create snapshot
    * call read(utilPath + '@PostSnapshot')
    #  create  authority record
    * def result = call read(utilPath + '@PostAuthority') { extAuthorityId: #(authorityId), extSourceFileId: #(sourceFileId)}
    #  create  MARC authority record
    * call read(utilPath + '@CreateMarcAuthority') { extAuthority: #(authorityId)}

    # reusable validator
    * def validate999 =
      """
      function(fields, recordId, matchedId) {
        var f999 = fields.find(x => x['999']);
        var data = f999['999'];
        karate.match(data.ind1, 'f');
        karate.match(data.ind2, 'f');
        var subI = data.subfields.find(x => x.i);
        var subS = data.subfields.find(x => x.s);
        karate.match(subI.i, recordId);
        karate.match(subS.s, matchedId);
      }
      """
    
    # Get srs record and verify the LDR position 05 is "c" after the MARC record is created.
    * def srsRecord = call read(utilPath + '@GetSRSRecord') {recordId: '#(authorityId)', idType: 'AUTHORITY'}
    * match srsRecord.response.deleted == false
    * match srsRecord.response.state == 'ACTUAL'
    * def content = srsRecord.response.parsedRecord.content
    * def leader = content.leader
    * match leader[5] == 'c'
    * def matchedId = srsRecord.response.matchedId
    * eval validate999(content.fields, authorityId, matchedId)

    #  Delete the authority record
    * call read(utilPath + '@DeleteAuthority') {authorityId: '#(authorityId)'}

    # Get srs record and verify the LDR position 05 is "d" after the authority record is deleted.
    Given path 'source-storage/records', authorityId, 'formatted'
    And param idType = 'AUTHORITY'
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    * match response.state == 'DELETED'
    * match response.leaderRecordStatus == "d"
    * def content = response.parsedRecord.content
    * def leader = content.leader
    * match leader[5] == "d"
    * eval validate999(content.fields, authorityId, matchedId)