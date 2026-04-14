@ignore
Feature: Create invoice line
  # parameters: invoiceLineId, invoiceId, total, fundDistributions?, fundId?, fundCode?, poLineId?, encumbranceId?, expenseClassId?,
  # releaseEncumbrance?, adjustments?, tags?, description?
  # fundDistributions should not be used at the same time as fundId, fundCode, encumbranceId or expenseClassId

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create invoice line
    * def invoiceLine = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundDistributions = karate.get('fundDistributions', null)
    * def fundId = karate.get('fundId', globalFundId)
    * def fundCode = karate.get('fundCode', fundId)
    * def poLineId = karate.get('poLineId', null)
    * def encumbranceId = karate.get('encumbranceId', null)
    * def expenseClassId = karate.get('expenseClassId', null)
    * def releaseEncumbrance = karate.get('releaseEncumbrance', true)
    * def adjustments = karate.get('adjustments', [])
    * def tags = karate.get('tags', null)
    * def description = karate.get('description', invoiceLine.description)

    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.fundDistributions[0].code = fundCode
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.fundDistributions[0].expenseClassId = expenseClassId
    * if (fundDistributions != null) invoiceLine.fundDistributions = fundDistributions
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.total = total
    * set invoiceLine.subTotal = total
    * set invoiceLine.releaseEncumbrance = releaseEncumbrance
    * set invoiceLine.adjustments = adjustments
    * set invoiceLine.tags = tags
    * set invoiceLine.description = description

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201
