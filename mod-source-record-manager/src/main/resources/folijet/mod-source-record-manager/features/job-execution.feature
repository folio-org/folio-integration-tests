Feature: Source-Record-Manager

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def testUserId = '00000000-1111-5555-9999-999999999992'
    * def oneFileJobExecution = { 'files' : [ { 'name' : 'importBib1.bib' } ], 'sourceType' : 'FILES', 'userId' : '#(testUserId)' }
    * def jobProfile = { "id": "22fafcc3-f582-493d-88b0-3c538480cd83", "name": "MARC records", "dataType": "MARC", "hidden": false }

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
        "id": "c306b7ad-36e5-44bc-bfc5-5b1ecee2f9c2",
        "initialRecords": [
          {
            "record": "01240cas a2200397   4500001000700000005001700007008004100024010001700065022001400082035002600096035002200122035001100144035001900155040004400174050001500218082001100233222004200244245004300286260004700329265003800376300001500414310002200429321002500451362002300476570002900499650003300528650004500561655004200606700004500648853001800693863002300711902001600734905002100750948003700771950003400808\u001e366832\u001e20141106221425.0\u001e750907c19509999enkqr p       0   a0eng d\u001e  \u001fa   58020553 \u001e  \u001fa0022-0469\u001e  \u001fa(CStRLIN)NYCX1604275S\u001e  \u001fa(NIC)notisABP6388\u001e  \u001fa366832\u001e  \u001fa(OCoLC)1604275\u001e  \u001fdCtY\u001fdMBTI\u001fdCtY\u001fdMBTI\u001fdNIC\u001fdCStRLIN\u001fdNIC\u001e0 \u001faBR140\u001fb.J6\u001e  \u001fa270.05\u001e04\u001faThe Journal of ecclesiastical history\u001e04\u001faThe Journal of ecclesiastical history.\u001e  \u001faLondon,\u001fbCambridge University Press [etc.]\u001e  \u001fa32 East 57th St., New York, 10022\u001e  \u001fav.\u001fb25 cm.\u001e  \u001faQuarterly,\u001fb1970-\u001e  \u001faSemiannual,\u001fb1950-69\u001e0 \u001fav. 1-   Apr. 1950-\u001e  \u001faEditor:   C. W. Dugmore.\u001e 0\u001faChurch history\u001fxPeriodicals.\u001e 7\u001faChurch history\u001f2fast\u001f0(OCoLC)fst00860740\u001e 7\u001faPeriodicals\u001f2fast\u001f0(OCoLC)fst01411641\u001e1 \u001faDugmore, C. W.\u001fq(Clifford William),\u001feed.\u001e03\u001f81\u001fav.\u001fi(year)\u001e40\u001f81\u001fa1-49\u001fi1950-1998\u001e  \u001fapfnd\u001fbLintz\u001e  \u001fa19890510120000.0\u001e2 \u001fa20141106\u001fbm\u001fdbatch\u001felts\u001fxaddfast\u001e  \u001flOLIN\u001faBR140\u001fb.J86\u001fh01/01/01 N\u001e\u001d01542ccm a2200361   "
          },
          {
            "record": "01314nam  22003851a 4500001001100000003000800011005001700019006001800036007001500054008004100069020003200110020003500142040002100177050002000198082001500218100002000233245008900253250001200342260004900354300002300403490002400426500002400450504006200474505009200536650003200628650001400660700002500674710001400699776004000713830001800753856009400771935001500865980003400880981001400914\u001eybp7406411\u001eNhCcYBP\u001e20120404100627.6\u001em||||||||d|||||||\u001ecr||n|||||||||\u001e120329s2011    sz a    ob    001 0 eng d\u001e  \u001fa2940447241 (electronic bk.)\u001e  \u001fa9782940447244 (electronic bk.)\u001e  \u001faNhCcYBP\u001fcNhCcYBP\u001e 4\u001faZ246\u001fb.A43 2011\u001e04\u001fa686.22\u001f222\u001e1 \u001faAmbrose, Gavin.\u001e14\u001faThe fundamentals of typography\u001fh[electronic resource] /\u001fcGavin Ambrose, Paul Harris.\u001e  \u001fa2nd ed.\u001e  \u001faLausanne ;\u001faWorthing :\u001fbAVA Academia,\u001fc2011.\u001e  \u001fa1 online resource.\u001e1 \u001faAVA Academia series\u001e  \u001faPrevious ed.: 2006.\u001e  \u001faIncludes bibliographical references (p. [200]) and index.\u001e0 \u001faType and language -- A few basics -- Letterforms -- Words and paragraphs -- Using type.\u001e 0\u001faGraphic design (Typography)\u001e 0\u001faPrinting.\u001e1 \u001faHarris, Paul,\u001fd1971-\u001e2 \u001faEBSCOhost\u001e  \u001fcOriginal\u001fz9782940411764\u001fz294041176X\u001e 0\u001faAVA academia.\u001e40\u001fuhttp://search.ebscohost.com/login.aspx?direct=true&scope=site&db=nlebk&db=nlabk&AN=430135\u001e  \u001fa.o13465259\u001e  \u001fa130307\u001fb7107\u001fe7107\u001ff243965\u001fg1\u001e  \u001fbOM\u001fcnlnet\u001e\u001d\n",
            "order": 5
          },
          {
            "record": "00182cx  a22000851  4500001000900000004000800009005001700017008003300034852002900067\u001e10245123\u001e9928371\u001e20170607135730.0\u001e1706072u    8   4001uu   0901128\u001e0 \u001fbfine\u001fhN7433.3\u001fi.B87 2014\u001e\u001d",
            "order": 6
          }
        ],
        "recordsMetadata": {
          "last": true,
          "counter": 7,
          "contentType": "MARC_RAW"
        }
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
  Scenario: Test return of journal records sorted by source record order
    * print 'This scenario might be a part of integration - importing a file and then querying the metadata provider API'

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
    And request raw3RecordDto
    When method POST
    Then status 204

    Given path 'change-manager', 'jobExecutions', jobExecutionId
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method GET
    Then status 200

    Given path 'metadata-provider', 'journalRecords', jobExecutionId
    And param sortBy = 'source_record_order'
    And param order = 'desc'
    When method GET
    Then status 200
    And assert response.totalRecords == 3
    And assert response.journalRecords.length == 3
    And assert response.journalRecords[0].sourceRecordOrder >= response.journalRecords[1].sourceRecordOrder
    And assert response.journalRecords[1].sourceRecordOrder >= response.journalRecords[2].sourceRecordOrder