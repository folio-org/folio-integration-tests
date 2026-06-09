# For FAT-21136, https://foliotest.testrail.io/index.php?/cases/view/350543
Feature: Verify, if Saved flag "automaticExport" in the POL supports EDIFACT orders export

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 12, interval: 5000 }

    * def expCreateOrg = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@CreateOrganization')
    * def expSetupOrgAcc = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@SetAccountToOrganization')
    * def expCreateOrgOrder = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@CreateOrderForOrganization')
    * def expCreateOrderLines = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@CreateOrderLines')
    * def expOpenOrder = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@OpenOrder')
    * def expAddOrgIntegration = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@AddIntegrationToOrganization')
    * def expGetJobs = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@GetDataExportSpringJobsByType')


  @C350543
  @Positive
  Scenario: PO line with automaticExport=true triggers EDIFACT orders export at scheduled WEEK time including today's day

    #========================================================================================================
    # Preconditions
    #========================================================================================================

    # 1. Create an organization
    * def organizationId = call uuid1
    * def organizationName = 'OrgName-C350543'
    * def organizationCode = 'OrgCode-C350543'
    * call expCreateOrg { extOrganizationId: #(organizationId), extOrganizationName: #(organizationName), extOrganizationCode: #(organizationCode) }

    # 2. Create an Active account and attach it to the organization
    * def account = read('classpath:thunderjet/mod-data-export-spring/features/samples/account-for-organization.json')
    * def accountName = 'OrgAccountName-C350543'
    * def accountNo = 'OrgAccountNo-C350543'
    * account.name = accountName
    * account.accountNo = accountNo

    * call expSetupOrgAcc { extOrganizationId: #(organizationId), extAccounts: [#(account)] }

    # 3. Create a One-time order in Pending status for the vendor (Manual option = disabled is the default)
    * def orderId = call uuid1
    * def poNumber = 'PoNumberC350543'
    * call expCreateOrgOrder { extOrderId: #(orderId), extOrganizationId: #(organizationId), extPoNumber: #(poNumber) }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 4. Add a PO line with acquisitionMethod=Purchase, automaticExport=true (saved flag under test), valid vendor account number
    * def poLineId = call uuid1
    * call expCreateOrderLines { extPoLineId: #(poLineId), extOrderId: #(orderId), extOrganizationId: #(organizationId), extAccountNumber: #(accountNo) }

    # 5. Open the order
    * call expOpenOrder { extOrderId: #(orderId)}

    # Pause if necessary so the integration scheduleTime lands on a clean minute boundary
    * call pause waitIfNecessary('UTC')

    # 6. Add integration to the organization: Ordering type, Purchase acquisition method, FTP, WEEKLY schedule with today's day included, scheduleTime = current time + 1 min
    * def exportConfigId = call uuid1

    * def ediScheduleFrequency = 1
    * def ediSchedulePeriod = 'WEEK'
    * def ediScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def ediScheduleWeekDays = ['SATURDAY', 'FRIDAY', 'THURSDAY', 'WEDNESDAY', 'TUESDAY', 'MONDAY', 'SUNDAY']
    * def ediScheduleTimeZone = 'UTC'
    * call expAddOrgIntegration { extExportConfigId: #(exportConfigId), extOrganizationId: #(organizationId), extAccountNoList: [#(accountNo)], extEdiScheduleFrequency: #(ediScheduleFrequency), extEdiSchedulePeriod: #(ediSchedulePeriod), extEdiScheduleTime: #(ediScheduleTime), extEdiScheduleWeekDays: #(ediScheduleWeekDays), extEdiScheduleTimeZone: #(ediScheduleTimeZone)}

    # Pause 70 seconds so the scheduled export executes
    * call pause 70000

    # 7. Search created job - verify it was successfully ran and a file was exported
    * def dataExportSpringJobsByType = call expGetJobs
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == exportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 1
    * def job = jobs[0]
    And retry until job.status == 'SUCCESSFUL'

    # 8. Download the EDI file and verify it contains expected EDIFACT order segments (UNH/UNB header for ORDERS message + UNT/UNZ trailers)
    Given path 'data-export-spring/jobs', job.id, 'download'
    When method GET
    Then status 200
    And string actualEdiFile = response
    And match actualEdiFile contains 'UNB+UNOC'
    And match actualEdiFile contains 'BGM+220'
    And match actualEdiFile contains 'UNZ+1'

