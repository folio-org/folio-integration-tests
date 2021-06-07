Feature: global variables

  Scenario: edge-caiasoft global variables
    * def remoteFolioLocationId = '53cf956f-c1df-410b-8bea-27f712cca7c0'
    * def remoteStorageId = 'de56bad2-1a33-5f1c-bee6-f653ded15629'
    * def notRemoteFolioLocationId = 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    * def instanceId = 'a24eccf0-57a6-495e-898d-32b9b2210f2f'
    * def instanceIdForHoldingDublication = call uuid
    * def instanceTypeId = '6312d172-f0cf-40f6-b27d-9fa8feaf332f'
    * def itemId = call uuid
    * def itemBarcode = call random_string
    * def itemId2 = 'fb3b70f3-b291-4921-a391-1e4b6513bb8f'
    * def itemBarcode2 = 'B0B0B'
    * def itemId3 = 'fb5b90f2-b294-4127-a398-1e4b6513bb8f'
    * def itemBarcode3 = 'C0C0C'
    * def holdingsRecordId = call uuid
    * def holdingsRecordId2 = call uuid
    * def servicePointId = '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    * def user1Barcode = call random_string
    * def user1Id = call uuid
    * def user2Barcode = call random_string
    * def user2Id = call uuid
    * def cancellationReasonId = "75187e8d-e25a-47a7-89ad-23ba612338de"
    * def requesterId = call uuid
    * def requestId = call uuid

