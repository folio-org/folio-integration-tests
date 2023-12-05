Feature: global variables

  @GlobalVariables
  Scenario: use global variables
    * def intInstanceTypeId = '0f97f0fc-77b3-11ee-b962-0242ac120002'
    * def contributorNameTypeId = '176915ea-77b3-11ee-b962-0242ac120002'

    * def permanentLoanTypeId = '311a85f6-77b7-11ee-b962-0242ac120002'

    * def intItemId = '3c497cc0-77b7-11ee-b962-0242ac120002'
    * def intStatusName = 'Available'

    * def dcbTransactionId = '123456891'
    * def dcbTransactionIdNonExisting = '123'
    * def itemBarcode = 'newdcb123'
    * def itemNonExistingBarcode = 'newdcb1111'
    * def patronId = 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2'e
    * def patronName = 'patronName'
    * def patronBarcode = '111111'
    * def instanceId = 'ea614654-73d8-11ee-b962-0242ac120002'

    * def contributorNameTypeId = 'f2cedf06-73d1-11ee-b962-0242ac120002'
    * def institutionId = '8e30bb06-76ff-11ee-b962-0242ac120002'
    * def locationId = '0afceb26-77d9-11ee-b962-0242ac120002'
    * def campusId = 'ae12d634-76ff-11ee-b962-0242ac120002'
    * def libraryId = 'b55e9040-76ff-11ee-b962-0242ac120002'
    * def locationId = 'd8b25bb2-76ff-11ee-b962-0242ac120002'
    * def holdingId = '70cf22e6-779f-11ee-b962-0242ac120002'
    * def checkInId = 'ea1235da-779a-11ee-b962-0242ac120002'

    * def extItemId = 'c7a2f4de-77af-11ee-b962-0242ac120002'
    * def notExistingItem = 'c7a2f4de-77af-11ee-b962-0242ac120002'

    * def extUserBarcode = 'FAT-993IBC'
    * def extItemBarcode = 'FAT-993IBC'
    * def extUserId = 'a9b73276-77b6-11ee-b962-0242ac120002'

    * def intInstitutionId = '52914c6c-77d8-11ee-b962-0242ac120002'
    * def intCampusId = '592e58da-77d8-11ee-b962-0242ac120002'
    * def intLibraryId = '60bda6c8-77d8-11ee-b962-0242ac120002'

    * def extInstanceTypeId = 'ab164870-77af-11ee-b962-0242ac120002'
    * def extInstitutionId = 'b1ad12f4-77af-11ee-b962-0242ac120002'
    * def extCampusId = 'b812fdf2-77af-11ee-b962-0242ac120002'
    * def extLibraryId = 'bf61fea0-77af-11ee-b962-0242ac120002'
    * def extItemBarcode = 'FAT-unknownIBC'

    * def servicePointId = 'afbd1042-794a-11ee-b962-0242ac120002'

    * def intMaterialTypeId = 'daf1aaea-794d-11ee-b962-0242ac120002'
    * def materialTypeName = 'e182c8a8-794d-11ee-b962-0242ac120002'
    * def intUserGroupId = '5edd4dce-77b3-11ee-b962-0242ac120002'

    * def checkInId = '4257262e-77b4-11ee-b962-0242ac120002'

    * def intLoanDate = '2021-10-27T13:25:46.000Z'