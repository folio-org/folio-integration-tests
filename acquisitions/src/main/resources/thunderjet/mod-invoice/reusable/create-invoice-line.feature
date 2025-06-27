@ignore
Feature: Create invoice line
  # parameters: invoiceLineId, invoiceId, poLineId?, fundId, encumbranceId?, total, expenseClassId?, releaseEncumbrance?, adjustments?

  Background:
    * url baseUrl

  Scenario: createInvoiceLine
    * def poLineId = karate.get('poLineId', null)
    * def encumbranceId = karate.get('encumbranceId', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def releaseEncumbrance = karate.get('releaseEncumbrance', true)
    * def adjustments = karate.get('adjustments', [])
    * def invoiceLine = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')
    * def fundCode = karate.get('fundCode', invoiceLine.fundDistributions[0].code)

    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.fundDistributions[0].code = fundCode
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.total = total
    * set invoiceLine.subTotal = total
    * set invoiceLine.fundDistributions[0].expenseClassId = expenseClassId
    * set invoiceLine.releaseEncumbrance = releaseEncumbrance
    * set invoiceLine.adjustments = adjustments
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201
