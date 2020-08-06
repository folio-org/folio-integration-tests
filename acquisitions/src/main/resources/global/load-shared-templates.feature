Feature: Load shared templates
  #--------!Important use in your feature only :
  # copy newInvoice =  $invoiceTemplate  - creates a clone
  Scenario: Load invoice templates
    * def percentageInvoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')