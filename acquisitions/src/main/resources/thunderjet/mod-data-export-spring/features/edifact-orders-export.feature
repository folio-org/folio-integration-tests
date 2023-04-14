Feature: EDIFACT orders export tests

  Background:
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Template test for MODEXPS-202
    # Step 1. Create an organization
    * def extOrganizationId = call uuid1
    * def extOrganizationName = 'MODEXPS-202-OrgName-1.1'
    * def extOrganizationCode = 'MODEXPS-202-OrgCode-1.1'
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(extOrganizationId), extOrganizationName: #(extOrganizationName), extOrganizationCode: #(extOrganizationCode) }

    # Step 2. Create two accounts
    * def extAccount1 = read('samples/account-for-organization.json')
    * extAccount1.name = 'MODEXPS-202-OrgAccountName-1.1'
    * extAccount1.accountNo = 'MODEXPS-202-OrgAccountNo-1.1'

    * def extAccount2 = read('samples/account-for-organization.json')
    * extAccount2.name = 'MODEXPS-202-OrgAccountName-1.2'
    * extAccount2.accountNo = 'MODEXPS-202-OrgAccountNo-1.2'

    # Step 3. Set created accounts to the organization
    * call read('util/initData.feature@SetAccountToOrganization') { extOrganizationId: #(extOrganizationId), extAccounts: [#(extAccount1), #(extAccount2)] }

#    # Step 4. Add integration to the organization for 'extAccount1' (Acquisition method = 'Purchase')
#    * def extEdiScheduleFrequency = 1
#    * def extEdiSchedulePeriod = 'DAY'
#    * def extEdiScheduleDate = '2023-04-13T10:53Z'
#    * def extEdiScheduleTime = '10:53:00'
#    * call read('classpath:thunderjet/mod-data-export-spring/features/util/initData.feature@AddIntegrationToOrganization') { extOrganizationId: #(extOrganizationId), extAccountNo: #(extAccount1), extEdiScheduleFrequency: #(extEdiScheduleFrequency), extEdiSchedulePeriod: #(extEdiSchedulePeriod), extEdiScheduleDate: #(extEdiScheduleDate), extEdiScheduleTime: #(extEdiScheduleTime)}

    # Step 5. Create purchase order for the organization
    * def extOrderId =  call uuid1
    * def extPoNumber =  'PoNumber1'
    * call read('util/initData.feature@CreateOrderForOrganization') { extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId), extPoNumber: #(extPoNumber) }

    # Step 6. Create PO Line for the order with 'PO line details.Acquisition method = 'Purchase'' (as in Step 4)
    * def extPoLineId = call uuid1
    * call read('util/initData.feature@CreateOrderLines') { extPoLineId: #(extPoLineId), extOrderId: #(extOrderId), extOrganizationId: #(extOrganizationId) }

#    # Step 7. Open created order
#    * call read('util/initData.feature@OpenOrder') { extOrderId: #(extOrderId)}

    # Step 8. Pause a minute ---

    # Step 9. Verify the result ---