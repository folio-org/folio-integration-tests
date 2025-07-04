Feature: global variables

  @GlobalVariables
  Scenario: use global variables
    * def intInstanceTypeId = '0f97f0fc-77b3-11ee-b962-0242ac120002'
    * def contributorNameTypeId = '176915ea-77b3-11ee-b962-0242ac120002'

    * def permanentLoanTypeId = '311a85f6-77b7-11ee-b962-0242ac120002'

    * def intItemId = '3c497cc0-77b7-11ee-b962-0242ac120002'
    * def intItemId1 = '87fb26fa-91cc-4a94-ba2f-8903ff792460'
    * def intItemId2 = 'e68b3153-11a8-47ee-ba80-75b1c0d332c1'
    * def intItemId3 = 'eaf59922-b3fc-4ab5-8c2d-6a884247e9b3'
    * def intItemId4 = 'a9576acb-83ee-4819-bee0-d27f07863f23'
    * def intItemId5 = 'b9576adb-83ee-4819-bee0-d27f07863f23'
    * def intItemId6 = 'b9576aeb-83ee-4819-bee0-d27f07863f23'
    * def intStatusName = 'Available'

    * def dcbTransactionId = '123456891'
    * def dcbTransactionIdNonExisting = '123'
    * def itemBarcode = 'newdcb12'
    * def itemBarcode1 = 'newdcb123'
    * def itemBarcode2 = 'newdcb1234'
    * def itemBarcode3 = 'newdcb12345'
    * def itemBarcode4 = 'newdcb123456'
    * def itemBarcode5 = 'newdcb1234567'
    * def itemBarcode6 = 'newdcb1234568'
    * def itemNonExistingBarcode = 'newdcb1111'
    * def patronId = 'ad2164c7-ba3d-1bc2-a12c-e35ceccbfaf2'
    * def patronName = 'patronName1'
    * def patronBarcode = '1111111'
    * def instanceId = 'ea614654-73d8-11ee-b962-0242ac120002'

    * def contributorNameTypeId = 'f2cedf06-73d1-11ee-b962-0242ac120002'
    * def institutionId = '8e30bb06-76ff-11ee-b962-0242ac120002'
    * def locationId = '0afceb26-77d9-11ee-b962-0242ac120002'
    * def campusId = 'ae12d634-76ff-11ee-b962-0242ac120002'
    * def libraryId = 'b55e9040-76ff-11ee-b962-0242ac120002'
    * def locationId = 'd8b25bb2-76ff-11ee-b962-0242ac120002'
    * def holdingId = '70cf22e6-779f-11ee-b962-0242ac120002'
    * def checkInId = 'ea1235da-779a-11ee-b962-0242ac120002'
    * def extRequestType = 'Page'
    * def extRequestId = 'ef1235da-779a-11ee-b962-0242ac120002'

    * def extItemId = 'c7a2f4de-77af-11ee-b962-0242ac120003'
    * def extItemId1 = 'bf12d634-76ff-11ee-b962-0242ac120004'
    * def extItemId2 = 'd8b25bb2-76ff-11ee-b962-0242ac120005'
    * def extItemId3 = 'c7a2f4de-77af-11ee-b962-0242ac120006'
    * def extItemId4 = '70cf22e6-779f-11ee-b962-0242ac120007'
    * def extItemId5 = '70cf22e6-779f-11ee-b962-0242ac120008'
    * def extItemId6 = '70cf22f6-779f-11ee-b962-0242ac120008'
    * def extUserBarcode = 'FAT-993IBC'
    * def extUserBarcode1 = 'FAT-993IBD'
    * def extItemBarcode = 'FAT-993IBC'
    * def extUserId = 'a9b73276-77b6-11ee-b962-0242ac120002'
    * def extUserId1 = 'a9b73277-77b6-11ee-b962-0242ac120002'

    * def intInstitutionId = '52914c6c-77d8-11ee-b962-0242ac120002'
    * def intCampusId = '592e58da-77d8-11ee-b962-0242ac120002'
    * def intLibraryId = '60bda6c8-77d8-11ee-b962-0242ac120002'
    * def cancellationReasonId = 'ea614654-73d8-11ee-b962-0242ac120003'

    * def extInstanceTypeId = 'ab164870-77af-11ee-b962-0242ac120002'
    * def extInstitutionId = 'b1ad12f4-77af-11ee-b962-0242ac120002'
    * def extCampusId = 'b812fdf2-77af-11ee-b962-0242ac120002'
    * def extLibraryId = 'bf61fea0-77af-11ee-b962-0242ac120002'
    * def extItemBarcode = 'FAT-unknownIBC'

    * def servicePointId = 'afbd1042-794a-11ee-b962-0242ac120002'

    * def intMaterialTypeId = 'daf1aaea-794d-11ee-b962-0242ac150002'
    * def intUserGroupId = '5edd4dce-77b3-11ee-b962-0242ac120002'
    * def checkInId = '4257262e-77b4-11ee-b962-0242ac120002'
    * def intLoanDate = '2021-10-27T13:25:46.000Z'

    * def materialTypeId = 'daf1aaea-794d-11ee-b962-0242ac120002'
    * def materialTypeName = 'namebook'
    * def itemStatusName = 'Available'
    * def patronGroupId = '5edd4dce-77b3-11ee-b962-0242ac120003'
    * def patronGroupName = 'staff gyu708765'
    * def servicePointId = 'afbd1042-794a-11ee-b962-0242ac120002'
    * def servicePointName = 'test service point'
    * def servicePointCode = 'test'

    * def servicePointId11 = '3a40852d-49fd-4df2-a1f9-6e2641a6e71f'
    * def servicePointId21 = '5d2625ef-81eb-4e61-a8a9-87c94ba3774d'

    * def servicePointName11 = 'Circ Desky 10'
    * def servicePointName21 = 'Circ Desky 20'

    * def servicePointCode11 = 'cdy10'
    * def servicePointCode21 = 'cdy20'

    * def patronId11 = 'e58ca3a7-7674-44e5-8a1c-cdb22d0f87ec'
    * def patronId21 = 'e58ca3a7-7674-44e5-8a1c-cdb22d0f87ce'
    * def patronId31 = 'ee6542c3-f98e-414a-94e4-caad908aebdf'
    * def patronId41 = 'ee6542c3-f98e-414a-94e4-caad908aeb00'

    * def patronBarcode11 = 'testuser123'
    * def patronBarcode21 = 'testuser12345'
    * def patronBarcode31 = 'testuser987'
    * def patronBarcode41 = 'testuser98765'

    * def dcbTransactionId11 = '1234'
    * def dcbTransactionId21 = '12345'
    * def dcbTransactionId31 = '987'
    * def dcbTransactionId41 = '98765'

    * def itemId11 = 'e58ca7a7-7674-44e5-8a1c-cdb22d0f87ce'
    * def itemId21 = '91aa52cb-29d2-41c1-99a2-fb9b293956dc'
    * def itemId31 = '565a17a1-e258-4973-bab6-da176010ea3c'
    * def itemId32 = 'ca90e0fc-68f5-4547-ab3e-4d5076e18818'
    * def itemId41 = '3c497cc0-77b7-11ee-b962-0242ac120003'
    * def itemId51 = '3c497cc0-77b7-11ee-b962-0242ac120004'
    * def itemId61 = '3c497cc0-77b7-11ee-b962-0242ac120005'
    * def itemId71 = '3c497cc0-77b7-11ee-b962-0242ac120006'

    * def itemBarcode11 = '18'
    * def itemBarcode21 = '19'
    * def itemBarcode31 = '20'
    * def itemBarcode32 = '32'
    * def itemBarcode41 = '21'
    * def itemBarcode51 = '22'
    * def itemBarcode61 = '23'
    * def itemBarcode71 = '24'

    * def itemNonExistingBarcode = 'newdcb11020'
    * def itemId71 = '1cbcdb7e-edcd-4874-af0b-2df1c5076737'
    * def itemBarcode311 = '3111'
    * def patronId51 = 'd0d52946-c5da-40a8-acc8-f05805135b65'
    * def patronBarcode51 = 'testuser123051'
    * def dcbTransactionId411 = '9041187'
    * def intMaterialTypeIdNonExisting = '0f656d87-b6bc-407b-b483-8066dfe89d04'
    * def itemBarcode7itemId5 = '7724'
    * def itemId5 = '63a38cea-1aa5-4a7a-87d4-8b44807ca030'
    * def itemId30 = '5e70dcc0-7ec2-42c7-b44c-9dc5d18e1961'
    * def itemBarcode30 = '30201'
    * def dcbTransactionIdValidation7 = '744'
    * def dcbTransactionIdValidation6 = '644'
    * def itemId111 = '59c97459-512d-4cc1-9aaf-8af78f3a3c17'
    * def itemId112 = '87f33284-8e71-4c75-9bc9-fcdcfa516544'
    * def itemBarcode70 = '7070'
    * def itemId60 = 'fd510fa8-b2bf-4134-b6ac-71ecd8accfc6'
    * def intMaterialTypeId3 = '175922a9-d770-46a0-9758-966d8bfc4e5c'
    * def itemId80 = '2c879e1e-6e19-4555-8824-783a02c2f407'
    * def itemId110 = '44a0b870-4096-41d6-ab88-7e9fdedf8aba'
    * def patronIdNonExisting = '8ca3438a-6d91-4341-8a39-f66d318f814d'
    * def itemIdNotExisting = '5d6cfcbe-7fc2-4945-b082-1eb149b973aa'
    * def itemId311 = '34e16895-d876-42ba-b962-422c13f27428'
    * def itemBarcode7 = '7714'
    * def patronId1 = '74a0e2a0-5a09-44a0-ac6f-471af1fe8f48'
    * def utilsPath = 'classpath:volaris/mod-dcb/reusable/pre-requisites.feature'
    * def itemId20 = '155f1705-3628-4769-9a8d-bc58a7b52932'
    * def itemBarcode50 = '5050'
    * def itemId40 = 'e6208f36-adc5-419e-82f0-3a02d28ea809'
    * def intMaterialTypeId1 = '2b086e49-e5eb-46e6-8907-13a53e41c67a'
    * def itemId20 = '37f4a7a3-5a94-4148-8fa7-42fe6cfea8c2'
    * def itemBarcode111 = '110110000'
    * def itemBarcode112 = '111000112'
    * def itemId70 = '490fcf53-542b-4ad2-ae83-f1c825ab6fa3'
    * def itemBarcode60 = '6060'
    * def intMaterialTypeName3 = '6ae81a27-6138-483c-8ed4-266a74eec312'
    * def itemBarcode80 = '80808'
    * def patronNameNonExisting = 'patronNameNonExisting'
    * def dcbTransactionId511 = '5110'
    * def itemBarcode110 = '11010'
    * def intMaterialTypeId2 = 'e61fd043-641b-4f2a-b4ab-8dbc1ab28679'
    * def patronBarcode1 = '111011'
    * def itemBarcode20 = '20200'
    * def itemBarcode40 = '4044'
    * def itemId50 = 'b1210866-50e7-44b1-bd4d-2b4e31804c5e'
    * def intMaterialTypeName1 = 'Name1'
    * def itemBarcodeAlreadyExists3 = '30300'
    * def patronId3 = '30152d24-af64-4c6c-91f4-0f81c88afcc3'
    * def patronId111 = '6fb2fad9-cbb4-441e-8b95-31535a6005bd'
    * def servicePointId1 = 'b929f6fe-720e-4c0b-88f8-2e36997962b1'
    * def dcbTransactionId611 = '611'
    * def patronId110 = 'a46a9e8e-da5c-4c86-893f-306da18dfe4f'
    * def intMaterialTypeName2 = 'name2'
    * def patronBarcodeNonExisting = 'patronBarcodeNonExisting'
    * def patronId2 = 'dde93db3-23bb-48b5-be44-cafec93cbcd8'
    * def dcbTransactionId311 = '3111'
    * def patronBarcode3 = '322'
    * def patronBarcode111 = '111'
    * def itemId7 = '44d8127c-c372-4112-ac79-d45e0e762ae1'
    * def servicePointName1 = 'servicePointName1'
    * def patronBarcode110 = '1101111'
    * def itemBarcodeAlreadyExists = '222'
    * def patronBarcode2 = '2222'
    * def dcbTransactionIdValidation11 = '1101'
    * def dcbTransactionId61 = '61111'
    * def dcbTransactionIdValidation10 = '1010'
    * def dcbTransactionIdValidation12 = '1212'
    * def dcbTransactionIdValidation20 = '202'
    * def dcbTransactionId51 = '51'
    * def dcbTransactionIdValidation8 = '88'
    * def dcbTransactionIdValidation9 = '99'
    * def dcbTransactionIdValidation1 = '11'
    * def itemId8 = 'cce9b856-77db-48c0-b6b5-7383b91d9119'
    * def dcbTransactionIdValidation2 = '202'
    * def itemBarcodeAlreadyExists2 = '2022'
    * def itemId6 = '14cddb28-f1c5-48ea-a349-5965c0aeb3dc'
    * def key = ''