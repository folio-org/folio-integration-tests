Feature: EDIFACT orders export tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def nextZonedTimeAsLocaleSettings = read('util/get-next-time-function.js')
    * def currentDayOfWeek = read('util/get-day-of-week-function.js')

  Scenario: If there is an open order for organization and organization has integration method with the same acquisition method as order THEN export job should be triggered and be 'SUCCESSFUL' (ediSchedulePeriod = 'DAY')
    # Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-1'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-1'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Create an account, and set it to the organization
    * def extAccount = read('samples/account-for-organization.json')
    * def extAccountName = 'MODEXPS-202-OrgAccountName-1'
    * def extAccountNo = 'MODEXPS-202-OrgAccountNo-1'
    * extAccount.name = extAccountName
    * extAccount.accountNo = extAccountNo

    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount)] }

    # Create purchase order for the organization
    * def extOrderId =  call uuid1
    * def extPoNumber =  'PoNumber1'
    * call read('util/initData.feature@CreateOrderForOrganization') { extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extPoNumber: #(extPoNumber) }

    # Create PO Line for the order
    * def extPoLineId = call uuid1
    * call read('util/initData.feature@CreateOrderLines') { extPoLineId: #(extPoLineId), extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extAccountNumber: #(extAccountNo) }

    # Open the order
    * call read('util/initData.feature@OpenOrder') { extOrderId: #(extOrderId)}

    # Add integration to the organization
    * def extExportConfigId = call uuid1

    * def extEdiScheduleFrequency = 1
    * def extEdiSchedulePeriod = 'DAY'
    * def extEdiScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def extEdiScheduleTimeZone = 'UTC'
    * call read('util/initData.feature@AddIntegrationToOrganization') { extExportConfigId: #(extExportConfigId), extOrganizationId: #(extOrganizationId), extAccountNoList: [#(extAccountNo)], extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleTime: #(extEdiScheduleTime), extEdiScheduleTimeZone: #(extEdiScheduleTimeZone)}

    # Pause for a minute ('delay' = 1 minute)
    * call pause 65000

    # Verify that job run was successful
    * def dataExportSpringJobsByType = call read('util/initData.feature@GetDataExportSpringJobsByType')
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == extExportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 1
    * def job = jobs[0]
    And assert job.status == 'SUCCESSFUL'

  Scenario: If organization has integration method but there is no any open order for the organization THEN export job should be triggered and be 'FAILED' (ediSchedulePeriod = 'DAY')
    # Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-2'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-2'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Create an account, and set it to the organization
    * def extAccount = read('samples/account-for-organization.json')
    * def extAccountName = 'MODEXPS-202-OrgAccountName-2'
    * def extAccountNo = 'MODEXPS-202-OrgAccountNo-2'
    * extAccount.name = extAccountName
    * extAccount.accountNo = extAccountNo

    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount)] }

    # Add integration to the organization
    * def extExportConfigId = call uuid1

    * def extEdiScheduleFrequency = 1
    * def extEdiSchedulePeriod = 'DAY'
    * def extEdiScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def extEdiScheduleTimeZone = 'UTC'
    * call read('util/initData.feature@AddIntegrationToOrganization') { extExportConfigId: #(extExportConfigId), extOrganizationId: #(extOrganizationId), extAccountNoList: [#(extAccountNo)], extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleTime: #(extEdiScheduleTime), extEdiScheduleTimeZone: #(extEdiScheduleTimeZone)}

    # Pause for a minute ('delay' = 1 minute)
    * call pause 65000

    # Verify that job run was failed
    * def dataExportSpringJobsByType = call read('util/initData.feature@GetDataExportSpringJobsByType')
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == extExportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 1
    * def job = jobs[0]
    And assert job.status == 'FAILED'
    And assert job.errorDetails == 'Orders for export not found (OrderNotFoundException)'

  Scenario: If there is an open order for organization and organization has integration method with the same acquisition method as order THEN export job should be triggered and be 'SUCCESSFUL' (ediSchedulePeriod = 'WEEK')
    # Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-3'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-3'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Create an account, and set it to the organization
    * def extAccount = read('samples/account-for-organization.json')
    * def extAccountName = 'MODEXPS-202-OrgAccountName-3'
    * def extAccountNo = 'MODEXPS-202-OrgAccountNo-3'
    * extAccount.name = extAccountName
    * extAccount.accountNo = extAccountNo

    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount)] }

    # Create purchase order for the organization
    * def extOrderId =  call uuid1
    * def extPoNumber =  'PoNumber3'
    * call read('util/initData.feature@CreateOrderForOrganization') { extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extPoNumber: #(extPoNumber) }

    # Create PO Line for the order
    * def extPoLineId = call uuid1
    * call read('util/initData.feature@CreateOrderLines') { extPoLineId: #(extPoLineId), extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extAccountNumber: #(extAccountNo) }

    # Open the order
    * call read('util/initData.feature@OpenOrder') { extOrderId: #(extOrderId)}

    # Add integration to the organization
    * def extExportConfigId = call uuid1

    * def extEdiScheduleFrequency = 1
    * def extEdiSchedulePeriod = 'WEEK'
    * def extEdiScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def extEdiScheduleWeekDays = ['SATURDAY', 'FRIDAY', 'THURSDAY', 'WEDNESDAY', 'TUESDAY', 'MONDAY', 'SUNDAY']
    * def extEdiScheduleTimeZone = 'UTC'
    * call read('util/initData.feature@AddIntegrationToOrganization') { extExportConfigId: #(extExportConfigId), extOrganizationId: #(extOrganizationId), extAccountNoList: [#(extAccountNo)], extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleTime: #(extEdiScheduleTime), extEdiScheduleWeekDays: #(extEdiScheduleWeekDays), extEdiScheduleTimeZone: #(extEdiScheduleTimeZone)}

    # Pause for a minute ('delay' = 1 minute)
    * call pause 70000

    # Verify that job run was successful
    * def dataExportSpringJobsByType = call read('util/initData.feature@GetDataExportSpringJobsByType')
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == extExportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 1
    * def job = jobs[0]
    And assert job.status == 'SUCCESSFUL'

  Scenario: If organization has integration method but there is no any open order for the organization THEN export job should be triggered and be 'FAILED' (ediSchedulePeriod = 'WEEK')
    # Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-4'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-4'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Create an account, and set it to the organization
    * def extAccount = read('samples/account-for-organization.json')
    * def extAccountName = 'MODEXPS-202-OrgAccountName-4'
    * def extAccountNo = 'MODEXPS-202-OrgAccountNo-4'
    * extAccount.name = extAccountName
    * extAccount.accountNo = extAccountNo

    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount)] }

    # Add integration to the organization
    * def extExportConfigId = call uuid1

    * def extEdiScheduleFrequency = 1
    * def extEdiSchedulePeriod = 'WEEK'
    * def extEdiScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def extEdiScheduleWeekDays = ['SATURDAY', 'FRIDAY', 'THURSDAY', 'WEDNESDAY', 'TUESDAY', 'MONDAY', 'SUNDAY']
    * def extEdiScheduleTimeZone = 'UTC'
    * call read('util/initData.feature@AddIntegrationToOrganization') { extExportConfigId: #(extExportConfigId), extOrganizationId: #(extOrganizationId), extAccountNoList: [#(extAccountNo)], extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleTime: #(extEdiScheduleTime), extEdiScheduleWeekDays: #(extEdiScheduleWeekDays), extEdiScheduleTimeZone: #(extEdiScheduleTimeZone)}

    # Pause for a minute ('delay' = 1 minute)
    * call pause 70000

    # Verify that job run was failed
    * def dataExportSpringJobsByType = call read('util/initData.feature@GetDataExportSpringJobsByType')
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == extExportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 1
    * def job = jobs[0]
    And assert job.status == 'FAILED'
    And assert job.errorDetails == 'Orders for export not found (OrderNotFoundException)'

  Scenario: If there is an open order for organization and organization has integration method with the same acquisition method as order but not for (today) current day of the week THEN there should not be a job for today (ediSchedulePeriod = 'WEEK')
    # Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-5'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-5'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Create an account, and set it to the organization
    * def extAccount = read('samples/account-for-organization.json')
    * def extAccountName = 'MODEXPS-202-OrgAccountName-5'
    * def extAccountNo = 'MODEXPS-202-OrgAccountNo-5'
    * extAccount.name = extAccountName
    * extAccount.accountNo = extAccountNo

    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount)] }

    # Create purchase order for the organization
    * def extOrderId =  call uuid1
    * def extPoNumber =  'PoNumber5'
    * call read('util/initData.feature@CreateOrderForOrganization') { extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extPoNumber: #(extPoNumber) }

    # Create PO Line for the order
    * def extPoLineId = call uuid1
    * call read('util/initData.feature@CreateOrderLines') { extPoLineId: #(extPoLineId), extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extAccountNumber: #(extAccountNo) }

    # Open the order
    * call read('util/initData.feature@OpenOrder') { extOrderId: #(extOrderId)}

    # Add integration to the organization
    * def extExportConfigId = call uuid1

    * def currentDay = currentDayOfWeek('UTC')

    * def extEdiScheduleFrequency = 1
    * def extEdiSchedulePeriod = 'WEEK'
    * def extEdiScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def extEdiScheduleWeekDays = karate.filter(['SATURDAY', 'FRIDAY', 'THURSDAY', 'WEDNESDAY', 'TUESDAY', 'MONDAY', 'SUNDAY'], (day) => day != currentDay)
    * def extEdiScheduleTimeZone = 'UTC'
    * call read('util/initData.feature@AddIntegrationToOrganization') { extExportConfigId: #(extExportConfigId), extOrganizationId: #(extOrganizationId), extAccountNoList: [#(extAccountNo)], extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleTime: #(extEdiScheduleTime), extEdiScheduleWeekDays: #(extEdiScheduleWeekDays), extEdiScheduleTimeZone: #(extEdiScheduleTimeZone)}

    # Pause for a minute ('delay' = 1 minute)
    * call pause 70000

    # Verify that job run was successful
    * def dataExportSpringJobsByType = call read('util/initData.feature@GetDataExportSpringJobsByType')
    * def fun = function(job) {return job.isSystemSource && job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == extExportConfigId}
    * def jobs = karate.filter(dataExportSpringJobsByType.response.jobRecords, fun)

    And assert karate.sizeOf(jobs) == 0