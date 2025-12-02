Feature: Transaction Body Generator
  Background:
    * callonce variables

  @CreateLenderPayloadWithLocalNames
  Scenario: generate-payload-for-pickup-role
    * def dcbTransaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * def randomTransactionId = call uuid1

    * dcbTransaction.item.id = itemId120
    * dcbTransaction.item.barcode = itemBarcode120
    * dcbTransaction.patron.id = uuid1()
    * dcbTransaction.patron.barcode = 'dcb_patron_' + random_string()
    * dcbTransaction.patron.localNames = args.localNames
    * dcbTransaction.patron.group = patronGroupName
    * dcbTransaction.pickup.servicePointName = 'lending_sp1'
    * dcbTransaction.pickup.libraryCode = '6uclv'
    * dcbTransaction.role = 'LENDER'

  @CreatePickupPayloadWithLocalNames
  Scenario: generate-payload-for-pickup-role
    * def dcbTransaction = read('classpath:volaris/mod-dcb/features/samples/transaction/create-dcb-transaction.json')
    * def randomTransactionId = call uuid1

    * dcbTransaction.item.id = uuid1()
    * dcbTransaction.item.barcode = 'dcb_item_' + random_string()
    * dcbTransaction.patron.id = uuid1()
    * dcbTransaction.patron.barcode = 'dcb_patron_' + random_string()
    * dcbTransaction.patron.localNames = args.localNames
    * dcbTransaction.patron.group = patronGroupName
    * dcbTransaction.pickup.servicePointId = servicePointId21
    * dcbTransaction.pickup.servicePointName = servicePointName21
    * dcbTransaction.pickup.libraryCode = '6uclv'
    * dcbTransaction.role = 'PICKUP'
