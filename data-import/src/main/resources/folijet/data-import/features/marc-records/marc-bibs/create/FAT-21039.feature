Feature: FAT-21039 Verify mapping of contributors from MARC 720 fields with relator terms and codes

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

  @C366547
  Scenario: FAT-21039 Verify mapping of contributors from MARC 720 fields (Personal/Corporate names with relator terms and codes)

    # ============================================================================
    # Steps 1-2 (REST): Upload "FAT-21039.mrc" and run the
    #                   "Default - Create instance and SRS MARC Bib" job profile.
    # Realized by @ImportRecord which executes:
    #   POST /data-import/uploadDefinitions
    #   GET  /data-import/uploadUrl
    #   PUT  {presignedS3Url}
    #   POST /data-import/uploadDefinitions/{id}/files/{fileId}/assembleStorageFile
    #   POST /data-import/uploadDefinitions/{id}/processFiles
    # ============================================================================
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-21039', jobName:'createInstance' }
    Then match status != 'ERROR'
    # ============================================================================
    # Step 2 confirmation (REST): wait until job execution reaches terminal state.
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
    # Lookup: contributor type ids for all relator-mapped types referenced in TestRail
    # expectations across the 3 records (used for deep contributorTypeId assertions).
    # ============================================================================
    Given path 'contributor-types'
    And headers headersUser
    And param query = 'name==("Author" or "Editor" or "Creator" or "Moderator" or "Performer" or "Delineator" or "Metadata contact")'
    And param limit = 100
    When method GET
    Then status 200
    * def typeIdByName = {}
    * eval response.contributorTypes.forEach(function(t){ typeIdByName[t.name] = t.id })

    # ============================================================================
    # Expected per-record contributors (layered: name + nameType + primary + count
    # + contributorTypeId + contributorTypeText). Values are taken from TestRail
    # case C366547 expectations (Steps 6, 11, 16).
    # MODSOURMAN-873 mapping rule: $4 wins over $e; if $e matches a contributorType
    # name it maps to contributorTypeId; otherwise $e -> contributorTypeText.
    # ============================================================================

    * def personalId  = personalNameTypeId
    * def corporateId = corporateNameTypeId
    * def meetingId   = meetingNameTypeId

    * def expectedRecord1 =
      """
      {
        count: 5,
        namesInOrder: [
          'Abdul Rahman, Alias',
          'Boguslawski, Pawel',
          'Gold, Christopher',
          'Said, Mohamad Nor',
          'Said, Abdul'
        ],
        nameTypeIdsInOrder: [
          '#(personalId)',  '#(personalId)',  '#(personalId)',
          '#(personalId)',  '#(personalId)'
        ],
        typeIdsInOrder: [
          '#(typeIdByName.Editor)',
          '#(typeIdByName.Author)',
          '#(typeIdByName.Editor)',
          null,
          null
        ],
        typeTextsInOrder: [
          null,
          null,
          null,
          'deditor',
          null
        ]
      }
      """

    * def expectedRecord2 =
      """
      {
        count: 6,
        namesInOrder: [
          'SAKAGUCHI, T',
          'OZAWA, K',
          'HAMAGAKI, H',
          'ESUMI, S',
          'KURIHARA, N',
          'CHUJO, T'
        ],
        nameTypeIdsInOrder: [
          '#(personalId)','#(personalId)','#(personalId)','#(personalId)','#(personalId)','#(personalId)'
        ],
        typeIdsInOrder: [
          '#(typeIdByName.Moderator)',
          null,
          '#(typeIdByName.Editor)',
          '#(typeIdByName["Metadata contact"])',
          '#(typeIdByName.Creator)',
          '#(typeIdByName.Delineator)'
        ],
        typeTextsInOrder: [
          null,
          null,
          null,
          null,
          null,
          null
        ]
      }
      """

    * def expectedRecord3 =
      """
      {
        count: 4,
        namesInOrder: [
          'John Alldis Choir',
          'Liverpool Philharmonic Choir',
          'London Symphony Orchestra',
          'Royal Liverpool Philharmonic Orchestra'
        ],
        nameTypeIdsInOrder: [
          '#(corporateId)','#(corporateId)','#(corporateId)','#(corporateId)'
        ],
        typeIdsInOrder: [
          '#(typeIdByName.Performer)',
          null,
          '#(typeIdByName.Performer)',
          null
        ],
        typeTextsInOrder: [
          null,
          'perf',
          null,
          'prf'
        ]
      }
      """

    * def expectedByOrder = [ '#(expectedRecord1)', '#(expectedRecord2)', '#(expectedRecord3)' ]

    # ============================================================================
    # Expected SRS source 720 fields per record (deep, deterministic).
    # Subfield arrays were derived from FAT-21039.mrc directly; they must round-trip
    # through mod-source-record-storage unchanged.
    # ============================================================================
    * def expectedSourceRecord1 =
      """
      [
        { '720': { ind1:' ', ind2:' ', subfields:[ {a:'Abdul Rahman, Alias'}, {e:'editor'}, {'4':'edt'} ] } },
        { '720': { ind1:' ', ind2:' ', subfields:[ {a:'Boguslawski, Pawel'}, {'4':'aut'}, {'4':'edt'} ] } },
        { '720': { ind1:' ', ind2:' ', subfields:[ {a:'Gold, Christopher'}, {e:'editor'}, {e:'author'} ] } },
        { '720': { ind1:' ', ind2:' ', subfields:[ {a:'Said, Mohamad Nor'}, {e:'deditor'} ] } },
        { '720': { ind1:' ', ind2:' ', subfields:[ {a:'Said, Abdul'}, {'4':'edi'} ] } }
      ]
      """

    * def expectedSourceRecord2 =
      """
      [
        { '720': { ind1:'1', ind2:' ', subfields:[ {a:'SAKAGUCHI, T.'}, {'4':'mod'}, {'4':'aut'} ] } },
        { '720': { ind1:'1', ind2:' ', subfields:[ {a:'OZAWA, K.'}, {'4':'mra'} ] } },
        { '720': { ind1:'1', ind2:' ', subfields:[ {a:'HAMAGAKI, H.'}, {'4':'mra'}, {e:'editor'} ] } },
        { '720': { ind1:'1', ind2:' ', subfields:[ {a:'ESUMI, S.'}, {e:'metadata contact'}, {'4':'mde'} ] } },
        { '720': { ind1:'1', ind2:' ', subfields:[ {a:'KURIHARA, N.'}, {e:'data contact'}, {e:'creator'} ] } },
        { '720': { ind1:'1', ind2:' ', subfields:[ {a:'CHUJO, T.'}, {'4':'dlm'}, {'4':'dln'} ] } }
      ]
      """

    * def expectedSourceRecord3 =
      """
      [
        { '720': { ind1:'2', ind2:' ', subfields:[ {a:'John Alldis Choir.'}, {'4':'prf'}, {'4':'cnd'} ] } },
        { '720': { ind1:'2', ind2:' ', subfields:[ {a:'Liverpool Philharmonic Choir.'}, {e:'perf'} ] } },
        { '720': { ind1:'2', ind2:' ', subfields:[ {a:'London Symphony Orchestra.'}, {e:'oth'}, {'4':'prf'} ] } },
        { '720': { ind1:'2', ind2:' ', subfields:[ {a:'Royal Liverpool Philharmonic Orchestra.'}, {e:'prf'} ] } }
      ]
      """

    * def expectedSourceByOrder = [ '#(expectedSourceRecord1)', '#(expectedSourceRecord2)', '#(expectedSourceRecord3)' ]

    # ============================================================================
    # Steps 4, 6, 7: For each created instance, verify Inventory contributors and
    # SRS MARC source via REST. Per-record verification delegated to @verifyEntry
    # (Karate sub-scenario) so any failed `match` fails the run (fail-fast).
    #   Step 4 (UI: "Created" link -> Inventory pane) -> GET /inventory/instances/{instanceId}
    #     (entries[i] order pinned via sourceRecordOrder; Nth .mrc record ->
    #      entriesSorted[i].relatedInstanceInfo.idList[0])
    #   Step 6 -> assertions on response.contributors (deep: contributorTypeId + contributorTypeText)
    #   Step 7 (UI: Actions -> View source)      -> GET /source-storage/records/{id}/formatted
    #   Step 8 (UI: close MARC view): no REST equivalent, no backend state change.
    # ============================================================================
    * def selfFeature = 'classpath:folijet/data-import/features/marc-records/marc-bibs/create/FAT-21039.feature'

    # Pin entry order to MARC source order so the Nth .mrc record always maps to
    # expectedByOrder[N]. The metadata-provider returns entries with order=asc by
    # default, but sourceRecordOrder is the authoritative per-entry index.
    * def entriesSorted = karate.sort(entries, function(x){ return parseInt(x.sourceRecordOrder) })
    * match entriesSorted[*].sourceRecordOrder == [ '0', '1', '2' ]

    * eval
      """
      for (var i = 0; i < entriesSorted.length; i++) {
        karate.call(selfFeature + '@verifyEntry', {
          idx: i,
          entry: entriesSorted[i],
          expected: expectedByOrder[i],
          expectedSource: expectedSourceByOrder[i]
        });
      }
      """

  # ===== Per-record verification sub-scenario =====

  @verifyEntry @ignore
  Scenario: Verify one created record (inventory contributors + SRS source 720)
    * def instanceId = entry.relatedInstanceInfo.idList[0]
    * def hrid       = entry.relatedInstanceInfo.hridList[0]
    * def sourceId   = entry.sourceRecordId
    * print '=== Verifying record #' + (idx + 1) + ' (instanceId=' + instanceId + ', hrid=' + hrid + ') ==='

    # --- Step 4 + 6: Inventory instance contributors (layered assertions) ---
    # Step 4 (UI: "Created" link) -> direct UUID GET (faithful to UI navigation).
    Given path 'inventory/instances', instanceId
    And headers headersUser
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.hrid == hrid
    * def contribs = response.contributors

    # Count
    * def actualCount = karate.sizeOf(contribs)
    * match actualCount == expected.count

    # Per-row schema (id/text optional but present-or-null; name/nameType/primary required)
    * match each contribs ==
      """
      {
        name: '#string',
        contributorNameTypeId: '#string',
        primary: '#boolean',
        authorityId: '##string',
        contributorTypeId: '##string',
        contributorTypeText: '##string'
      }
      """

    # Names in source-MRC tag order
    * def actualNames = karate.jsonPath(contribs, '$[*].name')
    * match actualNames == expected.namesInOrder

    # contributorNameTypeId per row
    * def actualNameTypeIds = karate.jsonPath(contribs, '$[*].contributorNameTypeId')
    * match actualNameTypeIds == expected.nameTypeIdsInOrder


    # contributorTypeId per row (MODSOURMAN-837 mapping rule verification)
    * def actualTypeIds = karate.jsonPath(contribs, '$[*].contributorTypeId')
    * match actualTypeIds == expected.typeIdsInOrder

    # contributorTypeText per row (Free text)
    * def actualTypeTexts = karate.jsonPath(contribs, '$[*].contributorTypeText')
    * match actualTypeTexts == expected.typeTextsInOrder

    # --- Step 7: SRS MARC source - deep subfield assertion on 720 fields ---
    Given path 'source-storage/records', sourceId, 'formatted'
    And headers headersUser
    When method GET
    Then status 200
    * def srsFields = response.parsedRecord.content.fields
    * def actualSevenTwenty =
      """
      karate.filter(srsFields, function(f){
        var k = Object.keys(f)[0];
        return k=='720';
      })
      """
    * match actualSevenTwenty == expectedSource
