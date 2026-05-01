Feature: FAT-21038

  # All steps in this scenario are performed via REST.
  # Any UI verbs from the original test case ("upload", "click", "view source",
  # "expand accordion", "redirected to ...") are realized through the
  # corresponding backend REST endpoints listed in inline comments below.
  # Note: 'uiStatus' is a REST payload field on jobExecutions; despite its
  # name it is not a UI value.

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-21038 Verify mapping of contributors from MARC 1xx/7xx fields (Personal/Corporate/Meeting names with relator terms and codes)

    # ============================================================================
    # Steps 1-2 (REST): Upload "1xx7xx_contributors.mrc" and run the
    #                   "Default - Create instance and SRS MARC Bib" job profile.
    # Realized by @ImportRecord which executes:
    #   POST /data-import/uploadDefinitions
    #   GET  /data-import/uploadUrl
    #   PUT  {presignedS3Url}
    #   POST /data-import/uploadDefinitions/{id}/files/{fileId}/assembleStorageFile
    #   POST /data-import/uploadDefinitions/{id}/processFiles
    # The actual file in the repo is named "1xx7xx relator terms.mrc"; we pass
    # the explicit path via filePathFromSourceRoot (supported by import-record.feature).
    # ============================================================================
    * def srcMrcPath = 'classpath:folijet/data-import/samples/mrc-files/1xx7xx relator terms.mrc'
    Given call read(utilFeature+'@ImportRecord') { fileName: '1xx7xx_contributors', jobName: 'createInstance', filePathFromSourceRoot: '#(srcMrcPath)' }
    Then match status != 'ERROR'

    # ============================================================================
    # Step 2 confirmation (REST): wait until job execution reaches terminal state.
    # Realized by completeExecutionFeature which polls:
    #   GET /metadata-provider/jobExecutions  (until COMMITTED + RUNNING_COMPLETE)
    #   GET /change-manager/jobExecutions/{parentId}/children
    #   GET /change-manager/jobExecutions/{parentId}  (until terminal)
    #   GET /change-manager/jobExecutions/{childId}
    # ============================================================================
    * call read(completeExecutionFeature) { key: '#(sourcePath)' }
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 3
    And assert jobExecution.progress.total == 3
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # ============================================================================
    # Step 3 (REST): retrieve job log entries.
    #   GET /metadata-provider/jobLogEntries/{jobExecutionId}
    # Each entry exposes relatedInstanceInfo (Instance) and sourceRecordActionStatus
    # (SRS MARC). Verifying both equals the UI assertion that "SRS MARC and Instance
    # were created" for every record with 1xx/7xx fields.
    # ============================================================================
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 3
    When method GET
    Then status 200
    * def entries = response.entries
    * match each entries[*].sourceRecordActionStatus == 'CREATED'
    * match each entries[*]..relatedInstanceInfo.actionStatus contains 'CREATED'
    * match each entries[*] contains { error: '' }

    # ============================================================================
    # Lookup: contributor name type ids (Personal / Corporate / Meeting)
    # ============================================================================
    Given path 'contributor-name-types'
    And headers headersUser
    And param query = 'name==("Personal name" or "Corporate name" or "Meeting name")'
    And param limit = 100
    When method GET
    Then status 200
    * def personalNameTypeId  = karate.jsonPath(response.contributorNameTypes, "$[?(@.name=='Personal name')].id")[0]
    * def corporateNameTypeId = karate.jsonPath(response.contributorNameTypes, "$[?(@.name=='Corporate name')].id")[0]
    * def meetingNameTypeId   = karate.jsonPath(response.contributorNameTypes, "$[?(@.name=='Meeting name')].id")[0]

    # ============================================================================
    # Lookup: contributor-types (relator codes used in the .mrc file)
    # Used to resolve $4 relator codes to contributorTypeId.
    # ============================================================================
    Given path 'contributor-types'
    And headers headersUser
    And param query = 'cql.allRecords=1'
    And param limit = 500
    When method GET
    Then status 200
    * def ctByCode = {}
    * eval for (var i = 0; i < response.contributorTypes.length; i++) { var ct = response.contributorTypes[i]; if (ct.code) ctByCode[ct.code] = ct.id }

    # ============================================================================
    # Expected per-record contributors derived from "1xx7xx relator terms.mrc"
    # (records 1, 2, 3 in file order). Step 5 (UI: expand "Contributor" accordion)
    # is intrinsically covered by the inventory/instances response which always
    # includes the full contributors[] array.
    # Step 6: name + contributorNameTypeId + contributorTypeId + contributorTypeText.
    # ============================================================================

    # --- Record 1: Crossfire / Staceyann Chin ---
    * def expectedContribs1 =
      """
      [
        { "name": "Chin, Staceyann, 1972-",  "contributorNameTypeId": "#(personalNameTypeId)",  "contributorTypeId": null,                "contributorTypeText": "Author, Narrator", "primary": true },
        { "name": "Woodson, Jacqueline,",    "contributorNameTypeId": "#(personalNameTypeId)",  "contributorTypeId": null,                "contributorTypeText": "writer of foreword" },
        { "name": "BroBand.",                "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": "#(ctByCode.win)",   "contributorTypeText": null },
        { "name": "Woodson, Jackie.",        "contributorNameTypeId": "#(personalNameTypeId)",  "contributorTypeId": "#(ctByCode.wam)",   "contributorTypeText": null },
        { "name": "BroBoyBand.",             "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": null,                "contributorTypeText": "writer" },
        { "name": "BroGirlBand.",            "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": null,                "contributorTypeText": "writer of added lyrics" },
        { "name": "Woodson, Jack.",          "contributorNameTypeId": "#(personalNameTypeId)",  "contributorTypeId": "#(ctByCode.art)",   "contributorTypeText": "artisti" }
      ]
      """

    # --- Record 2: 1950 Oklahoma traffic map ---
    * def expectedContribs2 =
      """
      [
        { "name": "Oklahoma. Dept. of Highways.",             "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": "#(ctByCode.cou)", "contributorTypeText": null, "primary": true },
        { "name": "United States. Bureau of Public Roads 1.", "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": null,              "contributorTypeText": "court" },
        { "name": "United States. Bureau of Public Roads 2.", "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": "#(ctByCode.coo)", "contributorTypeText": null },
        { "name": "United States. Bureau of Public Roads 2.", "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": "#(ctByCode.coo)", "contributorTypeText": null },
        { "name": "United States. Bureau of Public Roads 2.", "contributorNameTypeId": "#(corporateNameTypeId)", "contributorTypeId": null,              "contributorTypeText": "correctort" }
      ]
      """

    # --- Record 3: International Conference on Business History ---
    * def expectedContribs3 =
      """
      [
        { "name": "International Conference on Business History (17th : 1990)", "contributorNameTypeId": "#(meetingNameTypeId)",  "contributorTypeId": "#(ctByCode.cot)", "contributorTypeText": null, "primary": true },
        { "name": "Abe, Etsuo, 1949-",                                          "contributorNameTypeId": "#(personalNameTypeId)", "contributorTypeId": "#(ctByCode.cou)", "contributorTypeText": null },
        { "name": "Suzuki, Yoshitaka, 1944-",                                   "contributorNameTypeId": "#(personalNameTypeId)", "contributorTypeId": null,              "contributorTypeText": "contestant" },
        { "name": "International Conference on Business History (18th : 1991)", "contributorNameTypeId": "#(meetingNameTypeId)",  "contributorTypeId": "#(ctByCode.ccc)", "contributorTypeText": "contestee" },
        { "name": "International Conference on Business History (19th : 1992)", "contributorNameTypeId": "#(meetingNameTypeId)",  "contributorTypeId": "#(ctByCode.cte)", "contributorTypeText": "contester" },
        { "name": "International Conference on Business History (20th : 1993)", "contributorNameTypeId": "#(meetingNameTypeId)",  "contributorTypeId": "#(ctByCode.dnc)", "contributorTypeText": null },
        { "name": "International Conference on Business History (20th : 1993)", "contributorNameTypeId": "#(meetingNameTypeId)",  "contributorTypeId": "#(ctByCode.cur)", "contributorTypeText": null },
        { "name": "International Conference on Business History (21st : 1994)", "contributorNameTypeId": "#(meetingNameTypeId)",  "contributorTypeId": null,              "contributorTypeText": "dedicator, dedicatee" }
      ]
      """

    * def expectedByOrder = [ '#(expectedContribs1)', '#(expectedContribs2)', '#(expectedContribs3)' ]
    # MARC 1xx/7xx tags expected in SRS parsedRecord.content.fields per record (preserved order)
    * def expectedTagsByOrder =
      """
      [
        ["100","700","710","700","710","710","700"],
        ["110","710","710","710","710"],
        ["111","700","700","711","711","711","711"]
      ]
      """

    # ============================================================================
    # Steps 4, 6, 7 (and 9-17): For each created instance, verify Inventory
    # contributors and SRS MARC source via REST.
    #   Step 4 (UI: click "Created" -> Inventory pane) -> GET /inventory/instances?query=hrid==
    #   Step 6 -> assert contributors[] (name, type, free text) on the same response
    #   Step 7 (UI: Actions -> View source) -> GET /source-storage/records/{sourceRecordId}
    #          and (mirroring quickMARC view) GET /records-editor/records?externalId={instanceId}
    #   Step 8 (UI: close MARC view): no REST equivalent, no backend state change;
    #          the loop simply proceeds to the next record's verification.
    # ============================================================================
    * def selfFeature = 'classpath:folijet/data-import/features/marc-records/marc-bibs/create/FAT-21038.feature'

    * def verifyEntry =
      """
      function(args) {
        var idx = args.idx;
        var entry = args.entry;
        var expected = args.expected;
        var expectedTags = args.expectedTags;
        karate.log('=== Verifying record #' + (idx + 1) + ' ===');

        var hrid       = entry.relatedInstanceInfo.hridList[0];
        var instanceId = entry.relatedInstanceInfo.idList[0];
        var sourceId   = entry.sourceRecordId;

        // Step 4 + 6: Inventory instance contributors
        var inst = karate.call(args.selfFeature + '@getInstance', { hrid: hrid });
        var contribs = inst.instance.contributors;
        karate.match(contribs, '#[' + expected.length + ']');
        karate.match(contribs, 'contains only', expected);

        // Step 7a: SRS MARC source record - verify 1xx/7xx tags preserved
        var src = karate.call(args.selfFeature + '@getSource', { sourceRecordId: sourceId });
        var fields = src.parsed.fields;
        var actualTags = [];
        for (var k = 0; k < fields.length; k++) {
          for (var t in fields[k]) {
            if (t === '100' || t === '110' || t === '111' || t === '700' || t === '710' || t === '711') {
              actualTags.push(t);
            }
          }
        }
        karate.match(actualTags, expectedTags);

        // Step 7b: quickMARC view (mirrors UI "Actions -> View source")
        var qm = karate.call(args.selfFeature + '@getQuickMarc', { externalId: instanceId });
        var qmTags = [];
        for (var k = 0; k < qm.fields.length; k++) {
          var tag = qm.fields[k].tag;
          if (tag === '100' || tag === '110' || tag === '111' || tag === '700' || tag === '710' || tag === '711') {
            qmTags.push(tag);
          }
        }
        karate.match(qmTags, expectedTags);

        // Step 8: no REST equivalent; proceed to next record.
      }
      """

    * eval for (var i = 0; i < entries.length; i++) verifyEntry({ idx: i, entry: entries[i], expected: expectedByOrder[i], expectedTags: expectedTagsByOrder[i], selfFeature: selfFeature })

  # ===== Helper scenarios (called per entry from the loop above) =====

  @getInstance
  Scenario: GET instance by HRID
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + hrid
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def instance = response.instances[0]

  @getSource
  Scenario: GET SRS record by id
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def parsed = response.parsedRecord.content

  @getQuickMarc
  Scenario: GET quickMARC bib by externalId (mirrors UI "Actions -> View source")
    Given path 'records-editor/records'
    And param externalId = externalId
    And headers headersUser
    When method GET
    Then status 200
    * def fields = response.fields
