@ignore
Feature: ECS Requests fixed variables (inventory UUIDs for central and university tenants)

  Scenario: ecs-requests inventory variables

    # Central tenant inventory UUIDs
    * def ecsInstitutionId     = '4a10852d-49fd-4df2-a1f9-6e2641ab0001'
    * def ecsCampusId          = '4a10852d-49fd-4df2-a1f9-6e2641ab0002'
    * def ecsLibraryId         = '4a10852d-49fd-4df2-a1f9-6e2641ab0003'
    * def ecsServicePointId    = '4a10852d-49fd-4df2-a1f9-6e2641ab0004'
    * def ecsHoldingsSourceId  = '4a10852d-49fd-4df2-a1f9-6e2641ab0008'
    * def ecsLocationId        = '4a10852d-49fd-4df2-a1f9-6e2641ab0009'

    # University tenant inventory UUIDs
    * def uniInstitutionId     = '4b20852d-49fd-4df2-a1f9-6e2641ab0001'
    * def uniCampusId          = '4b20852d-49fd-4df2-a1f9-6e2641ab0002'
    * def uniLibraryId         = '4b20852d-49fd-4df2-a1f9-6e2641ab0003'
    * def uniServicePointId    = '4b20852d-49fd-4df2-a1f9-6e2641ab0004'
    * def uniHoldingsSourceId  = '4b20852d-49fd-4df2-a1f9-6e2641ab0008'
    * def uniLocationId        = '4b20852d-49fd-4df2-a1f9-6e2641ab0009'

    # Shared reference-data UUIDs — MUST be identical in both tenants for instance sharing to work
    * def ecsInstanceTypeId    = '4c30852d-49fd-4df2-a1f9-6e2641ab0005'
    * def ecsLoanTypeId        = '4c30852d-49fd-4df2-a1f9-6e2641ab0006'
    * def ecsMaterialTypeId    = '4c30852d-49fd-4df2-a1f9-6e2641ab0007'
    * def uniInstanceTypeId    = ecsInstanceTypeId
    * def uniLoanTypeId        = ecsLoanTypeId
    * def uniMaterialTypeId    = ecsMaterialTypeId
