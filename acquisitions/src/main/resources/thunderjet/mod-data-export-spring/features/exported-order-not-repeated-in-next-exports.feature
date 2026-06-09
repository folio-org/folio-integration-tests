# For FAT-21138, https://foliotest.testrail.io/index.php?/cases/view/358971
Feature: Already exported order is not included repeatedly in next exports AND title special characters are escaped in EDI

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
    * def expUpdateOrgIntegration = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@UpdateIntegrationOfOrganization')
    * def expGetJobs = read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@GetDataExportSpringJobsByType')


  @C358971
  @Positive
  Scenario: Already exported order is not included repeatedly in next exports AND title special characters are escaped in EDI (ediSchedulePeriod = 'DAY')

    #========================================================================================================
    # Preconditions
    #========================================================================================================

    # 1. Create an organization (vendor)
    * def organizationId = call uuid1
    * def organizationName = 'OrgName-6'
    * def organizationCode = 'OrgCode-6'
    * call expCreateOrg { extOrganizationId: #(organizationId), extOrganizationName: #(organizationName), extOrganizationCode: #(organizationCode) }

    # 2. Create an active account, and set it to the organization
    * def account = read('classpath:thunderjet/mod-data-export-spring/features/samples/account-for-organization.json')
    * def accountName = 'OrgAccountName-6'
    * def accountNo = 'OrgAccountNo-6'
    * account.name = accountName
    * account.accountNo = accountNo

    * call expSetupOrgAcc { extOrganizationId: #(organizationId), extAccounts: [#(account)] }

    # 3. Create purchase order for the organization
    * def orderId = call uuid1
    * def poNumber = 'PoNumber6'
    * call expCreateOrgOrder { extOrderId: #(orderId), extOrganizationId: #(organizationId), extPoNumber: #(poNumber) }

    # 4. Create PO Line for the order with title containing single quote, question mark and colon (Purchase acquisition method + automatic export are already defaults in the sample)
    * def poLineId = call uuid1
    * def titleOrPackage = "Test's example: title?"
    * call expCreateOrderLines { extPoLineId: #(poLineId), extOrderId: #(orderId), extOrganizationId: #(organizationId), extAccountNumber: #(accountNo), extTitleOrPackage: #(titleOrPackage) }

    # 5. Open the order
    * call expOpenOrder { extOrderId: #(orderId)}

    # Pause if necessary
    * call pause waitIfNecessary('UTC')

    # 6. Add integration to the organization (1st scheduled export)
    * def exportConfigId = call uuid1

    * def ediScheduleFrequency = 1
    * def ediSchedulePeriod = 'DAY'
    * def ediScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def ediScheduleTimeZone = 'UTC'
    * call expAddOrgIntegration { extExportConfigId: #(exportConfigId), extOrganizationId: #(organizationId), extAccountNoList: [#(accountNo)], extEdiScheduleFrequency: #(ediScheduleFrequency), extEdiSchedulePeriod: #(ediSchedulePeriod), extEdiScheduleTime: #(ediScheduleTime), extEdiScheduleTimeZone: #(ediScheduleTimeZone)}

    # Pause for a minute ('delay' = 1 minute) so the first scheduled run executes - this represents "Preconditions item #4 (One order export was performed after opening order)"
    * call pause 65000

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================
    
    # 7. Locate the last successful export job for the integration
    * def dataExportSpringJobsByType = call expGetJobs
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == exportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 1
    * def firstJob = jobs[0]
    And retry until firstJob.status == 'SUCCESSFUL'

    # 8. Download exported .edi file and verify title section escapes '?', single-quote, ':' with leading '?' (UN/EDIFACT release character)
    Given path 'data-export-spring/jobs', firstJob.id, 'download'
    When method GET
    Then status 200
    And string actualEdiFile = response
    And match actualEdiFile contains "IMD+L+050+:::Test?'s example?: title??'"

    # 9. "Rerun" - re-schedule the same export config to fire again
    * call pause waitIfNecessary('UTC')
    * def ediScheduleTimeRerun = nextZonedTimeAsLocaleSettings('UTC', 1)
    * call expUpdateOrgIntegration { extExportConfigId: #(exportConfigId), extEdiScheduleTime: #(ediScheduleTimeRerun) }

    # Pause for a minute so the second scheduled run executes
    * call pause 65000

    # 10. Verify rerun job has FAILED status because the already-exported order is NOT included again, and "Entities not found: PurchaseOrder" error is reported
    * def dataExportSpringJobsAfterRerun = call expGetJobs
    * def allJobs = karate.filter(dataExportSpringJobsAfterRerun.response.jobRecords, fun)

    And assert karate.sizeOf(allJobs) == 2
    * def sortedJobs = karate.sort(allJobs, function(j){ return j.metadata.createdDate })
    * def lastIndex = karate.sizeOf(sortedJobs) - 1
    * def rerunJob = sortedJobs[lastIndex]
    And retry until rerunJob.status == 'FAILED'
    And retry until rerunJob.errorDetails == 'Entities not found: PurchaseOrder (NotFoundException)'
