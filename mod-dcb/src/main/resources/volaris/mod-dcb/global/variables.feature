Feature: global variables

  @GlobalVariables
  Scenario: use global variables
    * def utilsPath = 'classpath:volaris/mod-dcb/reusable/pre-requisites.feature'

    * def instanceTypeId = '0f97f0fc-77b3-11ee-b962-0242ac120002'
    * def contributorNameTypeId = '176915ea-77b3-11ee-b962-0242ac120002'
    * def permanentLoanTypeId = '311a85f6-77b7-11ee-b962-0242ac120002'
    * def instanceId = 'ea614654-73d8-11ee-b962-0242ac120002'
    * def institutionId = '8e30bb06-76ff-11ee-b962-0242ac120002'
    * def locationId = '0afceb26-77d9-11ee-b962-0242ac120002'
    * def campusId = 'ae12d634-76ff-11ee-b962-0242ac120002'
    * def libraryId = 'b55e9040-76ff-11ee-b962-0242ac120002'
    * def locationId = 'd8b25bb2-76ff-11ee-b962-0242ac120002'
    * def holdingId = '70cf22e6-779f-11ee-b962-0242ac120002'
    * def checkInId = 'ea1235da-779a-11ee-b962-0242ac120002'
    * def intInstitutionId = '52914c6c-77d8-11ee-b962-0242ac120002'
    * def intCampusId = '592e58da-77d8-11ee-b962-0242ac120002'
    * def intLibraryId = '60bda6c8-77d8-11ee-b962-0242ac120002'
    * def extInstitutionId = 'b1ad12f4-77af-11ee-b962-0242ac120002'
    * def extCampusId = 'b812fdf2-77af-11ee-b962-0242ac120002'
    * def extLibraryId = 'bf61fea0-77af-11ee-b962-0242ac120002'
    * def materialTypeId = 'daf1aaea-794d-11ee-b962-0242ac120002'
    * def materialTypeName = 'book'
    * def itemStatusName = 'Available'
    * def patronGroupId = '5edd4dce-77b3-11ee-b962-0242ac120002'
    * def patronGroupName = 'staff'


    * def servicePointId = '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    * def servicePointId1 = '5d2625ef-81eb-4e61-a8a9-87c94ba3764d'

    * def servicePointName = 'Circ Desk 1'
    * def servicePointName1 = 'Circ Desk 2'

    * def servicePointCode = 'cd1'
    * def servicePointCode1 = 'cd2'

    * def patronId = 'e58ca3a7-7674-44e5-8a1c-cdb22d0f87ec'
    * def patronId1 = 'e58ca3a7-7674-44e5-8a1c-cdb22d0f87ce'
    * def patronId2 = 'ee6542c3-f98e-414a-94e4-caad908aebdf'
    * def patronId3 = 'ee6542c3-f98e-414a-94e4-caad908aeb00'
    * def patronIdNonExisting = 'ee6542c4-f98e-414a-94e4-caad908aeb00'
    * def patronNameNonExisting = 'patronIdNonExisting'


    * def patronBarcode = 'testuser123'
    * def patronBarcode1 = 'testuser12345'
    * def patronBarcode2 = 'testuser987'
    * def patronBarcode3 = 'testuser98765'
    * def patronBarcode4 = 'testuser444'
    * def patronBarcode5 = 'testuser555'


    * def dcbTransactionId = '123'
    * def dcbTransactionId1 = '12345'
    * def dcbTransactionId2 = '987'
    * def dcbTransactionId3 = '98765'

    * def dcbTransactionIdValidation1 = '10'
    * def dcbTransactionIdValidation2 = '20'
    * def dcbTransactionIdValidation3 = '30'
    * def dcbTransactionIdValidation4 = '40'
    * def dcbTransactionIdValidation5 = '50'
    * def dcbTransactionIdValidation6 = '60'
    * def dcbTransactionIdValidation7 = '70'
    * def dcbTransactionIdValidation8 = '80'
    * def dcbTransactionIdValidation9 = '90'
    * def dcbTransactionIdValidation10 = '100'
    * def dcbTransactionIdValidation11 = '110'
    * def dcbTransactionIdValidation12 = '120'

    * def dcbTransactionIdValidation20 = '200'


    * def patronIdNonExisting = 'ee6542c3-f98e-414a-94e4-caad908aeb01'
    * def patronBarcodeNonExisting = 'testuser10'

    * def itemId = 'e58ca7a7-7674-44e5-8a1c-cdb22d0f87ce'
    * def itemId1 = '91aa52cb-29d2-41c1-99a2-fb9b293956dc'
    * def itemId2 = '565a17a1-e258-4973-bab6-da176010ea3c'
    * def itemId3 = '3c497cc0-77b7-11ee-b962-0242ac120002'
    * def itemId4 = '5c497cc0-77b7-11ee-b962-0242ac120002'
    * def itemId5 = '6c497cc0-77b7-11ee-b962-0242ac120002'
    * def itemId6 = '80cf22e6-779f-11ee-b962-1242ac120009'
    * def itemId7 = '70cf22e6-779f-11ee-b962-1242ac120009'
    * def itemId8 = '85cf22e6-779f-11ee-b962-1242ac120009'


    * def itemId20 = '965a17a1-e258-4973-bab6-da176010ea4c'
    * def itemId30 = '345a17a1-e258-4973-bab6-da176010ea4c'
    * def itemId40 = '495a17a1-e258-4973-bab6-da176010ea4c'
    * def itemId50 = '495a17a1-e258-4973-bab6-da176010ea4c'
    * def itemId60 = '695a17a1-e258-4973-bab6-da176010ea4c'
    * def itemId70 = '795a17a1-e258-4973-bab6-da176010ea4c'
    * def itemId80 = '895a17a1-e258-4973-bab6-da176010ea4c'


    * def itemBarcode20 = '2055'
    * def itemBarcode30 = '3055'
    * def itemBarcode40 = '4055'
    * def itemBarcode50 = '5055'
    * def itemBarcode60 = '6055'
    * def itemBarcode70 = '7055'
    * def itemBarcode80 = '8055'


    * def itemBarcode = '18'
    * def itemBarcode1 = '19'
    * def itemBarcode2 = '20'
    * def itemBarcode3 = '21'
    * def itemBarcode4 = '41'
    * def itemBarcode5 = '51'

    * def itemBarcodeAlreadyExists = '320'
    * def itemBarcodeAlreadyExists2 = '325'
    * def itemBarcodeAlreadyExists3 = '333'

    * def dcbTransactionIdNonExisting = '11122'
    * def itemNonExistingBarcode = 'newdcb1111'

    * def cancellationReasonId = 'ea614654-73d8-11ee-b962-0242ac120003'
    * def extRequestType = 'Page'
    * def extRequestId = 'ef1235da-779a-11ee-b962-0242ac120002'

    * def intMaterialTypeIdNonExisting = 'ea614699-73d8-11ee-b962-0242ac120009'
    * def intMaterialTypeId1 = '40cf22e6-779f-11ee-b963-0242ac120004'
    * def intMaterialTypeId2 = '10cf22e6-779f-11ee-b963-0242ac120004'
    * def intMaterialTypeId3 = '42cf22e6-779f-11ee-b963-0242ac120004'

    * def intMaterialTypeName1 = 'name23'
    * def intMaterialTypeName2 = 'name22'
    * def intMaterialTypeName3 = 'name33'

    * def intMaterialTypeId2 = '10cf22e6-779f-11ee-b963-0242ac120012'
