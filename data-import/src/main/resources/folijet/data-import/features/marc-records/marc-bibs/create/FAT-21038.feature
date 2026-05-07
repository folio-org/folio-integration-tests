Feature: FAT-21038 Verify revision to relator term/code handling for 1xx7xx fields

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

  @C365638
  Scenario: FAT-21038 Verify mapping of contributors from MARC 1xx/7xx fields (Personal/Corporate/Meeting names with relator terms and codes)

    # ============================================================================
    # Steps 1-2 (REST): Upload "FAT-21038.mrc" and run the
    #                   "Default - Create instance and SRS MARC Bib" job profile.
    # Realized by @ImportRecord which executes:
    #   POST /data-import/uploadDefinitions
    #   GET  /data-import/uploadUrl
    #   PUT  {presignedS3Url}
    #   POST /data-import/uploadDefinitions/{id}/files/{fileId}/assembleStorageFile
    #   POST /data-import/uploadDefinitions/{id}/processFiles
    # ============================================================================
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-21038', jobName:'createInstance' }
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
    And param query = 'name==("Author" or "Writer of introduction" or "Writer of accompanying material" or "Writer of added lyrics" or "Artist" or "Court governed" or "Court reporter" or "Contestant-appellant" or "Contestant" or "Contestee" or "Contestee-appellee" or "Dancer" or "Dedicator")'
    And param limit = 100
    When method GET
    Then status 200
    * def typeIdByName = {}
    * eval response.contributorTypes.forEach(function(t){ typeIdByName[t.name] = t.id })
    * match karate.sizeOf(karate.keysOf(typeIdByName)) == 13

    # ============================================================================
    # Expected per-record contributors (layered: name + nameType + primary + count
    # + contributorTypeId + contributorTypeText). Values are taken from TestRail
    # case C365638 expectations (Steps 6, 11, 16). Any drift between TestRail wording
    # and mod-inventory's actual normalization will surface here as a CI failure.
    # MODSOURMAN-837 mapping rule: $4 wins over $e; if $e matches a contributorType
    # name it maps to contributorTypeId; otherwise $e -> contributorTypeText.
    # ============================================================================

    * def personalId  = personalNameTypeId
    * def corporateId = corporateNameTypeId
    * def meetingId   = meetingNameTypeId

    * def expectedRecord1 =
      """
      {
        count: 7,
        namesInOrder: [
          'Chin, Staceyann, 1972-',
          'Woodson, Jacqueline',
          'BroBand',
          'Woodson, Jackie',
          'BroBoyBand',
          'BroGirlBand',
          'Woodson, Jack'
        ],
        nameTypeIdsInOrder: [
          '#(personalId)',  '#(personalId)',  '#(corporateId)',
          '#(personalId)',  '#(corporateId)', '#(corporateId)',
          '#(personalId)'
        ],
        typeIdsInOrder: [
          '#(typeIdByName.Author)',
          null,
          '#(typeIdByName["Writer of introduction"])',
          '#(typeIdByName["Writer of accompanying material"])',
          null,
          '#(typeIdByName["Writer of added lyrics"])',
          '#(typeIdByName.Artist)'
        ],
        typeTextsInOrder: [
          null,
          'writer of foreword.',
          null,
          null,
          'writer',
          null,
          null
        ],
        primaryName: 'Chin, Staceyann, 1972-'
      }
      """

    * def expectedRecord2 =
      """
      {
        count: 5,
        namesInOrder: [
          'Oklahoma. Dept. of Highways',
          'United States. Bureau of Public Roads 1.',
          'United States. Bureau of Public Roads 2.',
          'United States. Bureau of Public Roads 2.',
          'United States. Bureau of Public Roads 2.'
        ],
        nameTypeIdsInOrder: [
          '#(corporateId)','#(corporateId)','#(corporateId)','#(corporateId)','#(corporateId)'
        ],
        typeIdsInOrder: [
          '#(typeIdByName["Court governed"])',
          null,
          '#(typeIdByName["Court reporter"])',
          null,
          null
        ],
        typeTextsInOrder: [
          null,
          'court',
          null,
          null,
          'correctort'
        ],
        primaryName: 'Oklahoma. Dept. of Highways'
      }
      """

    * def expectedRecord3 =
      """
      {
        count: 7,
        namesInOrder: [
          'International Conference on Business History (17th : 1990)',
          'Abe, Etsuo, 1949-',
          'Suzuki, Yoshitaka, 1944-',
          'International Conference on Business History (18th : 1991)',
          'International Conference on Business History (19th : 1992)',
          'International Conference on Business History (20th : 1993)',
          'International Conference on Business History (21st : 1994)'
        ],
        nameTypeIdsInOrder: [
          '#(meetingId)','#(personalId)','#(personalId)',
          '#(meetingId)','#(meetingId)','#(meetingId)','#(meetingId)'
        ],
        typeIdsInOrder: [
          '#(typeIdByName["Contestant-appellant"])',
          '#(typeIdByName["Court governed"])',
          '#(typeIdByName.Contestant)',
          '#(typeIdByName.Contestee)',
          '#(typeIdByName["Contestee-appellee"])',
          '#(typeIdByName.Dancer)',
          '#(typeIdByName.Dedicator)'
        ],
        typeTextsInOrder: [
          null, null, null, null, null, null, null
        ],
        primaryName: 'International Conference on Business History (17th : 1990)'
      }
      """

    * def expectedByOrder = [ '#(expectedRecord1)', '#(expectedRecord2)', '#(expectedRecord3)' ]

    # ============================================================================
    # Expected SRS source 1xx/7xx fields per record (deep, deterministic).
    # Subfield arrays were derived from FAT-21038.mrc directly; they must round-trip
    # through mod-source-record-storage unchanged.
    # ============================================================================
    * def expectedSourceRecord1 =
      """
      [
        { '100': { ind1:'1', ind2:' ', subfields:[ {a:'Chin, Staceyann,'}, {d:'1972-'}, {e:'Author'}, {e:'Narrator'}, {'0':'http://id.loc.gov/authorities/names/n2008052404'}, {'1':'http://viaf.org/viaf/24074052'} ] } },
        { '700': { ind1:'1', ind2:' ', subfields:[ {a:'Woodson, Jacqueline,'}, {e:'writer of foreword.'}, {'0':'http://id.loc.gov/authorities/names/n88234700'}, {'1':'http://viaf.org/viaf/79117120'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'BroBand.'}, {'4':'win'} ] } },
        { '700': { ind1:'1', ind2:' ', subfields:[ {a:'Woodson, Jackie.'}, {'4':'wam'}, {'4':'wac'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'BroBoyBand.'}, {e:'writer'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'BroGirlBand.'}, {e:'writer of added lyrics'} ] } },
        { '700': { ind1:'1', ind2:' ', subfields:[ {a:'Woodson, Jack.'}, {e:'artisti'}, {'4':'art'} ] } }
      ]
      """

    * def expectedSourceRecord2 =
      """
      [
        { '110': { ind1:'1', ind2:' ', subfields:[ {a:'Oklahoma.'}, {b:'Dept. of Highways.'}, {'4':'cou'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'United States.'}, {b:'Bureau of Public Roads 1.'}, {e:'court'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'United States.'}, {b:'Bureau of Public Roads 2.'}, {'4':'coo'}, {'4':'crt'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'United States.'}, {b:'Bureau of Public Roads 2.'}, {'4':'coo'} ] } },
        { '710': { ind1:'1', ind2:' ', subfields:[ {a:'United States.'}, {b:'Bureau of Public Roads 2.'}, {e:'correctort'} ] } }
      ]
      """

    * def expectedSourceRecord3 =
      """
      [
        { '111': { ind1:'2', ind2:' ', subfields:[ {a:'International Conference on Business History'}, {n:'(17th :'}, {d:'1990)'}, {'4':'cot'} ] } },
        { '700': { ind1:'1', ind2:'0', subfields:[ {a:'Abe, Etsuo,'}, {d:'1949-'}, {'4':'cou'} ] } },
        { '700': { ind1:'1', ind2:'0', subfields:[ {a:'Suzuki, Yoshitaka,'}, {d:'1944-'}, {e:'contestant'} ] } },
        { '711': { ind1:'1', ind2:' ', subfields:[ {a:'International Conference on Business History'}, {n:'(18th :'}, {d:'1991)'}, {j:'contestee'}, {'4':'ccc'} ] } },
        { '711': { ind1:'1', ind2:' ', subfields:[ {a:'International Conference on Business History'}, {n:'(19th :'}, {d:'1992)'}, {j:'contester'}, {'4':'cte'} ] } },
        { '711': { ind1:'1', ind2:' ', subfields:[ {a:'International Conference on Business History'}, {n:'(20th :'}, {d:'1993)'}, {'4':'dnc'}, {'4':'cur'} ] } },
        { '711': { ind1:'1', ind2:' ', subfields:[ {a:'International Conference on Business History'}, {n:'(21st :'}, {d:'1994)'}, {j:'dedicator'}, {j:'dedicatee'} ] } }
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
    * def selfFeature = 'classpath:folijet/data-import/features/marc-records/marc-bibs/create/FAT-21038.feature'

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
  Scenario: Verify one created record (inventory contributors + SRS source 1xx/7xx)
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

    # Exactly one primary contributor, and it's the first one
    * def primaryNames = karate.jsonPath(contribs, "$[?(@.primary==true)].name")
    * def expectedPrimaryName = expected.primaryName
    * match primaryNames == [ '#(expectedPrimaryName)' ]

    # contributorTypeId per row (MODSOURMAN-837 mapping rule verification)
    * def actualTypeIds = karate.jsonPath(contribs, '$[*].contributorTypeId')
    * match actualTypeIds == expected.typeIdsInOrder

    # contributorTypeText per row (Free text)
    * def actualTypeTexts = karate.jsonPath(contribs, '$[*].contributorTypeText')
    * match actualTypeTexts == expected.typeTextsInOrder

    # --- Step 7: SRS MARC source - deep subfield assertion on 1xx/7xx fields ---
    Given path 'source-storage/records', sourceId, 'formatted'
    And headers headersUser
    When method GET
    Then status 200
    * def srsFields = response.parsedRecord.content.fields
    * def actualOneXxSevenXx =
      """
      karate.filter(srsFields, function(f){
        var k = Object.keys(f)[0];
        return k=='100'||k=='110'||k=='111'||k=='700'||k=='710'||k=='711';
      })
      """
    * match actualOneXxSevenXx == expectedSource
