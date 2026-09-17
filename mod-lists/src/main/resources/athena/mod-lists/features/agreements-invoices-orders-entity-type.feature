# For FAT-27653, https://foliotest.testrail.io/index.php?/cases/view/1373047
Feature: Agreements - Invoices - Orders Entity Type Displays Agreement, Lines, PO Lines And Invoice Lines

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * configure retry = { count: 30, interval: 5000 }
    * def agreementsInvoicesOrdersEntityTypeId = 'a1e1b9b8-1f9f-4a01-b8c7-2c8a8a000011'

    * def createOrganization = read('classpath:athena/mod-lists/features/util/create-organization.feature')
    * def ensureOrgRole = read('classpath:athena/mod-lists/features/util/erm/ensure-org-role.feature')
    * def createAgreement = read('classpath:athena/mod-lists/features/util/erm/create-agreement.feature')
    * def createFiscalYear = read('classpath:athena/mod-lists/features/util/acq/create-fiscal-year.feature')
    * def createLedger = read('classpath:athena/mod-lists/features/util/acq/create-ledger.feature')
    * def createFund = read('classpath:athena/mod-lists/features/util/acq/create-fund.feature')
    * def createExpenseClass = read('classpath:athena/mod-lists/features/util/acq/create-expense-class.feature')
    * def createBudget = read('classpath:athena/mod-lists/features/util/acq/create-budget.feature')
    * def createBatchGroup = read('classpath:athena/mod-lists/features/util/acq/create-batch-group.feature')
    * def createOrder = read('classpath:athena/mod-lists/features/util/acq/create-order.feature')
    * def createOrderLine = read('classpath:athena/mod-lists/features/util/acq/create-order-line.feature')
    * def createInvoice = read('classpath:athena/mod-lists/features/util/acq/create-invoice.feature')
    * def createInvoiceLine = read('classpath:athena/mod-lists/features/util/acq/create-invoice-line.feature')
    * def runFqmQuery = read('classpath:athena/mod-lists/features/util/run-fqm-query.feature')
    * def getFieldValueId = read('classpath:athena/mod-lists/features/util/get-field-value-id.feature')
    * def exportExistingList = read('classpath:athena/mod-lists/features/util/export-existing-list.feature')

    # Dates Relative To The Current Year
    * def LocalDate = Java.type('java.time.LocalDate')
    * def currentYear = LocalDate.now().getYear()
    * def lastYear = currentYear - 1
    * def dateOf = function(year, month, day) { return LocalDate.of(year, month, day).toString() + '' }
    * def lastYearStart = dateOf(lastYear, 1, 1)
    * def lastYearEnd = dateOf(lastYear, 12, 31)
    * def currentYearStart = dateOf(currentYear, 1, 1)
    * def currentYearEnd = dateOf(currentYear, 12, 31)

    # Field Names Of The Two Composite Parts
    * def AW = 'agreement_with_lines.'
    * def OI = 'order_invoice.'
    * def agreementNameField = AW + 'agreement.sa_name'
    * def resourceNameField = AW + 'agreement_line.ent_res_name'
    * def organizationNameField = AW + 'organization.name'
    * def periodEndDateField = AW + 'period.per_end_date'
    * def poNumberField = OI + 'po.po_number'
    * def poLineTitleField = OI + 'pol.title_or_package'
    * def poLineFundCodeField = OI + 'pol.fund_distribution[*]->code'
    * def vendorInvoiceNoField = OI + 'invoice.vendor_invoice_no'
    * def invoiceVendorNameField = OI + 'invoice.vendor_name'
    * def invoiceFiscalYearField = OI + 'invoice.fiscal_year'
    * def invoiceFundNameField = OI + 'fund.name'
    * def invoiceFundCodeField = OI + 'fund.code'
    * def invoiceExpenseClassField = OI + 'expense_class.name'
    # Columns Checked In "Show Columns" And Requested From Queries; Requesting All Columns Would Exceed URL Limits
    * def selectedFields =
      """
      [
        'agreement_with_lines.agreement.id', 'agreement_with_lines.agreement.sa_name', 'agreement_with_lines.agreement.sa_agreement_status_label',
        'agreement_with_lines.period.per_start_date', 'agreement_with_lines.period.per_end_date', 'agreement_with_lines.organization.name',
        'agreement_with_lines.agreement_line.id', 'agreement_with_lines.agreement_line.ent_type', 'agreement_with_lines.agreement_line.ent_res_name',
        'order_invoice.po.po_number', 'order_invoice.po.workflow_status', 'order_invoice.po.order_type',
        'order_invoice.pol.po_line_number', 'order_invoice.pol.title_or_package',
        'order_invoice.invoice.vendor_invoice_no', 'order_invoice.invoice.vendor_name', 'order_invoice.invoice.fiscal_year',
        'order_invoice.fund.name', 'order_invoice.fund.code', 'order_invoice.expense_class.name'
      ]
      """

    # FQL Builders
    * def cond = function(field, operator, value) { return '{"' + field + '":{"' + operator + '":' + JSON.stringify(value) + '}}' }
    * def fql = function(conditions) { return '{"$and":[' + conditions.join(',') + ']}' }

    # Result Helpers
    * def rowsWhere = function(rows, field, value) { return karate.filter(rows, function(row) { return row[field] == value }) }
    # Field names are stored in variables, and match cannot resolve a variable inside brackets on its left side
    * def fieldValue = function(row, field) { return row[field] }
    * def countsByAgreement = function(rows) { return karate.map(agreementNames, function(name) { return rowsWhere(rows, agreementNameField, name).length }) }
    * def countsByAgreement1Line = function(rows) { return karate.map(agreement1LineNames, function(name) { return rowsWhere(rows, resourceNameField, name).length }) }
    * def distinct =
      """
      function(rows, field) {
        var values = [];
        karate.forEach(rows, function(row) {
          var value = row[field];
          if (value != null && values.indexOf('' + value) < 0) values.push('' + value);
        });
        return values;
      }
      """
    * def isRefreshed = function(list, recordsCount) { return list.inProgressRefresh == null && list.successRefresh != null && list.successRefresh.recordsCount == recordsCount }

  @C1373047
  @Positive
  Scenario: Agreements - Invoices - Orders ET Correctly Displays Agreement, Lines, PO Lines And Invoice Lines
    # Generate Unique Identifiers And Names For This Test Scenario
    * def suffix = randomMillis()
    * def suffixLetters = suffix.substring(suffix.length - 6).replace(/\d/g, function(digit) { return 'ABCDEFGHIJ'.charAt(parseInt(digit)) })
    * def agreementPrefix = 'Agr' + suffix
    * def agreement1Name = agreementPrefix + ' #1'
    * def agreement2Name = agreementPrefix + ' #2'
    * def agreement3Name = agreementPrefix + ' #3'
    * def agreement4Name = agreementPrefix + ' #4'
    * def agreement5Name = agreementPrefix + ' #5'
    * def agreementNames = ['#(agreement1Name)', '#(agreement2Name)', '#(agreement3Name)', '#(agreement4Name)', '#(agreement5Name)']
    * def agr1Line1Name = 'eHoldings Package Agr1 Line1 ' + suffix
    * def agr1Line2Name = 'eHoldings Package Agr1 Line2 ' + suffix
    * def agr1Line3Name = 'eHoldings Package Agr1 Line3 ' + suffix
    * def agreement1LineNames = ['#(agr1Line1Name)', '#(agr1Line2Name)', '#(agr1Line3Name)']
    * def agr2Line1Name = 'eHoldings Package Agr2 Line1 ' + suffix
    * def agr2Line2Name = 'eHoldings Package Agr2 Line2 ' + suffix
    * def agr3Line1Name = 'eHoldings Package Agr3 Line1 ' + suffix
    * def agr4Line1Name = 'eHoldings Package Agr4 Line1 ' + suffix
    * def agr5Line1Name = 'eHoldings Package Agr5 Line1 ' + suffix
    * def orgAId = call uuid
    * def orgBId = call uuid
    * def orgCId = call uuid
    * def orgAName = 'Org A ' + suffix
    * def orgBName = 'Org B ' + suffix
    * def orgCName = 'Org C ' + suffix
    * def previousFiscalYearId = call uuid
    * def currentFiscalYearId = call uuid
    * def previousFiscalYearCode = 'AIO' + suffixLetters + lastYear
    * def currentFiscalYearCode = 'AIO' + suffixLetters + currentYear
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def fundACode = 'FUNDA' + suffix
    * def fundBCode = 'FUNDB' + suffix
    * def fundAName = 'Fund A ' + suffix
    * def fundBName = 'Fund B ' + suffix
    * def electronicClassId = call uuid
    * def printClassId = call uuid
    * def electronicClassName = 'Electronic ' + suffix
    * def printClassName = 'Print ' + suffix
    * def batchGroupId = call uuid
    * def order1Id = call uuid
    * def order2Id = call uuid
    * def order3Id = call uuid
    * def order4Id = call uuid
    * def po1Number = 'AIO' + suffix + '1'
    * def po2Number = 'AIO' + suffix + '2'
    * def po3Number = 'AIO' + suffix + '3'
    * def po4Number = 'AIO' + suffix + '4'
    * def o1Line1Id = call uuid
    * def o1Line2Id = call uuid
    * def o1Line3Id = call uuid
    * def o2Line1Id = call uuid
    * def o2Line2Id = call uuid
    * def o3Line1Id = call uuid
    * def o4Line1Id = call uuid
    * def o1Line1Title = 'Order 1 Line 1 ' + suffix
    * def o1Line2Title = 'Order 1 Line 2 ' + suffix
    * def o1Line3Title = 'Order 1 Line 3 ' + suffix
    * def o2Line1Title = 'Order 2 Line 1 ' + suffix
    * def o2Line2Title = 'Order 2 Line 2 ' + suffix
    * def o3Line1Title = 'Order 3 Line 1 ' + suffix
    * def o4Line1Title = 'Order 4 Line 1 ' + suffix
    * def invoice1Id = call uuid
    * def invoice2Id = call uuid
    * def invoice3Id = call uuid
    * def invoice4Id = call uuid
    * def invoice1No = 'INV1-' + suffix
    * def invoice2No = 'INV2-' + suffix
    * def invoice3No = 'INV3-' + suffix
    * def invoice4No = 'INV4-' + suffix

    # Fund Distributions Shared By PO Lines And Their Invoice Lines
    * def fundAElectronicHalf = { fundId: '#(fundAId)', code: '#(fundACode)', expenseClassId: '#(electronicClassId)', distributionType: 'percentage', value: 50 }
    * def fundAPrintHalf = { fundId: '#(fundAId)', code: '#(fundACode)', expenseClassId: '#(printClassId)', distributionType: 'percentage', value: 50 }
    * def fundAElectronicFull = { fundId: '#(fundAId)', code: '#(fundACode)', expenseClassId: '#(electronicClassId)', distributionType: 'percentage', value: 100 }
    * def fundBHalf = { fundId: '#(fundBId)', code: '#(fundBCode)', distributionType: 'percentage', value: 50 }
    * def fundBFull = { fundId: '#(fundBId)', code: '#(fundBCode)', distributionType: 'percentage', value: 100 }

    # 1. Install FQM Entity Types So Those Depending On mod-agreements Are Available
    Given path 'entity-types', 'install'
    When method POST
    Then status 204

    # 2. Ensure "Vendor" Role Exists In "SubscriptionAgreementOrg.Role" Pick List
    * def v = call ensureOrgRole { roleLabel: 'Vendor', roleValue: 'vendor' }

    # 3. Create Organizations A, B And C
    * def v = call createOrganization { id: '#(orgAId)', name: '#(orgAName)', code: '#("ORGA" + suffix)' }
    * def v = call createOrganization { id: '#(orgBId)', name: '#(orgBName)', code: '#("ORGB" + suffix)' }
    * def v = call createOrganization { id: '#(orgCId)', name: '#(orgCName)', code: '#("ORGC" + suffix)' }

    # 4. Create Previous And Current Fiscal Years
    * def v = call createFiscalYear { id: '#(previousFiscalYearId)', code: '#(previousFiscalYearCode)', periodStart: '#(lastYearStart + "T00:00:00Z")', periodEnd: '#(lastYearEnd + "T23:59:59Z")' }
    * def v = call createFiscalYear { id: '#(currentFiscalYearId)', code: '#(currentFiscalYearCode)', periodStart: '#(currentYearStart + "T00:00:00Z")', periodEnd: '#(currentYearEnd + "T23:59:59Z")' }

    # 5. Create Active Ledger A And "Electronic" And "Print" Expense Classes
    * def v = call createLedger { id: '#(ledgerId)', code: '#("LEDGERA" + suffix)', fiscalYearId: '#(previousFiscalYearId)' }
    * def v = call createExpenseClass { id: '#(electronicClassId)', name: '#(electronicClassName)', code: '#("ELEC" + suffix)' }
    * def v = call createExpenseClass { id: '#(printClassId)', name: '#(printClassName)', code: '#("PRNT" + suffix)' }

    # 6. Create Funds A And B With Previous And Current Budgets, Fund A Budgets Having Both Expense Classes
    * def v = call createFund { id: '#(fundAId)', code: '#(fundACode)', name: '#(fundAName)', ledgerId: '#(ledgerId)' }
    * def v = call createFund { id: '#(fundBId)', code: '#(fundBCode)', name: '#(fundBName)', ledgerId: '#(ledgerId)' }
    * def expenseClassIds = ['#(electronicClassId)', '#(printClassId)']
    * def v = call createBudget { id: '#(uuid())', fundId: '#(fundAId)', fiscalYearId: '#(previousFiscalYearId)', expenseClassIds: '#(expenseClassIds)' }
    * def v = call createBudget { id: '#(uuid())', fundId: '#(fundAId)', fiscalYearId: '#(currentFiscalYearId)', expenseClassIds: '#(expenseClassIds)' }
    * def v = call createBudget { id: '#(uuid())', fundId: '#(fundBId)', fiscalYearId: '#(previousFiscalYearId)' }
    * def v = call createBudget { id: '#(uuid())', fundId: '#(fundBId)', fiscalYearId: '#(currentFiscalYearId)' }

    # 7. Create Ongoing Open Order #1 For Org A With Three PO Lines
    * def v = call createOrder { id: '#(order1Id)', poNumber: '#(po1Number)', vendorId: '#(orgAId)' }
    * def fd = ['#(fundAElectronicHalf)', '#(fundAPrintHalf)']
    * def v = call createOrderLine { id: '#(o1Line1Id)', orderId: '#(order1Id)', poLineNumber: '#(po1Number + "-1")', title: '#(o1Line1Title)', fundDistribution: '#(fd)' }
    * def fd = ['#(fundAElectronicFull)']
    * def v = call createOrderLine { id: '#(o1Line2Id)', orderId: '#(order1Id)', poLineNumber: '#(po1Number + "-2")', title: '#(o1Line2Title)', fundDistribution: '#(fd)' }
    * def fd = ['#(fundBFull)']
    * def v = call createOrderLine { id: '#(o1Line3Id)', orderId: '#(order1Id)', poLineNumber: '#(po1Number + "-3")', title: '#(o1Line3Title)', fundDistribution: '#(fd)' }

    # 8. Create Ongoing Open Order #2 For Org B With Two PO Lines
    * def v = call createOrder { id: '#(order2Id)', poNumber: '#(po2Number)', vendorId: '#(orgBId)' }
    * def fd = ['#(fundAElectronicFull)']
    * def v = call createOrderLine { id: '#(o2Line1Id)', orderId: '#(order2Id)', poLineNumber: '#(po2Number + "-1")', title: '#(o2Line1Title)', fundDistribution: '#(fd)' }
    * def fd = ['#(fundBFull)']
    * def v = call createOrderLine { id: '#(o2Line2Id)', orderId: '#(order2Id)', poLineNumber: '#(po2Number + "-2")', title: '#(o2Line2Title)', fundDistribution: '#(fd)' }

    # 9. Create Ongoing Open Order #3 For Org A With One PO Line Distributed To Fund A And Fund B
    * def v = call createOrder { id: '#(order3Id)', poNumber: '#(po3Number)', vendorId: '#(orgAId)' }
    * def fd = ['#(fundAElectronicHalf)', '#(fundBHalf)']
    * def v = call createOrderLine { id: '#(o3Line1Id)', orderId: '#(order3Id)', poLineNumber: '#(po3Number + "-1")', title: '#(o3Line1Title)', fundDistribution: '#(fd)' }

    # 10. Create Ongoing Open Order #4 For Org A With One PO Line Distributed To Fund B
    * def v = call createOrder { id: '#(order4Id)', poNumber: '#(po4Number)', vendorId: '#(orgAId)' }
    * def fd = ['#(fundBFull)']
    * def v = call createOrderLine { id: '#(o4Line1Id)', orderId: '#(order4Id)', poLineNumber: '#(po4Number + "-1")', title: '#(o4Line1Title)', fundDistribution: '#(fd)' }

    # 11. Create Open Invoice #1 For Order #1 In Previous Fiscal Year
    # The ET has a row per invoice line fund distribution, so invoice lines copy the PO line fund distributions
    * def v = call createBatchGroup { id: '#(batchGroupId)', name: '#("Batch Group " + suffix)' }
    * def poNumbers = ['#(po1Number)']
    * def v = call createInvoice { id: '#(invoice1Id)', vendorId: '#(orgAId)', vendorInvoiceNo: '#(invoice1No)', fiscalYearId: '#(previousFiscalYearId)', batchGroupId: '#(batchGroupId)', poNumbers: '#(poNumbers)' }
    * def fd = ['#(fundAElectronicHalf)', '#(fundAPrintHalf)']
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice1Id)', poLineId: '#(o1Line1Id)', fundDistributions: '#(fd)', total: 10 }
    * def fd = ['#(fundAElectronicFull)']
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice1Id)', poLineId: '#(o1Line2Id)', fundDistributions: '#(fd)', total: 10 }
    * def fd = ['#(fundBFull)']
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice1Id)', poLineId: '#(o1Line3Id)', fundDistributions: '#(fd)', total: 10 }

    # 12. Create Open Invoice #2 For PO Line #3 Of Order #1 In Current Fiscal Year
    * def v = call createInvoice { id: '#(invoice2Id)', vendorId: '#(orgAId)', vendorInvoiceNo: '#(invoice2No)', fiscalYearId: '#(currentFiscalYearId)', batchGroupId: '#(batchGroupId)', poNumbers: '#(poNumbers)' }
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice2Id)', poLineId: '#(o1Line3Id)', fundDistributions: '#(fd)', total: 10 }

    # 13. Create Open Invoice #3 For Order #2 In Current Fiscal Year
    * def poNumbers = ['#(po2Number)']
    * def v = call createInvoice { id: '#(invoice3Id)', vendorId: '#(orgBId)', vendorInvoiceNo: '#(invoice3No)', fiscalYearId: '#(currentFiscalYearId)', batchGroupId: '#(batchGroupId)', poNumbers: '#(poNumbers)' }
    * def fd = ['#(fundAElectronicFull)']
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice3Id)', poLineId: '#(o2Line1Id)', fundDistributions: '#(fd)', total: 10 }
    * def fd = ['#(fundBFull)']
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice3Id)', poLineId: '#(o2Line2Id)', fundDistributions: '#(fd)', total: 10 }

    # 14. Create Open Invoice #4 For Order #4 With Org C As Vendor In Current Fiscal Year
    * def poNumbers = ['#(po4Number)']
    * def v = call createInvoice { id: '#(invoice4Id)', vendorId: '#(orgCId)', vendorInvoiceNo: '#(invoice4No)', fiscalYearId: '#(currentFiscalYearId)', batchGroupId: '#(batchGroupId)', poNumbers: '#(poNumbers)' }
    * def v = call createInvoiceLine { id: '#(uuid())', invoiceId: '#(invoice4Id)', poLineId: '#(o4Line1Id)', fundDistributions: '#(fd)', total: 10 }

    # 15. Create Agreement #1 With Two Periods, Orgs A And B And Three Lines Linked To Order #1 PO Lines
    # eHoldings is not enabled for this tenant, so eHoldings packages are external agreement lines
    * def agreement1 =
      """
      {
        name: '#(agreement1Name)',
        agreementStatus: 'active',
        periods: [
          { startDate: '#(lastYearStart)', endDate: '#(lastYearEnd)' },
          { startDate: '#(currentYearStart)', endDate: '#(currentYearEnd)' }
        ],
        orgs: [
          { org: { orgsUuid: '#(orgAId)', name: '#(orgAName)' }, roles: [ { role: 'vendor' } ] },
          { org: { orgsUuid: '#(orgBId)', name: '#(orgBName)' }, roles: [ { role: 'vendor' } ] }
        ],
        items: [
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "1")', resourceName: '#(agr1Line1Name)', poLines: [ { poLineId: '#(o1Line1Id)' } ] },
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "2")', resourceName: '#(agr1Line2Name)', poLines: [ { poLineId: '#(o1Line2Id)' } ] },
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "3")', resourceName: '#(agr1Line3Name)', poLines: [ { poLineId: '#(o1Line3Id)' } ] }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement1)' }

    # 16. Create Agreement #2 For Org B With One Line Linked To Order #2 PO Line #1 And One Unlinked Line
    * def agreement2 =
      """
      {
        name: '#(agreement2Name)',
        agreementStatus: 'active',
        periods: [ { startDate: '#(currentYearStart)' } ],
        orgs: [ { org: { orgsUuid: '#(orgBId)', name: '#(orgBName)' }, roles: [ { role: 'vendor' } ] } ],
        items: [
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "4")', resourceName: '#(agr2Line1Name)', poLines: [ { poLineId: '#(o2Line1Id)' } ] },
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "5")', resourceName: '#(agr2Line2Name)' }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement2)' }

    # 17. Create Agreement #3 For Org B With One Line Linked To Both Order #2 PO Lines
    * def agreement3 =
      """
      {
        name: '#(agreement3Name)',
        agreementStatus: 'active',
        periods: [ { startDate: '#(currentYearStart)' } ],
        orgs: [ { org: { orgsUuid: '#(orgBId)', name: '#(orgBName)' }, roles: [ { role: 'vendor' } ] } ],
        items: [
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "6")', resourceName: '#(agr3Line1Name)', poLines: [ { poLineId: '#(o2Line1Id)' }, { poLineId: '#(o2Line2Id)' } ] }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement3)' }

    # 18. Create Agreement #4 Without Organizations With One Line Linked To Order #3 PO Line
    * def agreement4 =
      """
      {
        name: '#(agreement4Name)',
        agreementStatus: 'active',
        periods: [ { startDate: '#(currentYearStart)' } ],
        items: [
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "7")', resourceName: '#(agr4Line1Name)', poLines: [ { poLineId: '#(o3Line1Id)' } ] }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement4)' }

    # 19. Create Agreement #5 For Org A With One Line Linked To Order #4 PO Line
    * def agreement5 =
      """
      {
        name: '#(agreement5Name)',
        agreementStatus: 'active',
        periods: [ { startDate: '#(currentYearStart)' } ],
        orgs: [ { org: { orgsUuid: '#(orgAId)', name: '#(orgAName)' }, roles: [ { role: 'vendor' } ] } ],
        items: [
          { type: 'external', authority: 'EKB-PACKAGE', reference: '#("19-" + suffix + "8")', resourceName: '#(agr5Line1Name)', poLines: [ { poLineId: '#(o4Line1Id)' } ] }
        ]
      }
      """
    * def v = call createAgreement { agreement: '#(agreement5)' }

    # TestRail Case Steps
    # 20. Select "Agreements - Invoices - Orders" Record Type
    # Include inaccessible entity types so a failure reports which permissions the user is missing
    Given path 'entity-types'
    And param includeInaccessible = true
    When method GET
    Then status 200
    * def entityTypeSummary = karate.filter(response.entityTypes, function(entityType) { return entityType.id == agreementsInvoicesOrdersEntityTypeId })
    And match entityTypeSummary == '#[1]'
    And match entityTypeSummary[0].missingPermissions == '##[0]'

    Given path 'entity-types', agreementsInvoicesOrdersEntityTypeId
    When method GET
    Then status 200
    And match $.name == 'composite_agreement_with_lines_and_order_invoice_analytics'
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

    # 21. Query By "Agreements + Lines — Agreement — Name" Contains Prefix
    # Retry covers FQM installing the agreement and acquisitions source views on the first query
    * def nameContains = cond(agreementNameField, '$contains', agreementPrefix)
    Given path 'query'
    And params { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', query: '#(fql([nameContains]))', fields: '#(selectedFields)', limit: 100 }
    And retry until responseStatus == 200 && response.totalRecords == 26
    When method GET
    Then status 200
    * def allRows = $.content
    And match countsByAgreement(allRows) == [20, 2, 2, 1, 1]
    And match countsByAgreement1Line(allRows) == [8, 4, 8]

    # 22. Check Columns Related To Preconditions And Verify Data In The Preview
    * match visibleFields contains selectedFields
    * match distinct(allRows, OI + 'po.workflow_status') == ['Open']
    * match distinct(allRows, OI + 'po.order_type') == ['Ongoing']

    * def agreement1Rows = rowsWhere(allRows, agreementNameField, agreement1Name)
    * match distinct(agreement1Rows, organizationNameField) contains only ['#(orgAName)', '#(orgBName)']
    * match distinct(agreement1Rows, periodEndDateField) contains only ['#(lastYearEnd)', '#(currentYearEnd)']
    * match distinct(agreement1Rows, poNumberField) == ['#(po1Number)']
    * match distinct(agreement1Rows, vendorInvoiceNoField) contains only ['#(invoice1No)', '#(invoice2No)']
    * match distinct(agreement1Rows, invoiceVendorNameField) == ['#(orgAName)']
    * match distinct(agreement1Rows, invoiceFiscalYearField) contains only ['#(previousFiscalYearCode)', '#(currentFiscalYearCode)']
    * match distinct(agreement1Rows, invoiceFundCodeField) contains only ['#(fundACode)', '#(fundBCode)']
    * def agr1Line1Rows = rowsWhere(allRows, resourceNameField, agr1Line1Name)
    * match distinct(agr1Line1Rows, poLineTitleField) == ['#(o1Line1Title)']
    * match distinct(agr1Line1Rows, invoiceExpenseClassField) contains only ['#(electronicClassName)', '#(printClassName)']
    * match distinct(rowsWhere(allRows, resourceNameField, agr1Line3Name), poLineTitleField) == ['#(o1Line3Title)']
    # Agr #2 - Agreement Line #2 Not Linked To Any PO Line Has Blank Order And Invoice Fields
    * def agr2Line2Rows = rowsWhere(allRows, resourceNameField, agr2Line2Name)
    * match agr2Line2Rows == '#[1]'
    * match fieldValue(agr2Line2Rows[0], organizationNameField) == orgBName
    * match fieldValue(agr2Line2Rows[0], poLineTitleField) == '##null'
    * match fieldValue(agr2Line2Rows[0], vendorInvoiceNoField) == '##null'
    * def agr2Line1Rows = rowsWhere(allRows, resourceNameField, agr2Line1Name)
    * match agr2Line1Rows == '#[1]'
    * match fieldValue(agr2Line1Rows[0], poLineTitleField) == o2Line1Title
    * match fieldValue(agr2Line1Rows[0], vendorInvoiceNoField) == invoice3No

    # Agr #3 - Agreement Line #1 Linked To Two PO Lines Has A Separate Row For Each
    * def agreement3Rows = rowsWhere(allRows, agreementNameField, agreement3Name)
    * match distinct(agreement3Rows, poLineTitleField) contains only ['#(o2Line1Title)', '#(o2Line2Title)']
    * match distinct(agreement3Rows, vendorInvoiceNoField) == ['#(invoice3No)']
    * match distinct(agreement3Rows, invoiceFundCodeField) contains only ['#(fundACode)', '#(fundBCode)']
    # Agr #4 - Agreement Line #1 Linked To A PO Line Without Invoices Has Blank Invoice Fields
    * def agreement4Rows = rowsWhere(allRows, agreementNameField, agreement4Name)
    * match fieldValue(agreement4Rows[0], organizationNameField) == '##null'
    * match fieldValue(agreement4Rows[0], poNumberField) == po3Number
    * match fieldValue(agreement4Rows[0], poLineTitleField) == o3Line1Title
    * match fieldValue(agreement4Rows[0], vendorInvoiceNoField) == '##null'
    * match fieldValue(agreement4Rows[0], invoiceFundCodeField) == '##null'

    # Agr #5 - Invoice Vendor Differs From The Order Vendor
    * def agreement5Rows = rowsWhere(allRows, agreementNameField, agreement5Name)
    * match fieldValue(agreement5Rows[0], organizationNameField) == orgAName
    * match fieldValue(agreement5Rows[0], poNumberField) == po4Number
    * match fieldValue(agreement5Rows[0], vendorInvoiceNoField) == invoice4No
    * match fieldValue(agreement5Rows[0], invoiceVendorNameField) == orgCName
    * match fieldValue(agreement5Rows[0], invoiceFundCodeField) == fundBCode

    # 23. Add Filter By "Agreements + Lines — Organization — Name" Equals Org A
    # Look-up fields are filtered by the selected option's value (id), like in the query builder
    * def orgAOption = call getFieldValueId { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', field: '#(organizationNameField)', label: '#(orgAName)' }
    * def orgAFilter = cond(organizationNameField, '$eq', orgAOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 11
    * match countsByAgreement(result.content) == [10, 0, 0, 0, 1]
    * match countsByAgreement1Line(result.content) == [4, 2, 4]

    # 24. Add Filter By "Order — Invoice Analysis — Invoice — Fiscal Year" Equals Previous Fiscal Year
    * def previousFiscalYearOption = call getFieldValueId { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', field: '#(invoiceFiscalYearField)', label: '#(previousFiscalYearCode)' }
    * def previousFiscalYearFilter = cond(invoiceFiscalYearField, '$eq', previousFiscalYearOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter, previousFiscalYearFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 8
    * match countsByAgreement(result.content) == [8, 0, 0, 0, 0]
    * match countsByAgreement1Line(result.content) == [4, 2, 2]

    # 25. Add Filter By "Order — Invoice Analysis — PO Line — Fund Distribution — Code" Equals Fund B
    * def poLineFundBFilter = cond(poLineFundCodeField, '$eq', fundBCode)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter, previousFiscalYearFilter, poLineFundBFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 2
    * match countsByAgreement(result.content) == [2, 0, 0, 0, 0]
    * match countsByAgreement1Line(result.content) == [0, 0, 2]

    # 26. Add Filter By "Agreements + Lines — Agreement Period — End Date" Equals December 31st Of Last Year
    * def periodEndFilter = cond(periodEndDateField, '$eq', lastYearEnd)
    * def savedQuery = fql([nameContains, orgAFilter, previousFiscalYearFilter, poLineFundBFilter, periodEndFilter])
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(savedQuery)', fields: '#(selectedFields)' }
    * match result.totalRecords == 1
    * match countsByAgreement1Line(result.content) == [0, 0, 1]

    # 27. Run Query And Save The List
    * def listName = 'Agreements - Invoices - Orders List ' + suffix
    * def listRequest = read('classpath:athena/mod-lists/features/samples/agreements-invoices-orders-list.json')
    * listRequest.name = listName
    * listRequest.description = listName
    * listRequest.fqlQuery = savedQuery
    * listRequest.fields = selectedFields
    * def postCall = call postList
    * def listId = postCall.listId
    * call refreshList { listId: '#(listId)' }

    Given path 'lists', listId
    And retry until isRefreshed(response, 1)
    When method GET
    Then status 200
    And match $.fields contains only selectedFields

    Given path 'lists', listId, 'contents'
    And params { offset: 0, size: 100, fields: '#(selectedFields)' }
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match fieldValue(response.content[0], resourceNameField) == agr1Line3Name
    And match fieldValue(response.content[0], vendorInvoiceNoField) == invoice1No

    # 28. Export Selected Columns (CSV)
    * def selectedExport = call exportExistingList { listId: '#(listId)', fields: '#(selectedFields)' }
    * match selectedExport.csvHeader == csvHeaderFor(selectedFields)
    * match selectedExport.csvRows == '#[1]'
    * match selectedExport.csvRows[0] contains agreement1Name
    * match selectedExport.csvRows[0] contains agr1Line3Name
    * match selectedExport.csvRows[0] contains invoice1No
    * match selectedExport.csvRows[0] contains previousFiscalYearCode

    # 29. Export All Columns (CSV)
    * def allColumnsExport = call exportExistingList { listId: '#(listId)', fields: '#(visibleFields)' }
    * match allColumnsExport.csvHeader == csvHeaderFor(visibleFields)
    * match allColumnsExport.csvRows == '#[1]'
    * match allColumnsExport.csvRows[0] contains agreement1Name
    * match allColumnsExport.csvRows[0] contains o1Line3Title
    * match allColumnsExport.csvRows[0] contains fundBCode

    # 30. Edit List Query: Keep "Agreement — Name" And "Organization — Name" Filters, Add "Invoice — Vendor Name" Equals Org C
    * def orgCVendorOption = call getFieldValueId { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', field: '#(invoiceVendorNameField)', label: '#(orgCName)' }
    * def orgCVendorFilter = cond(invoiceVendorNameField, '$eq', orgCVendorOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameContains, orgAFilter, orgCVendorFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 1
    * match countsByAgreement(result.content) == [0, 0, 0, 0, 1]

    # 31. Keep Only "Agreement — Name" Filter And Add "Invoice — Vendor Invoice Number" Equals Invoice #3 Number
    * def invoice3Filter = cond(vendorInvoiceNoField, '$eq', invoice3No)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameContains, invoice3Filter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 3
    * match countsByAgreement(result.content) == [0, 1, 2, 0, 0]

    # 32. Add Filter By "Order — Invoice Analysis — Fund — Name" Equals Fund A
    * def fundANameFilter = cond(invoiceFundNameField, '$eq', fundAName)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameContains, invoice3Filter, fundANameFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 2
    * match countsByAgreement(result.content) == [0, 1, 1, 0, 0]
    * def agreement3FundARows = rowsWhere(result.content, agreementNameField, agreement3Name)
    * match fieldValue(agreement3FundARows[0], poLineTitleField) == o2Line1Title

    # 33. Remove All Filters And Add "Agreement Line — Resource Name" Equals Agr #1 Line #1 Package Name
    * def line1ResourceFilter = cond(resourceNameField, '$eq', agr1Line1Name)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([line1ResourceFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 8
    * match countsByAgreement1Line(result.content) == [8, 0, 0]

    # 34. Add Filter By "Agreements + Lines — Organization — Name" Equals Org B
    * def orgBOption = call getFieldValueId { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', field: '#(organizationNameField)', label: '#(orgBName)' }
    * def orgBFilter = cond(organizationNameField, '$eq', orgBOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([line1ResourceFilter, orgBFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 4
    * match countsByAgreement1Line(result.content) == [4, 0, 0]

    # 35. Remove All Filters, Add "Agreement — Name" Starts With Prefix And "Fund — Code" Equals Fund A
    * def nameStartsWith = cond(agreementNameField, '$starts_with', agreementPrefix)
    * def fundACodeFilter = cond(invoiceFundCodeField, '$eq', fundACode)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameStartsWith, fundACodeFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 14
    * match countsByAgreement(result.content) == [12, 1, 1, 0, 0]
    * match countsByAgreement1Line(result.content) == [8, 4, 0]

    # 36. Keep Only "Agreement — Name" Filter And Add "Invoice — Vendor Name" Equals Org A
    * def orgAVendorOption = call getFieldValueId { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', field: '#(invoiceVendorNameField)', label: '#(orgAName)' }
    * def orgAVendorFilter = cond(invoiceVendorNameField, '$eq', orgAVendorOption.valueId)
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(fql([nameStartsWith, orgAVendorFilter]))', fields: '#(selectedFields)' }
    * match result.totalRecords == 20
    * match countsByAgreement(result.content) == [20, 0, 0, 0, 0]
    * match countsByAgreement1Line(result.content) == [8, 4, 8]

    # 37. Change "Invoice — Vendor Name" Operator To In Org A And Org B
    * def orgBVendorOption = call getFieldValueId { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', field: '#(invoiceVendorNameField)', label: '#(orgBName)' }
    * def vendorIds = ['#(orgAVendorOption.valueId)', '#(orgBVendorOption.valueId)']
    * def orgsABVendorQuery = fql([nameStartsWith, cond(invoiceVendorNameField, '$in', vendorIds)])
    * def result = call runFqmQuery { entityTypeId: '#(agreementsInvoicesOrdersEntityTypeId)', fqlQuery: '#(orgsABVendorQuery)', fields: '#(selectedFields)' }
    * match result.totalRecords == 23
    * match countsByAgreement(result.content) == [20, 1, 2, 0, 0]

    # 38. Run Query And Save The Edited List
    Given path 'lists', listId
    When method GET
    Then status 200
    * def listUpdateRequest = { name: '#(listName)', description: '#(listName)', fqlQuery: '#(orgsABVendorQuery)', fields: '#(selectedFields)', isActive: true, isPrivate: false, version: '#(response.version)' }
    * call updateList { listId: '#(listId)', listRequest: '#(listUpdateRequest)' }
    * call refreshList { listId: '#(listId)' }

    Given path 'lists', listId
    And retry until isRefreshed(response, 23)
    When method GET
    Then status 200
    And match $.fields contains only selectedFields

    Given path 'lists', listId, 'contents'
    And params { offset: 0, size: 100, fields: '#(selectedFields)' }
    When method GET
    Then status 200
    And match $.totalRecords == 23
    And match countsByAgreement(response.content) == [20, 1, 2, 0, 0]
