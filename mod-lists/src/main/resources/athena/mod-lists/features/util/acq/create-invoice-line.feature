Feature: Create open invoice line in storage
  # parameters: id, invoiceId, poLineId, fundDistributions, total
  Background:
    * url baseUrl

  Scenario: Create open invoice line
    * def invoiceLine =
      """
      {
        id: '#(id)',
        invoiceId: '#(invoiceId)',
        poLineId: '#(poLineId)',
        description: 'Invoice line',
        invoiceLineStatus: 'Open',
        quantity: 1,
        subTotal: '#(total)',
        total: '#(total)',
        releaseEncumbrance: false,
        fundDistributions: '#(fundDistributions)'
      }
      """
    Given path 'invoice-storage/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201
