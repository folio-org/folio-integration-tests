Feature: EDIFACT orders export tests

  Background:
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def nextZonedTimeAsLocaleSettings = read('util/get-next-time-function.js')

  Scenario: Template test for MODEXPS-202
    # Step 1. Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-1.1'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-1.1'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Step 2. Create two accounts, and set them to the organization
    * def extAccount1 = read('samples/account-for-organization.json')
    * def extAccountName1 = 'MODEXPS-202-OrgAccountName-1.1'
    * def extAccountNo1 = 'MODEXPS-202-OrgAccountNo-1.1'
    * extAccount1.name = extAccountName1
    * extAccount1.accountNo = extAccountNo1

    * def extAccount2 = read('samples/account-for-organization.json')
    * def extAccountName2 = 'MODEXPS-202-OrgAccountName-1.2'
    * def extAccountNo2 = 'MODEXPS-202-OrgAccountNo-1.2'
    * extAccount2.name = extAccountName2
    * extAccount2.accountNo = extAccountNo2

    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount1), #(extAccount2)] }

    # Step 3. Create purchase order for the organization
    * def extOrderId =  call uuid1
    * def extPoNumber =  'PoNumber1'
    * call read('util/initData.feature@CreateOrderForOrganization') { extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extPoNumber: #(extPoNumber) }

    # Step 4. Create PO Line for the order (with 'PO line details.Acquisition method = 'Purchase'' (as in Step 6))
    * def extPoLineId = call uuid1
    * call read('util/initData.feature@CreateOrderLines') { extPoLineId: #(extPoLineId), extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extAccountNumber: #(extAccountNo1) }

    # Step 5. Open the order
    * call read('util/initData.feature@OpenOrder') { extOrderId: #(extOrderId)}

    # Step 6. Add integration to the organization for 'extAccount1' (Acquisition method = 'Purchase' (as in Step 4))
    * def extExportConfigId = call uuid1

    # configure 'EdiSchedule'
#    * def localeSettings = call read('util/initData.feature@GetLocaleSettings')
#    * def timeZone = localeSettings.value.timezone

    * def extEdiScheduleFrequency = 1
    * def extEdiSchedulePeriod = 'DAY'
    * def extEdiScheduleTime = nextZonedTimeAsLocaleSettings('UTC', 1)
    * def extEdiScheduleTimeZone = 'UTC'
    * call read('util/initData.feature@AddIntegrationToOrganization') { extExportConfigId: #(extExportConfigId), extOrganizationId: #(extOrganizationId), extAccountNoList: [#(extAccountNo1), #(extAccountNo2)], extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleTime: #(extEdiScheduleTime), extEdiScheduleTimeZone: #(extEdiScheduleTimeZone)}

    # Step 7. Pause for a minute
    * call pause 60000

    # Step 8. Verify that order has been exported successfully