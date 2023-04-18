Feature: Root feature that runs all other mod-data-export-spring features

  Background:
    * url baseUrl
    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    # create default variables:
    # finance
    * def defaultFiscalYearId = '012eeb2b-5bac-40bc-b783-8426c46a33b3'
    * def defaultLedgerId = 'a41a0d9a-1bf5-4c68-85ab-861c7e766b06'
    * def defaultFundId = 'e37b7c21-a68c-43af-b98d-161caa7bc729'
    * def defaultBudgetId = '7e7efdc6-5698-478c-bf21-7530168b2a74'
    # inventory
    * def defaultIdentifierTypeId = '08e7b805-b618-49d3-863d-d092ec00c005'
    * def defaultISBNIdentifierTypeId = '861b5028-2aa4-4403-95d0-e7323f271dfa'
    * def defaultInstanceTypeId = '9f3614a8-be63-40e5-9ed5-ff2bdc00ef10'
    * def defaultInstanceStatusId = 'f0be6b43-2385-4305-a05d-9be414998c7d'
    * def defaultLoanTypeId = '9dd62fa5-a060-46d4-8c75-150bc4251f17'
    * def defaultMaterialTypeIdElec = '7c3cad61-6f9e-4ecc-a0e7-6c2355804edc'
    * def defaultMaterialTypeIdPhys = 'b11f5f46-7583-45ae-8afe-519efb6af382'
    * def defaultContributorNameTypeId = 'f0f567fb-2df4-4158-b7b8-17602233d52b'
    * def defaultElectronicAccessRelationshipId = '37d1e2bb-03a1-46eb-8255-06f831dcedf5'
    * def defaultInstitutionId = '3e96ca1c-315e-4c74-a303-4a822a382510'
    * def defaultCampusId = '0c857612-550f-4ebf-8973-0d8ff2f4f10f'
    * def defaultLibraryId = '764163bb-2dce-44bb-bb08-3afcde18affe'
    * def defaultServicePointId = '11137554-f5ec-4460-afe0-1f9594e10def'
    * def defaultHoldingsSourceId = '9019ae7e-15d3-488d-bd30-8913fa4dd0b5'
    * def defaultLocationId = '0a12caf5-cd8f-4819-92da-92d04c759877'
    * def defaultInstanceId = '4d321a03-7d11-4893-9bf7-6dd6f7902b5d'
    * def defaultHoldingId = 'ef11249c-5796-45c1-ac91-6891be6df463'
    # invoice
    * def defaultBatchGroupId = '979ffe7b-9c17-477a-8e22-f3929ab6b7b8'
    # organization
    * def defaultVendorId = '12f4fc79-7055-4fa4-bfef-335d8918e2e4'
    # orders
    * def defaultPurchaseAcqMethodId = '2a38abc5-5a68-4fe5-8db6-cab0d296d6f5'

  Scenario: Set up all defaults
    # classpath:thunderjet/mod-data-export-spring/features/*
    * call read('util/initData.feature@CreateFiscalYear')
    * call read('util/initData.feature@CreateLedgers')
    * call read('util/initData.feature@CreateFund')
    * call read('util/initData.feature@CreateBudget')
    * call read('util/initData.feature@CreateIdentifierType')
    * call read('util/initData.feature@CreateIdentifierTypeISBN')
    * call read('util/initData.feature@CreateInstanceType')
    * call read('util/initData.feature@CreateInstanceStatus')
    * call read('util/initData.feature@CreateLoanType')
    * call read('util/initData.feature@CreateMaterialType')
    * call read('util/initData.feature@CreateMaterialType') { extMaterialTypeId: #(defaultMaterialTypeIdPhys), extMaterialTypeName: 'Phys' }
    * call read('util/initData.feature@CreateContributorNameType')
    * call read('util/initData.feature@CreateElectronicAccessRelationship')
    * call read('util/initData.feature@CreateInstitution')
    * call read('util/initData.feature@CreateCampus')
    * call read('util/initData.feature@CreateLibrary')
    * call read('util/initData.feature@CreateServicePoint')
    * call read('util/initData.feature@CreateHoldingsSource')
    * call read('util/initData.feature@CreateLocation')
    * call read('util/initData.feature@CreateInstance')
    * call read('util/initData.feature@CreateHolding')
    * call read('util/initData.feature@CreateOrganization') { extOrganizationId: #(defaultVendorId), extOrganizationName: 'MODEXPS-202-Default vendor name', extOrganizationCode: 'MODEXPS-202-Default vendor code' }
    * call read('util/initData.feature@CreatePurchaseAcqMethod')

  Scenario: Run all mod-data-export-spring features
    * call read('classpath:thunderjet/mod-data-export-spring/features/edifact-orders-export.feature')