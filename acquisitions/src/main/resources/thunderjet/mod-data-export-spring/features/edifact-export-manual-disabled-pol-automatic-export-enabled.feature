# For https://foliotest.testrail.io/index.php?/cases/view/350401
Feature: Order With Manual Disabled And POL Automatic Export Enabled Triggers EDIFACT Export

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 12, interval: 5000 }

    * call read('classpath:thunderjet/mod-data-export-spring/features/util/initHelpers.feature')

    * def expCreateOrg = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@CreateOrganization')
    * def expSetupOrgAcc = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@SetAccountToOrganization')
    * def expCreateOrgOrder = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@CreateOrderForOrganization')
    * def expCreateOrderLines = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@CreateOrderLines')
    * def expOpenOrder = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@OpenOrder')
    * def expAddOrgIntegration = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@AddIntegrationToOrganization')
    * def expGetJobs = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@GetDataExportSpringJobsByType')


  @C350401
  @Positive
  Scenario: Order With Manual Disabled And POL Automatic Export Enabled Triggers EDIFACT Export

    #========================================================================================================
    # Preconditions
    #========================================================================================================

    # 1. Create An Organization
    * def organizationId = call uuid1
    * def organizationName = 'OrgName-C350401'
    * def organizationCode = 'OrgCode-C350401'
    * call expCreateOrg { extOrganizationId: #(organizationId), extOrganizationName: #(organizationName), extOrganizationCode: #(organizationCode) }

    # 2. Create An Active Account And Attach It To The Organization
    * def account = read('classpath:thunderjet/mod-data-export-spring/features/samples/account-for-organization.json')
    * def accountName = 'OrgAccountName-C350401'
    * def accountNo = 'OrgAccountNo-C350401'
    * account.name = accountName
    * account.accountNo = accountNo
    * call expSetupOrgAcc { extOrganizationId: #(organizationId), extAccounts: [#(account)] }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 3. Create A One-Time Order With Manual Option Disabled (manual = false, which is the default)
    * def orderId = call uuid1
    * def poNumber = 'PoNumberC350401'
    * call expCreateOrgOrder { extOrderId: #(orderId), extOrganizationId: #(organizationId), extPoNumber: #(poNumber) }

    # 4. Add A PO Line With acquisitionMethod=Purchase And automaticExport=true
    * def poLineId = call uuid1
    * call expCreateOrderLines { extPoLineId: #(poLineId), extOrderId: #(orderId), extOrganizationId: #(organizationId), extAccountNumber: #(accountNo) }

    # 5. Open The Order
    * call expOpenOrder { extOrderId: #(orderId) }

    # Pause if necessary so the integration scheduleTime lands on a clean minute boundary
    * call pause waitIfNecessary('UTC')

    # 6. Add Integration To The Organization: Ordering Type, Purchase Acquisition Method, DAILY Schedule
    * def exportConfigId = call uuid1
    * def ediScheduleFrequency = 1
    * def ediSchedulePeriod = 'DAY'
    * def ediScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def ediScheduleTimeZone = 'UTC'
    * call expAddOrgIntegration { extExportConfigId: #(exportConfigId), extOrganizationId: #(organizationId), extAccountNoList: [#(accountNo)], extEdiScheduleFrequency: #(ediScheduleFrequency), extEdiSchedulePeriod: #(ediSchedulePeriod), extEdiScheduleTime: #(ediScheduleTime), extEdiScheduleTimeZone: #(ediScheduleTimeZone) }

    # Pause 70 seconds so the scheduled export executes
    * call pause 70000

    # 7. Verify The Export Job Was Triggered And Completed Successfully
    * def dataExportSpringJobsByType = call expGetJobs
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == exportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)
    And assert karate.sizeOf(jobs) == 1
    * def job = jobs[0]
    Given path 'data-export-spring/jobs', job.id
    And retry until response.status == 'SUCCESSFUL'
    When method GET
    Then status 200

    # 8. Download The EDI File And Verify It Contains The Order Details
    Given path 'data-export-spring/jobs', job.id, 'download'
    When method GET
    Then status 200
    And string actualEdiFile = response
    And match actualEdiFile contains 'UNB+UNOC'
    And match actualEdiFile contains 'BGM+220'
    And match actualEdiFile contains 'UNZ+1'

