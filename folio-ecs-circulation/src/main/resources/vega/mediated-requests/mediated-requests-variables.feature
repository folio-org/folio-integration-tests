@ignore
Feature: Mediated Requests fixed variables (inventory UUIDs for central, university, and college tenants)

  Scenario: mediated-requests inventory variables

    # Central tenant inventory UUIDs
    * def mrCentralInstitutionId    = '5a10852d-49fd-4df2-a1f9-6e2641ac0001'
    * def mrCentralCampusId         = '5a10852d-49fd-4df2-a1f9-6e2641ac0002'
    * def mrCentralLibraryId        = '5a10852d-49fd-4df2-a1f9-6e2641ac0003'
    * def mrCentralServicePointId   = '5a10852d-49fd-4df2-a1f9-6e2641ac0004'
    * def mrCentralHoldingsSourceId = '5a10852d-49fd-4df2-a1f9-6e2641ac0008'
    * def mrCentralLocationId       = '5a10852d-49fd-4df2-a1f9-6e2641ac0009'

    # University (secure) tenant inventory UUIDs
    * def mrUniInstitutionId        = '5b20852d-49fd-4df2-a1f9-6e2641ac0001'
    * def mrUniCampusId             = '5b20852d-49fd-4df2-a1f9-6e2641ac0002'
    * def mrUniLibraryId            = '5b20852d-49fd-4df2-a1f9-6e2641ac0003'
    * def mrUniServicePointId       = '5b20852d-49fd-4df2-a1f9-6e2641ac0004'
    * def mrUniHoldingsSourceId     = '5b20852d-49fd-4df2-a1f9-6e2641ac0008'
    * def mrUniLocationId           = '5b20852d-49fd-4df2-a1f9-6e2641ac0009'

    # College tenant inventory UUIDs
    * def mrCollegeInstitutionId    = '5c30852d-49fd-4df2-a1f9-6e2641ac0001'
    * def mrCollegeCampusId         = '5c30852d-49fd-4df2-a1f9-6e2641ac0002'
    * def mrCollegeLibraryId        = '5c30852d-49fd-4df2-a1f9-6e2641ac0003'
    * def mrCollegeServicePointId   = '5c30852d-49fd-4df2-a1f9-6e2641ac0004'
    * def mrCollegeHoldingsSourceId = '5c30852d-49fd-4df2-a1f9-6e2641ac0008'
    * def mrCollegeLocationId       = '5c30852d-49fd-4df2-a1f9-6e2641ac0009'

    # Shared reference-data UUIDs — MUST be identical across all tenants for instance sharing to work
    * def mrInstanceTypeId          = '5d40852d-49fd-4df2-a1f9-6e2641ac0005'
    * def mrLoanTypeId              = '5d40852d-49fd-4df2-a1f9-6e2641ac0006'
    * def mrMaterialTypeId          = '5d40852d-49fd-4df2-a1f9-6e2641ac0007'
