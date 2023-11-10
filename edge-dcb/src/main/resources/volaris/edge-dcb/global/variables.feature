Feature: global variables

  @GlobalVariables
  Scenario: use global variables

    * def dcbTransactionId = '97654'
    * def holdingsRecordId = 'c1bddff4-0648-4013-9f1c-d30989ea2859'
    * def permanentLoanTypeId = '2b94c631-fca9-4892-a730-03ee529ffe27'
    * def materialTypeId = '1a54b431-2e4f-452d-9cae-9cee66c9a892'

#    * def itemId = call random_uuid
#    * def itemBarcode = call random_string

    * def itemId = '1c17a642-5e7f-452d-9cae-9cff66c9a892'
    * def itemBarcode = 'item128'
    * def itemStatusName = 'Available'
