Feature: Central variables

  Scenario: finance variables
    * def centralFiscalYearId = 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf2'
    * def centralPlannedFiscalYearId = 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf3'
    * def centralLedgerId = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695'
    * def centralLedgerWithRestrictionsId = '5e4fbdab-f1b1-4be8-9c33-d3c41ec6a696'
    * def centralFundId = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696'
    * def centralFundCode = 'TST-FND'
    * def centralBudgetId = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a697'
    * def centralFundId2 = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698'
    * def centralFundCode2 = 'TST-FND-2'
    * def centralBudgetId2 = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a658'
    * def centralFundId3 = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a638'
    * def centralFundCode3 = 'TST-FND-3'
    * def centralBudgetId3 = '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a618'
    * def centralFundId4 = '6e4fbdab-f1b1-4be8-9c33-d3c41ec9a638'
    * def centralFundCode4 = 'USHIST'
    * def centralBudgetId4 = '6e4fbdab-f1b1-4be8-9c33-d3c41ec9a618'
    * def centralFundWithoutBudget = 'c9363394-c13a-4470-bce5-3fdfce5a14cc'
    * def centralFundWithoutBudgetCode = 'TST-FND-3-WO'
    * def centralElecExpenseClassId = '1bcc3247-99bf-4dca-9b0f-7bc51a2998c2'
    * def centralPrnExpenseClassId = '5b5ebe3a-cf8b-4f16-a880-46873ef21388'
    * def centralOtherExpenseClassId = '9abc4491-b2f0-413c-be51-51675b15f366'

  Scenario: inventory variables
    * def centralInstanceTypeId = '6d6f642d-0000-1111-aaaa-6f7264657273'
    * def centralSecondInstanceTypeId = '30fffe0e-e985-4144-b2e2-1e8179bdb41f'
    * def centralInstanceStatusId = 'daf2681c-25af-4202-a3fa-e58fdf806183'
    * def centralSecondInstanceStatusId = '6d6f642d-0001-1111-aaaa-6f7264657273'
    * def centralLoanTypeId = '2b94c631-fca9-4892-a730-03ee529ffe27'
    * def centralMaterialTypeIdPhys = '6d6f642d-0003-1111-aaaa-6f7264657272'
    * def centralMaterialTypeIdElec = '6d6f642d-0003-1111-aaaa-6f7264657273'
    * def centralLocationUnitsInstitutionsId = '40ee00ca-a518-4b49-be01-0638d0a4ac57'
    * def centralLocationUnitsCampusesId = '62cf76b7-cca5-4d33-9217-edf42ce1a848'
    * def centralLocationUnitsLibrariesId = '5d78803e-ca04-4b4a-aeae-2c63b924518b'
    * def centralServicePointsId = '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    * def centralHoldingsSourceId = 'f32d531e-df79-46b3-8932-cdd35f7a2264'
    * def centralLocationsId = 'b32c5ce2-6738-42db-a291-2796b1c3c4c6'
    * def centralLocationsId2 = 'b32c5ce2-6738-42db-a291-2796b1c3c4c8'
    * def centralLocationsId3 = 'b32c5ce2-6738-42db-a291-2796b1c3c4c9'
    * def centralInstanceId = 'd6635cf1-b775-46ac-94e5-adaffee111cd'
    * def centralHoldingId1 = '59e2c91d-d1dd-4e1a-bbeb-67e8b4dcd111'
    * def centralHoldingId2 = '59e2c91d-d1dd-4e1a-bbeb-67e8b4dcd222'
    * def centralHoldingId3 = '59e2c91d-d1dd-4e1a-bbeb-67e8b4dcd333'
    * def centralContributionTypeId = '6d6f642d-0005-1111-aaaa-6f7264657273'

  Scenario: organization variables
    * def centralVendorId = 'c6dace5d-4574-411e-8ba1-036102fcdc9b'
    * def centralGobiVendorId = 'c6dace5d-4574-411e-8ba1-036102fcdc1a'
    * def centralOrgIsNotVendorId = 'c6dace5d-4574-411e-8ba2-036102fcdc2a'

  Scenario: orders variables
    * def centralApprovalPlanAcqMethodId = 'e69a29f8-f4b2-472e-8b6b-bfca1679dd38'
    * def centralPurchaseAcqMethodId = 'f64e8df1-33de-4bb1-970d-5d2767e712a3'

  Scenario: User IDs
    * def centralAdminId = '122b3d2b-4788-4f1e-9117-56daa91cb75c'