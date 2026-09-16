# For FAT-27653, https://foliotest.testrail.io/index.php?/cases/view/1348599
Feature: Agreements + Lines Entity Type Displays Agreement And Line Records

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * configure retry = { count: 30, interval: 5000 }
    * def agreementLinesEntityTypeId = 'a1e1b9b8-1f9f-4a01-b8c7-2c8a8a000010'

    * def createOrganization = read('classpath:athena/mod-lists/features/util/create-organization.feature')
    * def ensureOrgRole = read('classpath:athena/mod-lists/features/util/erm/ensure-org-role.feature')
    * def importErmPackage = read('classpath:athena/mod-lists/features/util/erm/import-package.feature')
    * def createAgreement = read('classpath:athena/mod-lists/features/util/erm/create-agreement.feature')
    * def runFqmQuery = read('classpath:athena/mod-lists/features/util/run-fqm-query.feature')
    * def getFieldValueId = read('classpath:athena/mod-lists/features/util/get-field-value-id.feature')
    * def exportExistingList = read('classpath:athena/mod-lists/features/util/export-existing-list.feature')

    # Dates Relative To The Current Year
    * def LocalDate = Java.type('java.time.LocalDate')
    * def TemporalAdjusters = Java.type('java.time.temporal.TemporalAdjusters')
    * def currentYear = LocalDate.now().getYear()
    * def dateOf = function(year, month, day) { return LocalDate.of(year, month, day).toString() + '' }
    * def yearBeforeLastStart = dateOf(currentYear - 2, 1, 1)
    * def yearBeforeLastCancellation = dateOf(currentYear - 2, 11, 30)
    * def yearBeforeLastEnd = dateOf(currentYear - 2, 12, 31)
    * def lastYearStart = dateOf(currentYear - 1, 1, 1)
    * def lastYearEnd = dateOf(currentYear - 1, 12, 31)
    * def currentYearStart = dateOf(currentYear, 1, 1)
    * def currentYearFebruaryStart = dateOf(currentYear, 2, 1)
    * def currentYearNovemberEnd = dateOf(currentYear, 11, 30)
    * def currentYearEnd = dateOf(currentYear, 12, 31)
    * def nextYearStart = dateOf(currentYear + 1, 1, 1)
    * def nextYearNovemberEnd = dateOf(currentYear + 1, 11, 30)
    * def nextYearEnd = dateOf(currentYear + 1, 12, 31)
    * def nextMonthStart = LocalDate.now().plusMonths(1).withDayOfMonth(1).toString() + ''
    * def nextMonthEnd = LocalDate.now().plusMonths(1).with(TemporalAdjusters.lastDayOfMonth()).toString() + ''

    # FQL Builders
    * def cond = function(field, operator, value) { return '{"' + field + '":{"' + operator + '":' + JSON.stringify(value) + '}}' }
    * def fql = function(conditions) { return '{"$and":[' + conditions.join(',') + ']}' }

    # Result Helpers
    * def rowsFor = function(rows, agreementName) { return karate.filter(rows, function(row) { return row['agreement.sa_name'] == agreementName }) }
    * def countsByAgreement = function(rows) { return [rowsFor(rows, agreement1Name).length, rowsFor(rows, agreement2Name).length, rowsFor(rows, agreement3Name).length, rowsFor(rows, agreement4Name).length] }
    * def csvCountsByAgreement = function(csvRows) { return karate.map([agreement1Name, agreement2Name, agreement3Name, agreement4Name], function(name) { return karate.filter(csvRows, function(line) { return line.indexOf(name) >= 0 }).length }) }
    * def distinct =
      """
      function(rows, field) {
        var values = [];
        karate.forEach(rows, function(row) {
          var value = row[field];
          if (value != null && values.indexOf('' + value) < 0) values.push('' + value);
        });
        return values.sort();
      }
      """
    * def agreementSummary =
      """
      function(rows) {
        return {
          rows: rows.length,
          status: distinct(rows, 'agreement.sa_agreement_status_label'),
          description: distinct(rows, 'agreement.sa_description'),
          renewalPriority: distinct(rows, 'agreement.sa_renewal_priority_label'),
          isPerpetual: distinct(rows, 'agreement.sa_is_perpetual_label'),
          reasonForClosure: distinct(rows, 'agreement.sa_reason_for_closure_label'),
          startDate: distinct(rows, 'agreement.sa_start_date'),
          endDate: distinct(rows, 'agreement.sa_end_date'),
          cancellationDeadline: distinct(rows, 'agreement.sa_cancellation_deadline'),
          periodStartDates: distinct(rows, 'period.per_start_date'),
          periodEndDates: distinct(rows, 'period.per_end_date'),
          agreementOrgNames: distinct(rows, 'agreement_org.org_name'),
          organizationNames: distinct(rows, 'organization.name'),
          organizationCodes: distinct(rows, 'organization.code'),
          lineTypes: distinct(rows, 'agreement_line.ent_type')
        };
      }
      """
    * def lineSummary =
      """
      function(rows, lineType) {
        var lineRows = karate.filter(rows, function(row) { return row['agreement_line.ent_type'] == lineType });
        return {
          rows: lineRows.length,
          authority: distinct(lineRows, 'agreement_line.ent_authority'),
          reference: distinct(lineRows, 'agreement_line.ent_reference'),
          resourceName: distinct(lineRows, 'agreement_line.ent_res_name'),
          suppressFromDiscovery: distinct(lineRows, 'agreement_line.ent_suppress_discovery'),
          activeFrom: distinct(lineRows, 'agreement_line.ent_active_from'),
          activeTo: distinct(lineRows, 'agreement_line.ent_active_to')
        };
      }
      """
    * def rolesFor =
      """
      function(rows, orgName) {
        var orgRows = karate.filter(rows, function(row) { return row['agreement_org.org_name'] == orgName });
        if (orgRows.length == 0) return [];
        var roles = orgRows[0]['agreement_org.sao_roles'];
        return typeof roles === 'string' ? JSON.parse(roles) : roles;
      }
      """
    * def isRefreshed = function(list, recordsCount) { return list.inProgressRefresh == null && list.successRefresh != null && list.successRefresh.recordsCount == recordsCount }

  @C1348599
  @Positive
  Scenario: Agreements + Lines ET Correctly Displays Agreement And Line Records
    # Generate Unique Names For This Test Scenario
    * def suffix = randomMillis()
    * def agreementPrefix = 'Agr' + suffix
    * def agreement1Name = agreementPrefix + ' #1'
    * def agreement2Name = agreementPrefix + ' #2'
    * def agreement3Name = agreementPrefix + ' #3'
    * def agreement4Name = agreementPrefix + ' #4'
    * def orgAId = call uuid
    * def orgBId = call uuid
    * def orgCId = call uuid
    * def orgAName = 'Org A ' + suffix
    * def orgBName = 'Org B ' + suffix
    * def orgCName = 'Org C ' + suffix
    * def orgACode = 'ORGA' + suffix
    * def orgBCode = 'ORGB' + suffix
    * def orgCCode = 'ORGC' + suffix
    * def localPackageName = 'Simple Package ' + suffix
    * def gokbPackageName = 'GOKb Package ' + suffix
    * def gokbTitleName = 'GOKb Title ' + suffix
    # mod-agreements names a package content item after its title, platform and package
    * def gokbTitlePciName = "'" + gokbTitleName + "' on Platform 'FQM Test Platform' in Package " + gokbPackageName
    * def ekbTitleName = 'eHoldings Title ' + suffix
    * def ekbTitleReference = '19-' + suffix + '-7'
    * def ekbPackageName = 'eHoldings Package ' + suffix
    * def ekbPackageReference = '19-' + suffix

    # 1. Install FQM Entity Types So Those Depending On mod-agreements Are Available
    # mod-agreements is enabled in a separate application after FQM, so its entity types are not installed yet
    Given path 'entity-types', 'install'
    When method POST
    Then status 204

    # 2. Ensure "Content Provider" And "Vendor" Roles Exist In "SubscriptionAgreementOrg.Role" Pick List
    * def v = call ensureOrgRole { roleLabel: 'Content provider', roleValue: 'content_provider' }
    * def v = call ensureOrgRole { roleLabel: 'Vendor', roleValue: 'vendor' }

    # 3. Create Organizations A, B And C
    * def v = call createOrganization { id: '#(orgAId)', name: '#(orgAName)', code: '#(orgACode)' }
    * def v = call createOrganization { id: '#(orgBId)', name: '#(orgBName)', code: '#(orgBCode)' }
    * def v = call createOrganization { id: '#(orgCId)', name: '#(orgCName)', code: '#(orgCCode)' }

    # 4. Import Local KB Package And A GOKb-Sourced Package With A Title
    * def localPackage = call importErmPackage { packageName: '#(localPackageName)', packageReference: '#("local-" + suffix)', packageSource: 'Local', titleName: '#("Simple Title " + suffix)' }
    * def gokbPackage = call importErmPackage { packageName: '#(gokbPackageName)', packageReference: '#("gokb-" + suffix)', packageSource: 'GOKb', titleName: '#(gokbTitleName)' }

    # 5. Create Active Agreement #1 With Four Periods, Two Organizations And Two Agreement Lines
    * def agreement1 =
      """
      {
        name: '#(agreement1Name)',
        description: 'Active agreement description',
        agreementStatus: 'active',
        renewalPriority: 'definitely_cancel',
        isPerpetual: 'no',
        periods: [
          { startDate: '#(yearBeforeLastStart)', endDate: '#(yearBeforeLastEnd)', cancellationDeadline: '#(yearBeforeLastCancellation)' },
          { startDate: '#(lastYearStart)', endDate: '#(lastYearEnd)' },
          { startDate: '#(currentYearStart)', endDate: '#(currentYearEnd)' },
          { startDate: '#(nextYearStart)', endDate: '#(nextYearEnd)', cancellationDeadline: '#(nextYearNovemberEnd)' }
        ],
        orgs: [
          { org: { orgsUuid: '#(orgAId)', name: '#(orgAName)' }, roles: [ { role: 'content_provider' } ] },
          { org: { orgsUuid: '#(orgBId)', name: '#(orgBName)' }, roles: [ { role: 'vendor' } ] }
        ],
        items: [
          { resource: { id: '#(localPackage.packageId)' }, activeFrom: '#(yearBeforeLastStart)', activeTo: '#(yearBeforeLastEnd)', suppressFromDiscovery: true },
          { type: 'external', authority: 'EKB-TITLE', reference: '#(ekbTitleReference)', resourceName: '#(ekbTitleName)', activeFrom: '#(nextMonthStart)', activeTo: '#(nextMonthEnd)' }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement1)' }

    # 6. Create Draft Agreement #2 Without Agreement Lines
    * def agreement2 =
      """
      {
        name: '#(agreement2Name)',
        description: 'Draft agreement description',
        agreementStatus: 'draft',
        renewalPriority: 'definitely_renew',
        periods: [ { startDate: '#(nextYearStart)' } ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement2)' }

    # 7. Create Closed Agreement #3 With Two Organizations And Three Agreement Lines
    * def agreement3 =
      """
      {
        name: '#(agreement3Name)',
        agreementStatus: 'closed',
        reasonForClosure: 'rejected',
        periods: [ { startDate: '#(currentYearFebruaryStart)', endDate: '#(currentYearNovemberEnd)', cancellationDeadline: '#(currentYearNovemberEnd)' } ],
        orgs: [
          { org: { orgsUuid: '#(orgAId)', name: '#(orgAName)' }, roles: [ { role: 'vendor' } ] },
          { org: { orgsUuid: '#(orgCId)', name: '#(orgCName)' }, roles: [ { role: 'content_provider' } ] }
        ],
        items: [
          { resource: { id: '#(gokbPackage.packageId)' } },
          { resource: { id: '#(gokbPackage.pciId)' } },
          { type: 'detached', description: '#("Detached agreement line " + suffix)' }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement3)' }

    # 8. Create In Negotiation Agreement #4 With One Organization And One Agreement Line
    * def agreement4 =
      """
      {
        name: '#(agreement4Name)',
        agreementStatus: 'in_negotiation',
        isPerpetual: 'yes',
        periods: [ { startDate: '#(lastYearStart)', endDate: '#(nextYearNovemberEnd)' } ],
        orgs: [
          { org: { orgsUuid: '#(orgAId)', name: '#(orgAName)' }, roles: [ { role: 'content_provider' } ] }
        ],
        items: [
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#(ekbPackageReference)', resourceName: '#(ekbPackageName)', suppressFromDiscovery: true }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement4)' }

    # TestRail Case Steps
    # 9. Select "Agreements + Lines" Record Type
    # Include inaccessible entity types so a failure reports which permissions the user is missing
    Given path 'entity-types'
    And param includeInaccessible = true
    When method GET
    Then status 200
    * def agreementLinesSummary = karate.filter(response.entityTypes, function(entityType) { return entityType.id == agreementLinesEntityTypeId })
    And match agreementLinesSummary == '#[1]'
    And match agreementLinesSummary[0].missingPermissions == '##[0]'

    Given path 'entity-types', agreementLinesEntityTypeId
    When method GET
    Then status 200
    And match $.name == 'composite_agreement_with_lines'
    * def entityTypeColumns = $.columns
    * def visibleFields = karate.map(karate.filter(entityTypeColumns, function(column) { return !column.hidden }), function(column) { return column.name })
    # CSV headers use column labels in entity type order, with em/en dashes replaced by hyphens
    * def csvHeaderFor =
      """
      function(fields) {
        var labels = [];
        karate.forEach(entityTypeColumns, function(column) {
          if (fields.indexOf(column.name) >= 0) labels.push(column.labelAlias.replace(/[—–]/g, '-'));
        });
        return labels;
      }
      """

    # 10. Query Agreements By "Agreement — Name" Contains Prefix
    # Retry covers FQM installing the agreement source views on the first query
    * def nameContains = cond('agreement.sa_name', '$contains', agreementPrefix)
    * def nameOnlyQuery = fql([nameContains])
    Given path 'query'
    And params { entityTypeId: '#(agreementLinesEntityTypeId)', query: '#(nameOnlyQuery)', fields: '#(visibleFields)', limit: 100 }
    And retry until responseStatus == 200 && response.totalRecords == 24
    When method GET
    Then status 200
    * def allRows = $.content
    And match countsByAgreement(allRows) == [16, 1, 6, 1]

    # 11. Check All Columns And Verify Data For Each Agreement, Agreement Line, Period And Organization
    * def expectedColumns =
      """
      [
        'agreement.id', 'agreement.sa_name', 'agreement.sa_description', 'agreement.sa_start_date', 'agreement.sa_end_date',
        'agreement.sa_cancellation_deadline', 'agreement.sa_agreement_status_label', 'agreement.sa_renewal_priority_label',
        'agreement.sa_is_perpetual_label', 'agreement.sa_reason_for_closure_label',
        'period.id', 'period.per_start_date', 'period.per_end_date',
        'agreement_org.id', 'agreement_org.org_name', 'agreement_org.sao_roles',
        'agreement_line.id', 'agreement_line.ent_type', 'agreement_line.ent_authority', 'agreement_line.ent_reference',
        'agreement_line.ent_suppress_discovery', 'agreement_line.ent_active_from', 'agreement_line.ent_active_to', 'agreement_line.ent_res_name',
        'organization.id', 'organization.name', 'organization.code', 'organization.status', 'organization.is_vendor',
        'organization.is_donor', 'organization.tags', 'organization.edi_vendor_edi_code', 'organization.edi_vendor_edi_type'
      ]
      """
    * match visibleFields contains expectedColumns

    * def agreement1Rows = rowsFor(allRows, agreement1Name)
    * match agreementSummary(agreement1Rows) ==
      """
      {
        rows: 16,
        status: ['Active'],
        description: ['Active agreement description'],
        renewalPriority: ['Definitely cancel'],
        isPerpetual: ['No'],
        reasonForClosure: [],
        startDate: ['#(yearBeforeLastStart)'],
        endDate: ['#(nextYearEnd)'],
        cancellationDeadline: ['#(nextYearNovemberEnd)'],
        periodStartDates: ['#(yearBeforeLastStart)', '#(lastYearStart)', '#(currentYearStart)', '#(nextYearStart)'],
        periodEndDates: ['#(yearBeforeLastEnd)', '#(lastYearEnd)', '#(currentYearEnd)', '#(nextYearEnd)'],
        agreementOrgNames: ['#(orgAName)', '#(orgBName)'],
        organizationNames: ['#(orgAName)', '#(orgBName)'],
        organizationCodes: ['#(orgACode)', '#(orgBCode)'],
        lineTypes: ['external', 'internal']
      }
      """
    * match lineSummary(agreement1Rows, 'internal') == { rows: 8, authority: [], reference: [], resourceName: ['#(localPackageName)'], suppressFromDiscovery: ['true'], activeFrom: ['#(yearBeforeLastStart)'], activeTo: ['#(yearBeforeLastEnd)'] }
    * match lineSummary(agreement1Rows, 'external') == { rows: 8, authority: ['EKB-TITLE'], reference: ['#(ekbTitleReference)'], resourceName: ['#(ekbTitleName)'], suppressFromDiscovery: ['false'], activeFrom: ['#(nextMonthStart)'], activeTo: ['#(nextMonthEnd)'] }
    * match rolesFor(agreement1Rows, orgAName) == ['Content provider']
    * match rolesFor(agreement1Rows, orgBName) == ['Vendor']

    * match agreementSummary(rowsFor(allRows, agreement2Name)) ==
      """
      {
        rows: 1,
        status: ['Draft'],
        description: ['Draft agreement description'],
        renewalPriority: ['Definitely renew'],
        isPerpetual: [],
        reasonForClosure: [],
        startDate: ['#(nextYearStart)'],
        endDate: [],
        cancellationDeadline: [],
        periodStartDates: ['#(nextYearStart)'],
        periodEndDates: [],
        agreementOrgNames: [],
        organizationNames: [],
        organizationCodes: [],
        lineTypes: []
      }
      """

    * def agreement3Rows = rowsFor(allRows, agreement3Name)
    * match agreementSummary(agreement3Rows) ==
      """
      {
        rows: 6,
        status: ['Closed'],
        description: [],
        renewalPriority: [],
        isPerpetual: [],
        reasonForClosure: ['Rejected'],
        startDate: ['#(currentYearFebruaryStart)'],
        endDate: ['#(currentYearNovemberEnd)'],
        cancellationDeadline: ['#(currentYearNovemberEnd)'],
        periodStartDates: ['#(currentYearFebruaryStart)'],
        periodEndDates: ['#(currentYearNovemberEnd)'],
        agreementOrgNames: ['#(orgAName)', '#(orgCName)'],
        organizationNames: ['#(orgAName)', '#(orgCName)'],
        organizationCodes: ['#(orgACode)', '#(orgCCode)'],
        lineTypes: ['detached', 'internal']
      }
      """
    # The GOKb package line resolves to the package name, the package content item line to its title name
    * match lineSummary(agreement3Rows, 'internal') == { rows: 4, authority: [], reference: [], resourceName: ['#(gokbTitlePciName)', '#(gokbPackageName)'], suppressFromDiscovery: ['false'], activeFrom: [], activeTo: [] }
    * match lineSummary(agreement3Rows, 'detached') == { rows: 2, authority: [], reference: [], resourceName: [], suppressFromDiscovery: ['false'], activeFrom: [], activeTo: [] }
    * match rolesFor(agreement3Rows, orgAName) == ['Vendor']
    * match rolesFor(agreement3Rows, orgCName) == ['Content provider']

    * def agreement4Rows = rowsFor(allRows, agreement4Name)
    * match agreementSummary(agreement4Rows) ==
      """
      {
        rows: 1,
        status: ['In negotiation'],
        description: [],
        renewalPriority: [],
        isPerpetual: ['Yes'],
        reasonForClosure: [],
        startDate: ['#(lastYearStart)'],
        endDate: ['#(nextYearNovemberEnd)'],
        cancellationDeadline: [],
        periodStartDates: ['#(lastYearStart)'],
        periodEndDates: ['#(nextYearNovemberEnd)'],
        agreementOrgNames: ['#(orgAName)'],
        organizationNames: ['#(orgAName)'],
        organizationCodes: ['#(orgACode)'],
        lineTypes: ['external']
      }
      """
    * match lineSummary(agreement4Rows, 'external') == { rows: 1, authority: ['EKB-PACKAGE'], reference: ['#(ekbPackageReference)'], resourceName: ['#(ekbPackageName)'], suppressFromDiscovery: ['true'], activeFrom: [], activeTo: [] }
    * match rolesFor(agreement4Rows, orgAName) == ['Content provider']

    # 12. Add Filter By "Organization — Name" Equals Org A
    # The organization look-up selects an option, and the query is filtered by that option's value
    * def orgAOption = call getFieldValueId { entityTypeId: '#(agreementLinesEntityTypeId)', field: 'organization.name', label: '#(orgAName)' }
    * def orgAFilter = cond('organization.name', '$eq', orgAOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 12
    * match countsByAgreement(result.content) == [8, 0, 3, 1]

    # 13. Add Filters By "Agreement Period — Start Date" And "Agreement Period — End Date" For The Year Before Last
    * def periodStartFilter = cond('period.per_start_date', '$eq', yearBeforeLastStart)
    * def periodEndFilter = cond('period.per_end_date', '$eq', yearBeforeLastEnd)
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter, periodStartFilter, periodEndFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 2
    * match countsByAgreement(result.content) == [2, 0, 0, 0]

    # 14. Add Filter By "Agreement Line — Type" In Internal
    * def internalTypeFilter = cond('agreement_line.ent_type', '$in', ['internal'])
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter, periodStartFilter, periodEndFilter, internalTypeFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 1
    * match result.content[0]['agreement.sa_name'] == agreement1Name
    * match result.content[0]['agreement_line.ent_res_name'] == localPackageName

    # 15. Keep Only "Agreement — Name" And "Agreement Line — Type" In Internal Filters
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, internalTypeFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 12
    * match countsByAgreement(result.content) == [8, 0, 4, 0]

    # 16. Change "Agreement Line — Type" Filter To External
    * def externalTypeFilter = cond('agreement_line.ent_type', '$in', ['external'])
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, externalTypeFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 9
    * match countsByAgreement(result.content) == [8, 0, 0, 1]

    # 17. Add Filter By "Agreement — Start Date" Greater Than Or Equal To January 1st Of Last Year
    * def agreementStartFilter = cond('agreement.sa_start_date', '$gte', lastYearStart)
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, externalTypeFilter, agreementStartFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 1
    * match countsByAgreement(result.content) == [0, 0, 0, 1]

    # 18. Keep Only "Agreement — Name" Filter And Add "Agreement — Cancellation Deadline" Less Than December 31st Of Current Year
    * def cancellationDeadlineFilter = cond('agreement.sa_cancellation_deadline', '$lt', currentYearEnd)
    * def cancellationDeadlineQuery = fql([nameContains, cancellationDeadlineFilter])
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(cancellationDeadlineQuery)', fields: '#(visibleFields)' }
    * match result.totalRecords == 6
    * match countsByAgreement(result.content) == [0, 0, 6, 0]

    # 19. Run Query And Save The List
    * def listName = 'Agreements + Lines List ' + suffix
    * def listRequest = read('classpath:athena/mod-lists/features/samples/agreement-lines-list.json')
    * listRequest.name = listName
    * listRequest.description = listName
    * listRequest.fqlQuery = cancellationDeadlineQuery
    * listRequest.fields = visibleFields
    * def postCall = call postList
    * def listId = postCall.listId
    * call refreshList { listId: '#(listId)' }

    Given path 'lists', listId
    And retry until isRefreshed(response, 6)
    When method GET
    Then status 200
    And match $.fields contains only visibleFields

    Given path 'lists', listId, 'contents'
    And params { offset: 0, size: 100, fields: '#(visibleFields)' }
    When method GET
    Then status 200
    And match $.totalRecords == 6
    And match countsByAgreement(response.content) == [0, 0, 6, 0]

    # 20. Edit List Query: Keep Only "Agreement — Name" And Add "Agreement Line — Suppress From Discovery" Equals True
    * def suppressedFilter = cond('agreement_line.ent_suppress_discovery', '$eq', 'true')
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, suppressedFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 9
    * match countsByAgreement(result.content) == [8, 0, 0, 1]

    # 21. Add Filter By "Agreement Line — Active From" Greater Than Or Equal To January 1st Of The Year Before Last
    * def activeFromFilter = cond('agreement_line.ent_active_from', '$gte', yearBeforeLastStart)
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, suppressedFilter, activeFromFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 8
    * match countsByAgreement(result.content) == [8, 0, 0, 0]

    # 22. Keep Only "Agreement — Name" Filter And Add "Agreement Organization — Name" Equals Org C
    * def orgCOption = call getFieldValueId { entityTypeId: '#(agreementLinesEntityTypeId)', field: 'agreement_org.org_name', label: '#(orgCName)' }
    * def orgCAgreementOrgQuery = fql([nameContains, cond('agreement_org.org_name', '$eq', orgCOption.valueId)])
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(orgCAgreementOrgQuery)', fields: '#(visibleFields)' }
    * match result.totalRecords == 3
    * match countsByAgreement(result.content) == [0, 0, 3, 0]

    # 23. Uncheck Some Organization Columns, Run Query And Save The List
    * def uncheckedFields = ['organization.edi_vendor_edi_code', 'organization.edi_vendor_edi_type', 'organization.is_donor', 'organization.tags']
    * def selectedFields = karate.filter(visibleFields, function(field) { return uncheckedFields.indexOf(field) < 0 })
    Given path 'lists', listId
    When method GET
    Then status 200
    * def listUpdateRequest = { name: '#(listName)', description: '#(listName)', fqlQuery: '#(orgCAgreementOrgQuery)', fields: '#(selectedFields)', isActive: true, isPrivate: false, version: '#(response.version)' }
    * call updateList { listId: '#(listId)', listRequest: '#(listUpdateRequest)' }
    * call refreshList { listId: '#(listId)' }

    Given path 'lists', listId
    And retry until isRefreshed(response, 3)
    When method GET
    Then status 200
    And match $.fields contains only selectedFields

    Given path 'lists', listId, 'contents'
    And params { offset: 0, size: 100, fields: '#(selectedFields)' }
    When method GET
    Then status 200
    And match $.totalRecords == 3
    And match countsByAgreement(response.content) == [0, 0, 3, 0]

    # 24. Export Selected Columns (CSV)
    * def selectedExport = call exportExistingList { listId: '#(listId)', fields: '#(selectedFields)' }
    * match selectedExport.csvHeader == csvHeaderFor(selectedFields)
    * match selectedExport.csvRows == '#[3]'
    * match each selectedExport.csvRows contains agreement3Name
    * match each selectedExport.csvRows contains orgCName
    # The export API emits dates as stored (yyyy-MM-dd); the MM/DD/YYYY rendering the test case expects is applied by the UI
    * match each selectedExport.csvRows contains currentYearNovemberEnd

    # 25. Export All Columns (CSV)
    * def allColumnsExport = call exportExistingList { listId: '#(listId)', fields: '#(visibleFields)' }
    * match allColumnsExport.csvHeader == csvHeaderFor(visibleFields)
    * match allColumnsExport.csvRows == '#[3]'
    * match each allColumnsExport.csvRows contains agreement3Name
    * match each allColumnsExport.csvRows contains orgCCode

    # 26. Create A New List Query With "Agreement — Name" And "Agreement — Status" Equals Active
    * def activeStatusOption = call getFieldValueId { entityTypeId: '#(agreementLinesEntityTypeId)', field: 'agreement.sa_agreement_status_label', label: 'Active' }
    * def statusActiveFilter = cond('agreement.sa_agreement_status_label', '$eq', activeStatusOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, statusActiveFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 16
    * match countsByAgreement(result.content) == [16, 0, 0, 0]

    # 27. Change "Agreement — Status" Operator To Not Equal To
    * def statusNotActiveFilter = cond('agreement.sa_agreement_status_label', '$ne', activeStatusOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, statusNotActiveFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 8
    * match countsByAgreement(result.content) == [0, 1, 6, 1]

    # 28. Add Filter By "Agreement — Renewal Priority" In Definitely Renew
    * def definitelyRenewOption = call getFieldValueId { entityTypeId: '#(agreementLinesEntityTypeId)', field: 'agreement.sa_renewal_priority_label', label: 'Definitely renew' }
    * def renewalPriorityFilter = cond('agreement.sa_renewal_priority_label', '$in', [definitelyRenewOption.valueId])
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(fql([nameContains, statusNotActiveFilter, renewalPriorityFilter]))', fields: '#(visibleFields)' }
    * match result.totalRecords == 1
    * match countsByAgreement(result.content) == [0, 1, 0, 0]

    # 29. Change "Agreement — Renewal Priority" Operator To Is Null/Empty True
    * def emptyRenewalPriorityQuery = fql([nameContains, statusNotActiveFilter, cond('agreement.sa_renewal_priority_label', '$empty', true)])
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(emptyRenewalPriorityQuery)', fields: '#(visibleFields)' }
    * match result.totalRecords == 7
    * match countsByAgreement(result.content) == [0, 0, 6, 1]

    # 30. Run Query And Save The New List
    * def secondListName = 'Agreements + Lines Status List ' + suffix
    * def listRequest = read('classpath:athena/mod-lists/features/samples/agreement-lines-list.json')
    * listRequest.name = secondListName
    * listRequest.description = secondListName
    * listRequest.fqlQuery = emptyRenewalPriorityQuery
    * listRequest.fields = visibleFields
    * def postCall = call postList
    * def secondListId = postCall.listId
    * call refreshList { listId: '#(secondListId)' }

    Given path 'lists', secondListId
    And retry until isRefreshed(response, 7)
    When method GET
    Then status 200

    Given path 'lists', secondListId, 'contents'
    And params { offset: 0, size: 100, fields: '#(visibleFields)' }
    When method GET
    Then status 200
    And match $.totalRecords == 7
    And match countsByAgreement(response.content) == [0, 0, 6, 1]

    # 31. Edit List Query: Keep Only "Agreement — Name" Filter
    * def result = call runFqmQuery { entityTypeId: '#(agreementLinesEntityTypeId)', fqlQuery: '#(nameOnlyQuery)', fields: '#(visibleFields)' }
    * match result.totalRecords == 24
    * match countsByAgreement(result.content) == [16, 1, 6, 1]

    # 32. Run Query, Save The List And Export All Columns (CSV)
    Given path 'lists', secondListId
    When method GET
    Then status 200
    * def listUpdateRequest = { name: '#(secondListName)', description: '#(secondListName)', fqlQuery: '#(nameOnlyQuery)', fields: '#(visibleFields)', isActive: true, isPrivate: false, version: '#(response.version)' }
    * call updateList { listId: '#(secondListId)', listRequest: '#(listUpdateRequest)' }
    * call refreshList { listId: '#(secondListId)' }

    Given path 'lists', secondListId
    And retry until isRefreshed(response, 24)
    When method GET
    Then status 200

    Given path 'lists', secondListId, 'contents'
    And params { offset: 0, size: 100, fields: '#(visibleFields)' }
    When method GET
    Then status 200
    And match $.totalRecords == 24
    And match countsByAgreement(response.content) == [16, 1, 6, 1]

    * def fullExport = call exportExistingList { listId: '#(secondListId)', fields: '#(visibleFields)' }
    * match fullExport.csvHeader == csvHeaderFor(visibleFields)
    * match fullExport.csvRows == '#[24]'
    * match csvCountsByAgreement(fullExport.csvRows) == [16, 1, 6, 1]
