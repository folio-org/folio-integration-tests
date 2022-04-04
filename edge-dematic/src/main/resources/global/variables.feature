Feature: global variables

  Scenario: edge-dematic global variables
    * def holdingsRecordId = 'e3ff6133-b9a2-4d4c-a1c9-dc1867d4df19'
    * def remoteLocationId = '53cf956f-c1df-410b-8bea-27f712cca7c0'
    * def storageId = 'de17bad7-2a30-4f1c-bee5-f653ded15629'
    * def servicePointId = '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    * def user1Id = '245a9f4d-4889-4e4a-901d-6d8357043406'
    * def user1Barcode = '123456'
    * def user2Id = '57b254b2-cdc0-4960-941a-43ac630e2d96'
    * def user2Barcode = '546372'
    * def cancellationReasonId = "75187e8d-e25a-47a7-89ad-23ba612338de"
    * def instanceId = '5bf370e0-8cca-4d9c-82e4-5170ab2a0a39'
    * def dematicGroupId = call uuid
    * def dematicPageRequestPolicyId = call uuid
    * def random = call random_string
    * def dematicGroupName = "dematicTest" + random
    * def dematicPageRequestPolicyName = "dematic-page-request-policy" + random