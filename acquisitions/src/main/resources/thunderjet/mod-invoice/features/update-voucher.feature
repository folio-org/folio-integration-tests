@parallel=false
Feature: Update voucher

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def invoiceId = callonce uuid1
    * def invoiceLineId = callonce uuid2

    * def getVoucherByInvoiceId = read('classpath:thunderjet/mod-invoice/reusable/get-voucher-by-invoice-id.feature')

  Scenario: Approve an invoice so that a voucher is generated
    # a voucher is never posted directly - it is generated when an invoice is approved
    * def v = call createInvoice { id: '#(invoiceId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', total: 10 }
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    * def v = call getVoucherByInvoiceId { invoiceId: '#(invoiceId)' }
    * match v.voucher.invoiceId == invoiceId
    * match v.voucher.status == 'Awaiting payment'

  Scenario: Editable fields can be updated on the voucher
    * def v = call getVoucherByInvoiceId { invoiceId: '#(invoiceId)' }
    * def voucher = v.voucher
    * def originalVoucherNumber = voucher.voucherNumber

    * set voucher.disbursementNumber = 'EFT546789'
    * set voucher.disbursementDate = '2024-05-05T00:00:00.000+0000'
    * set voucher.disbursementAmount = 250.0
    * set voucher.voucherNumber = '999001'

    Given path 'voucher/vouchers', voucher.id
    And request voucher
    When method PUT
    Then status 204

    Given path 'voucher/vouchers', voucher.id
    When method GET
    Then status 200
    And match response.disbursementNumber == 'EFT546789'
    And match response.disbursementAmount == 250.0
    And match response.disbursementDate contains '2024-05-05'
    And match response.voucherNumber == '999001'
    And match response.voucherNumber != originalVoucherNumber
    # fields the caller did not touch must survive the update
    And match response.invoiceId == invoiceId
    And match response.status == 'Awaiting payment'

  Scenario: Protected voucher fields cannot be changed
    * def v = call getVoucherByInvoiceId { invoiceId: '#(invoiceId)' }
    * def voucher = v.voucher
    * set voucher.status = 'Paid'

    Given path 'voucher/vouchers', voucher.id
    And request voucher
    When method PUT
    Then status 400
    * def error = $.errors[0]
    And match error.code == 'protectedFieldChanging'
    And match (error.protectedAndModifiedFields) contains any ['status']
