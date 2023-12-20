Feature: global variables

  @GlobalVariables
  Scenario: use global variables

    * def holdingsRecordId = '72dec934-2a7a-4b2a-a522-ea6864cff030'
    * def permanentLoanTypeId = '2b94c631-fca9-4892-a730-03ee529ffe27'
    * def materialTypeId = '1a54b431-2e4f-452d-9cae-9cee66c9a892'
    * def itemStatusName = 'Available'

    * def patronGroupId = '3684a786-6671-4268-8ed0-9db82ebca60b'
    * def patronGroupName = 'staff'

    * def patronId11 = '11b526a6-37d6-47c2-a4df-e46189791256'
    * def patronBarcode11 = 'systemDemoUser1'

    * def patronId21 = '216d6ef8-b0c5-40a0-8cd1-d758a4937abd'
    * def patronBarcode21 = 'systemDemoUser2'

    * def patronId31 = '5ecb5ee3-df23-4f63-9449-b03d0ec470c5'
    * def patronBarcode31 = 'systemDemoUser3'

    * def patronId41 = '5ecb5ee4-df23-4f63-9449-b03d0ec470c6'
    * def patronBarcode41 = 'systemDemoUser4'

    * def servicePointId11 = '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    * def servicePointId21  = 'c4c90014-c8c9-4ade-8f24-b5e313319f4b'
    * def servicePointName11  = 'Circ Desk 1'
    * def servicePointName21  = 'Circ Desk 2'
    * def servicePointCode11 = 'cd1'
    * def servicePointCode21 = 'cd2'

    * def checkInId = 'ea1235da-779a-11ee-b962-0242ac120002'
    * def checkOutByBarcodeId = 'ea1235da-779a-11ee-b962-0242ac120003'

    * def dcbTransactionId11 = '39922346'
    * def dcbTransactionId21 = '39223457'
    * def dcbTransactionId31 = '48224'
    * def dcbTransactionId41 = '56224'

    * def itemId11 = '2c17a643-1e8f-452d-9cae-9cff66c9a893'
    * def itemId21 = '3c17a643-5e8f-452d-9cae-9cff66c9a899'
    * def itemId31 = '4c17a643-5e8f-452d-9cae-9cff66c9a899'
    * def itemId41 = '5c17a643-5e8f-452d-9cae-9cff66c9a899'

    * def itemBarcode11 = 'newitem346'
    * def itemBarcode21 = 'newitem246'
    * def itemBarcode31 = 'newitem446'
    * def itemBarcode41 = 'newitem546'