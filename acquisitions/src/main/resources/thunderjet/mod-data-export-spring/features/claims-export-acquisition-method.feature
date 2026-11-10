@parallel=false
# MODORDERS-1491: POST /orders/pieces/claim selects the Claims configs through
# GET /data-export-spring/effective-configs (vendor + PO line acquisition method, MODEXPS-323).
# A config that selects acquisition methods takes only those; a config without methods takes the methods
# no other Claims config of the vendor selects; a piece without an applicable config fails the request.
Feature: Claims export routed by the PO line acquisition method

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * def createLatePiece = read('this:util/export-claims/exportClaimUtils.feature@CreateLatePieceForVendor')
    * def currentDate = callonce getCurrentDate

    # Jobs of the given configs (all Claims jobs of the tenant, filtered by exportConfigId)
    * def jobsOfConfig =
      """
      function(jobRecords, configId) {
        return karate.filter(jobRecords, function(job) {
          return job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.exportConfigId == configId;
        });
      }
      """
    * def claimPieceIdsOf = function(job) { return job.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.claimPieceIds; }


  @Positive
  Scenario: Each Claims config gets only the pieces whose PO line acquisition method it selects
    # 1. One vendor with two Claims configs: Approval Plan and Purchase
    * def orgId = call uuid
    * def configApprovalPlanId = call uuid
    * def configPurchaseId = call uuid
    * def pieceApprovalPlanId = call uuid
    * def piecePurchaseId = call uuid
    * def v = call createOrganization { id: '#(orgId)', code: 'ORG_ACQ_ROUTE', name: 'ORG_ACQ_ROUTE', isVendor: true }

    * table configs
      | configId             | configName       | vendorId | transmissionMethod | fileFormat | defaultAcquisitionMethods         |
      | configApprovalPlanId | "ACQ_ROUTE_AP"   | orgId    | "File download"    | "CSV"      | [globalApprovalPlanAcqMethodId]   |
      | configPurchaseId     | "ACQ_ROUTE_PUR"  | orgId    | "File download"    | "CSV"      | [globalPurchaseAcqMethodId]       |
    * def v = call createIntegrationDetails configs

    # 2. One Late piece per acquisition method
    * table pieces
      | orgId | poNumber | poLineNumber | acqMethodId                   | pieceId             | currentDate |
      | orgId | "66601"  | "66601-1"    | globalApprovalPlanAcqMethodId | pieceApprovalPlanId | currentDate |
      | orgId | "66602"  | "66602-1"    | globalPurchaseAcqMethodId     | piecePurchaseId     | currentDate |
    * def v = call createLatePiece pieces

    # 3. Claim both pieces in one request
    * def v = call claimPieces { claimingPieceIds: "#([pieceApprovalPlanId, piecePurchaseId])", claimingInterval: 1 }

    # 4. One job per config, each with only its own piece
    * configure retry = { count: 10, interval: 3000 }
    Given path 'data-export-spring/jobs'
    And param query = '(type==CLAIMS)'
    And param limit = 1000
    And retry until jobsOfConfig(response.jobRecords, configApprovalPlanId).length == 1 && jobsOfConfig(response.jobRecords, configPurchaseId).length == 1
    When method GET
    Then status 200
    * match claimPieceIdsOf(jobsOfConfig(response.jobRecords, configApprovalPlanId)[0]) == [ '#(pieceApprovalPlanId)' ]
    * match claimPieceIdsOf(jobsOfConfig(response.jobRecords, configPurchaseId)[0]) == [ '#(piecePurchaseId)' ]


  @Positive
  Scenario: A Claims config without acquisition methods takes the methods no other config selects
    # 1. One vendor: config without methods (catch-all) and config for Purchase
    * def orgId = call uuid
    * def configCatchAllId = call uuid
    * def configPurchaseId = call uuid
    * def pieceApprovalPlanId = call uuid
    * def piecePurchaseId = call uuid
    * def v = call createOrganization { id: '#(orgId)', code: 'ORG_ACQ_REST', name: 'ORG_ACQ_REST', isVendor: true }

    * table configs
      | configId         | configName      | vendorId | transmissionMethod | fileFormat | defaultAcquisitionMethods   |
      | configCatchAllId | "ACQ_REST_ALL"  | orgId    | "File download"    | "CSV"      | []                          |
      | configPurchaseId | "ACQ_REST_PUR"  | orgId    | "File download"    | "CSV"      | [globalPurchaseAcqMethodId] |
    * def v = call createIntegrationDetails configs

    # 2. One Late piece per acquisition method
    * table pieces
      | orgId | poNumber | poLineNumber | acqMethodId                   | pieceId             | currentDate |
      | orgId | "66611"  | "66611-1"    | globalApprovalPlanAcqMethodId | pieceApprovalPlanId | currentDate |
      | orgId | "66612"  | "66612-1"    | globalPurchaseAcqMethodId     | piecePurchaseId     | currentDate |
    * def v = call createLatePiece pieces

    # 3. Claim both pieces
    * def v = call claimPieces { claimingPieceIds: "#([pieceApprovalPlanId, piecePurchaseId])", claimingInterval: 1 }

    # 4. Approval Plan goes to the catch-all only, Purchase only to the Purchase config
    * configure retry = { count: 10, interval: 3000 }
    Given path 'data-export-spring/jobs'
    And param query = '(type==CLAIMS)'
    And param limit = 1000
    And retry until jobsOfConfig(response.jobRecords, configCatchAllId).length == 1 && jobsOfConfig(response.jobRecords, configPurchaseId).length == 1
    When method GET
    Then status 200
    * match claimPieceIdsOf(jobsOfConfig(response.jobRecords, configCatchAllId)[0]) == [ '#(pieceApprovalPlanId)' ]
    * match claimPieceIdsOf(jobsOfConfig(response.jobRecords, configPurchaseId)[0]) == [ '#(piecePurchaseId)' ]


  @Negative
  Scenario: Claiming a piece whose acquisition method no Claims config accepts fails without changing the piece
    # 1. Vendor with a Purchase-only Claims config, piece on an Approval Plan PO line
    * def orgId = call uuid
    * def configPurchaseId = call uuid
    * def pieceId = call uuid
    * def v = call createOrganization { id: '#(orgId)', code: 'ORG_ACQ_NONE', name: 'ORG_ACQ_NONE', isVendor: true }
    * def v = call createIntegrationDetails { configId: '#(configPurchaseId)', configName: 'ACQ_NONE_PUR', vendorId: '#(orgId)', transmissionMethod: 'File download', fileFormat: 'CSV', defaultAcquisitionMethods: ['#(globalPurchaseAcqMethodId)'] }
    * def v = call createLatePiece { orgId: '#(orgId)', poNumber: '66621', poLineNumber: '66621-1', acqMethodId: '#(globalApprovalPlanAcqMethodId)', pieceId: '#(pieceId)', currentDate: '#(currentDate)' }

    # 2. Claim → 422 before any write
    Given path 'pieces/claim'
    And request { claimingPieceIds: ['#(pieceId)'], claimingInterval: 1 }
    When method POST
    Then status 422
    And match response.errors[0].code == 'unableToGenerateClaimsForOrgNoIntegrationDetails'

    # 3. The piece is still Late and no job was created for the config
    Given path 'orders/pieces'
    And param query = 'id==' + pieceId
    When method GET
    Then status 200
    And match response.pieces[0].receivingStatus == 'Late'

    Given path 'data-export-spring/jobs'
    And param query = '(type==CLAIMS)'
    And param limit = 1000
    When method GET
    Then status 200
    And match jobsOfConfig(response.jobRecords, configPurchaseId) == []
