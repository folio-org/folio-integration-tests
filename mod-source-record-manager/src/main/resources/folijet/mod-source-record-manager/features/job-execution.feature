Feature: Source-Record-Manager

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def testUserId = '00000000-1111-5555-9999-999999999992'
    * def oneFileJobExecution = { 'files' : [ { 'name' : 'importBib1.bib' } ], 'sourceType' : 'FILES', 'userId' : '#(testUserId)' }
    * def secondFileJobExecution = { 'files' : [ { 'name' : 'importBib2.bib' } ], 'sourceType' : 'FILES', 'userId' : '#(testUserId)' }
    * def jobProfile = {"id":"e34d7b92-9b83-11eb-a8b3-0242ac130003","name":"Default - Create instance and SRS MARC Bib","hidden":false,"dataType":"MARC"}
    * def multipleFileJobExecution = { 'files' : [ { 'name' : 'importBib1.bib' }, { 'name' : 'importBib2.bib' } ], 'sourceType' : 'FILES', 'userId' : '#(testUserId)' }
    * def expectedParentJobExecutions = 1;
    * def expectedChildJobExecutions = 2;

    * def updateStatusDiscarded = { 'status' : 'DISCARDED' }
    * def updateStatusParsing = { 'status' : 'PARSING_IN_PROGRESS' }
    * def uiStatusRunning = 'RUNNING'

    * def updateStatusError = { 'status' : 'ERROR', 'errorStatus' : 'FILE_PROCESSING_ERROR' }
    * def uiStatusError = 'ERROR'

    * def rawRecordDto =
    """
      {
        "id" : "e7b3377d-e942-4c34-bd8d-4eeffe12834e",
        "initialRecords" : [ {
          "record" : "01240cas a2200397   4500001000700000005001700007008004100024010001700065022001400082035002600096035002200122035001100144035001900155040004400174050001500218082001100233222004200244245004300286260004700329265003800376300001500414310002200429321002500451362002300476570002900499650003300528650004500561655004200606700004500648853001800693863002300711902001600734905002100750948003700771950003400808\u001E366832\u001E20141106221425.0\u001E750907c19509999enkqr p       0   a0eng d\u001E  \u001Fa   58020553 \u001E  \u001Fa0022-0469\u001E  \u001Fa(CStRLIN)NYCX1604275S\u001E  \u001Fa(NIC)notisABP6388\u001E  \u001Fa366832\u001E  \u001Fa(OCoLC)1604275\u001E  \u001FdCtY\u001FdMBTI\u001FdCtY\u001FdMBTI\u001FdNIC\u001FdCStRLIN\u001FdNIC\u001E0 \u001FaBR140\u001Fb.J6\u001E  \u001Fa270.05\u001E04\u001FaThe Journal of ecclesiastical history\u001E04\u001FaThe Journal of ecclesiastical history.\u001E  \u001FaLondon,\u001FbCambridge University Press [etc.]\u001E  \u001Fa32 East 57th St., New York, 10022\u001E  \u001Fav.\u001Fb25 cm.\u001E  \u001FaQuarterly,\u001Fb1970-\u001E  \u001FaSemiannual,\u001Fb1950-69\u001E0 \u001Fav. 1-   Apr. 1950-\u001E  \u001FaEditor:   C. W. Dugmore.\u001E 0\u001FaChurch history\u001FxPeriodicals.\u001E 7\u001FaChurch history\u001F2fast\u001F0(OCoLC)fst00860740\u001E 7\u001FaPeriodicals\u001F2fast\u001F0(OCoLC)fst01411641\u001E1 \u001FaDugmore, C. W.\u001Fq(Clifford William),\u001Feed.\u001E03\u001F81\u001Fav.\u001Fi(year)\u001E40\u001F81\u001Fa1-49\u001Fi1950-1998\u001E  \u001Fapfnd\u001FbLintz\u001E  \u001Fa19890510120000.0\u001E2 \u001Fa20141106\u001Fbm\u001Fdbatch\u001Felts\u001Fxaddfast\u001E  \u001FlOLIN\u001FaBR140\u001Fb.J86\u001Fh0101/01 N\u001E\u001D01542ccm a2200361   "
        } ],
        "recordsMetadata" : {
          "last" : false,
          "counter" : 15,
          "total" : 15,
          "contentType" : "MARC_RAW"
        }
      }
    """

    * def raw3RecordDto =
    """
{
  "id": "49846a65-0e02-404c-ae45-cb3b2043cda5",
  "recordsMetadata": {
    "last": true,
    "counter": 3,
    "contentType":"MARC_RAW",
    "total": 3
  },
  "initialRecords": [
    {
    "record": "01240cas a2200397   4500001000700000005001700007008004100024010001700065022001400082035002600096035002200122035001100144035001900155040004400174050001500218082001100233222004200244245004300286260004700329265003800376300001500414310002200429321002500451362002300476570002900499650003300528650004500561655004200606700004500648853001800693863002300711902001600734905002100750948003700771950003400808\u001E366832\u001E20141106221425.0\u001E750907c19509999enkqr p       0   a0eng d\u001E  \u001Fa   58020553 \u001E  \u001Fa0022-0469\u001E  \u001Fa(CStRLIN)NYCX1604275S\u001E  \u001Fa(NIC)notisABP6388\u001E  \u001Fa366832\u001E  \u001Fa(OCoLC)1604275\u001E  \u001FdCtY\u001FdMBTI\u001FdCtY\u001FdMBTI\u001FdNIC\u001FdCStRLIN\u001FdNIC\u001E0 \u001FaBR140\u001Fb.J6\u001E  \u001Fa270.05\u001E04\u001FaThe Journal of ecclesiastical history\u001E04\u001FaThe Journal of ecclesiastical history.\u001E  \u001FaLondon,\u001FbCambridge University Press [etc.]\u001E  \u001Fa32 East 57th St., New York, 10022\u001E  \u001Fav.\u001Fb25 cm.\u001E  \u001FaQuarterly,\u001Fb1970-\u001E  \u001FaSemiannual,\u001Fb1950-69\u001E0 \u001Fav. 1-   Apr. 1950-\u001E  \u001FaEditor:   C. W. Dugmore.\u001E 0\u001FaChurch history\u001FxPeriodicals.\u001E 7\u001FaChurch history\u001F2fast\u001F0(OCoLC)fst00860740\u001E 7\u001FaPeriodicals\u001F2fast\u001F0(OCoLC)fst01411641\u001E1 \u001FaDugmore, C. W.\u001Fq(Clifford William),\u001Feed.\u001E03\u001F81\u001Fav.\u001Fi(year)\u001E40\u001F81\u001Fa1-49\u001Fi1950-1998\u001E  \u001Fapfnd\u001FbLintz\u001E  \u001Fa19890510120000.0\u001E2 \u001Fa20141106\u001Fbm\u001Fdbatch\u001Felts\u001Fxaddfast\u001E  \u001FlOLIN\u001FaBR140\u001Fb.J86\u001Fh01/01/01 N\u001E\u001D01542ccm a2200361   ",
    "order": 1
    },
    {
    "record": "01240cas a2200397   4500001000700000005001700007008004100024010001700065022001400082035002600096035002200122035001100144035001900155040004400174050001500218082001100233222004200244245004300286260004700329265003800376300001500414310002200429321002500451362002300476570002900499650003300528650004500561655004200606700004500648853001800693863002300711902001600734905002100750948003700771950003400808\u001E366832\u001E20141106221425.0\u001E750907c19509999enkqr p       0   a0eng d\u001E  \u001Fa   58020553 \u001E  \u001Fa0022-0469\u001E  \u001Fa(CStRLIN)NYCX1604275S\u001E  \u001Fa(NIC)notisABP6388\u001E  \u001Fa366832\u001E  \u001Fa(OCoLC)1604275\u001E  \u001FdCtY\u001FdMBTI\u001FdCtY\u001FdMBTI\u001FdNIC\u001FdCStRLIN\u001FdNIC\u001E0 \u001FaBR140\u001Fb.J6\u001E  \u001Fa270.05\u001E04\u001FaThe Journal of ecclesiastical history\u001E04\u001FaThe Journal of ecclesiastical history.\u001E  \u001FaLondon,\u001FbCambridge University Press [etc.]\u001E  \u001Fa32 East 57th St., New York, 10022\u001E  \u001Fav.\u001Fb25 cm.\u001E  \u001FaQuarterly,\u001Fb1970-\u001E  \u001FaSemiannual,\u001Fb1950-69\u001E0 \u001Fav. 1-   Apr. 1950-\u001E  \u001FaEditor:   C. W. Dugmore.\u001E 0\u001FaChurch history\u001FxPeriodicals.\u001E 7\u001FaChurch history\u001F2fast\u001F0(OCoLC)fst00860740\u001E 7\u001FaPeriodicals\u001F2fast\u001F0(OCoLC)fst01411641\u001E1 \u001FaDugmore, C. W.\u001Fq(Clifford William),\u001Feed.\u001E03\u001F81\u001Fav.\u001Fi(year)\u001E40\u001F81\u001Fa1-49\u001Fi1950-1998\u001E  \u001Fapfnd\u001FbLintz\u001E  \u001Fa19890510120000.0\u001E2 \u001Fa20141106\u001Fbm\u001Fdbatch\u001Felts\u001Fxaddfast\u001E  \u001FlOLIN\u001FaBR140\u001Fb.J86\u001Fh01/01/01 N\u001E\u001D01542ccm a2200361   ",
    "order": 2
    },
    {
    "record": "01240cas a2200397   4500001000700000005001700007008004100024010001700065022001400082035002600096035002200122035001100144035001900155040004400174050001500218082001100233222004200244245004300286260004700329265003800376300001500414310002200429321002500451362002300476570002900499650003300528650004500561655004200606700004500648853001800693863002300711902001600734905002100750948003700771950003400808\u001E366832\u001E20141106221425.0\u001E750907c19509999enkqr p       0   a0eng d\u001E  \u001Fa   58020553 \u001E  \u001Fa0022-0469\u001E  \u001Fa(CStRLIN)NYCX1604275S\u001E  \u001Fa(NIC)notisABP6388\u001E  \u001Fa366832\u001E  \u001Fa(OCoLC)1604275\u001E  \u001FdCtY\u001FdMBTI\u001FdCtY\u001FdMBTI\u001FdNIC\u001FdCStRLIN\u001FdNIC\u001E0 \u001FaBR140\u001Fb.J6\u001E  \u001Fa270.05\u001E04\u001FaThe Journal of ecclesiastical history\u001E04\u001FaThe Journal of ecclesiastical history.\u001E  \u001FaLondon,\u001FbCambridge University Press [etc.]\u001E  \u001Fa32 East 57th St., New York, 10022\u001E  \u001Fav.\u001Fb25 cm.\u001E  \u001FaQuarterly,\u001Fb1970-\u001E  \u001FaSemiannual,\u001Fb1950-69\u001E0 \u001Fav. 1-   Apr. 1950-\u001E  \u001FaEditor:   C. W. Dugmore.\u001E 0\u001FaChurch history\u001FxPeriodicals.\u001E 7\u001FaChurch history\u001F2fast\u001F0(OCoLC)fst00860740\u001E 7\u001FaPeriodicals\u001F2fast\u001F0(OCoLC)fst01411641\u001E1 \u001FaDugmore, C. W.\u001Fq(Clifford William),\u001Feed.\u001E03\u001F81\u001Fav.\u001Fi(year)\u001E40\u001F81\u001Fa1-49\u001Fi1950-1998\u001E  \u001Fapfnd\u001FbLintz\u001E  \u001Fa19890510120000.0\u001E2 \u001Fa20141106\u001Fbm\u001Fdbatch\u001Felts\u001Fxaddfast\u001E  \u001FlOLIN\u001FaBR140\u001Fb.J86\u001Fh01/01/01 N\u001E\u001D01542ccm a2200361   ",
    "order": 3
    }
  ]
}
"""

    * def arrayOfJobExecutorsFilteredBySubordinationType =
    """
      function (subordinationType) {
        return response.jobExecutions.filter(jobExecution => jobExecution.subordinationType === subordinationType && isJobExecutionValid(jobExecution));
      }
    """

    * def isJobExecutionValid =
    """
      function(jobExecution) {
        return jobExecution != null
          && jobExecution.id != null
          && jobExecution.parentJobId != null
      }
    """

  @Positive
  Scenario: Test init job execution with 1 file
    * print 'Test init job execution with 1 file'

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201
    And match response.parentJobExecutionId != null

    * def parentJobExecution = response.jobExecutions[0]
    * def isJobExecutionValid = call isJobExecutionValid parentJobExecution
    And match parentJobExecution.sourcePath != null
    And match parentJobExecution.fileName != null
    And match isJobExecutionValid == true
    And match parentJobExecution.subordinationType == 'PARENT_SINGLE'
    And match parentJobExecution.status == 'NEW'
    And match parentJobExecution.id == parentJobExecution.parentJobId

  @Positive
  Scenario: Test init job execution with multiple files
    * print 'Test init job execution with multiple files'

    * def expectedJobExecutionsNumber = expectedParentJobExecutions + expectedChildJobExecutions;

    Given path 'change-manager', 'jobExecutions'
    And request multipleFileJobExecution
    When method POST
    Then status 201
    And match response.parentJobExecutionId != null
    And assert response.jobExecutions.length == 3

    * def parent = call arrayOfJobExecutorsFilteredBySubordinationType 'PARENT_MULTIPLE'
    And assert parent.length == expectedParentJobExecutions

    * def children = call arrayOfJobExecutorsFilteredBySubordinationType 'CHILD'
    And assert children.length == expectedChildJobExecutions

  @Positive
  Scenario: Test return job execution on get by id
    * print 'Init job execution, get that job execution'

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201

    * def parentId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', parentId
    When method GET
    Then status 200
    And match response.id == parentId
    And assert response.hrId >= 0
    And match response.runBy.firstName != null
    And match response.runBy.lastName != null

  @Positive
  Scenario: Test return of children job executions for multiple files
    * print 'Init job execution with multiple files, get children of that job execution'

    Given path 'change-manager', 'jobExecutions'
    And request multipleFileJobExecution
    When method POST
    Then status 201

    * def parent = call arrayOfJobExecutorsFilteredBySubordinationType 'PARENT_MULTIPLE'

    Given path 'change-manager', 'jobExecutions', parent[0].id, 'children'
    When method GET
    Then status 200
    And assert response.jobExecutions.length == expectedChildJobExecutions
    And match response.totalRecords == expectedChildJobExecutions
    And match response.jobExecutions[*].subordinationType == ["CHILD","CHILD"]

  @Positive
  Scenario: Test update of a status of job execution
    * print 'Init job execution, update its status'

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201

    * def jobExecutionId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', jobExecutionId, 'status'
    And request updateStatusParsing
    When method PUT
    Then status 200
    And match response.status == updateStatusParsing.status
    And match response.uiStatus == uiStatusRunning

  @Positive
  Scenario: Test filter jobExecutions by status
    * print 'Init job execution, filter by status'

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201

    * def jobExecutionsId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', jobExecutionsId, 'status'
    And request updateStatusParsing
    When method PUT
    Then status 200

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201

    * def jobExecutionsId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', jobExecutionsId, 'status'
    And request updateStatusDiscarded
    When method PUT
    Then status 200

    Given path 'metadata-provider', 'jobExecutions'
    And param statusAny = updateStatusDiscarded.status
    When method GET
    Then status 200
    And response.totalRecords = 1
    And response.jobExecutions.length = 1
    And response.jobExecutions[0].id = jobExecutionsId
    And response.jobExecutions[0].status = updateStatusDiscarded.status

  @Positive
  Scenario: Test completed date and total for job execution when status is updated to ERROR
    * print 'Init job execution, update its status to ERROR, verify completed date is set and total is set to zero'

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201

    * def jobExecutionId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', jobExecutionId, 'status'
    And request updateStatusError
    When method PUT
    Then status 200
    And match response.status == updateStatusError.status
    And match response.uiStatus == uiStatusError
    And match response.errorStatus == updateStatusError.errorStatus
    And match response.completedDate != null

    Given path 'change-manager', 'jobExecutions', jobExecutionId
    When method GET
    Then status 200
    And match response.status == updateStatusError.status
    And match response.uiStatus == uiStatusError
    And match response.errorStatus == updateStatusError.errorStatus
    And match response.completedDate != null
    And match response.progress.total == 0

  @Positive
  Scenario: Test processing of a chunk of raw records
    * print 'Init job execution, post chunk of raw records'

    Given path 'change-manager', 'jobExecutions'
    And request oneFileJobExecution
    When method POST
    Then status 201

    * def jobExecutionId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', jobExecutionId, 'jobProfile'
    And request jobProfile
    When method PUT
    Then status 200

    Given path 'change-manager', 'jobExecutions', jobExecutionId, 'records'
    And request rawRecordDto
    When method POST
    Then status 204

    Given path 'change-manager', 'jobExecutions', jobExecutionId
    When method GET
    Then status 200
    And match response.status == 'PARSING_IN_PROGRESS'
    And match response.runBy.firstName != null
    And match response.progress.total == rawRecordDto.recordsMetadata.total
    And match response.startedDate != null

  @Positive
  Scenario: Test return all existing journal records
    * print 'This scenario might be a part of integration - importing a file and then querying the metadata provider API'

    Given path 'change-manager', 'jobExecutions'
    And request secondFileJobExecution
    When method POST
    Then status 201

    * def jobExecutionId = response.jobExecutions[0].id

    Given path 'change-manager', 'jobExecutions', jobExecutionId, 'jobProfile'
    And request jobProfile
    When method PUT
    Then status 200

    Given path 'change-manager', 'jobExecutions', jobExecutionId, 'records'
    And request raw3RecordDto
    When method POST
    Then status 204

    Given path 'change-manager', 'jobExecutions', jobExecutionId
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method GET
    Then status 200

    * call sleep 5

    Given path 'metadata-provider', 'journalRecords', jobExecutionId
    And param sortBy = 'source_record_order'
    And param order = 'desc'
    When method GET
    Then status 200
    And match response.totalRecords == 6
    And assert response.journalRecords.length == 6