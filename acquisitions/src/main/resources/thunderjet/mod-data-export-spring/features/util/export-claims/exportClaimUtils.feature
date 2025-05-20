@ignore
Feature: Init Data for Claims Export

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    # Replace these 2 lines to remove date and time constraints, but match with file ids
    * def interchangeHeaderRegexTemplte = "UNB\\+UNOC:3\\+LIB-EDI-CODE:31B\\+VENDOR-EDI-CODE:31B\\+\\d{6}:\\d{4}\\+{fileId}'"
    * def interchangeHeaderSampleTemplate = "UNB+UNOC:3+LIB-EDI-CODE:31B+VENDOR-EDI-CODE:31B+150125:1249+{fileId}'"
    * def orderDateRegex = "DTM\\+137:\\d{8}:102'"
    * def orderDateSample = "DTM+137:20250115:102'"

  @InitData
  Scenario: initData
    # parameters: orgId, orgCode, accountNo,
    #             configId, configName, transMeth, fileFormat, ftpFormat,
    #             poNumber, poLineNumber, pieceId, fundId, currentDate

    # 1. Create organization
    * def accounts = [{ name: "#(orgCode)_ACC", accountNo: "#(accountNo)", accountStatus: "Active" }]
    * table orgData
      | id    | code    | name    | accounts | isVendor |
      | orgId | orgCode | orgCode | accounts | true     |
    * callonce createOrganization orgData

    # 2. Create organization integration details
    * table orgIntegrationDetails
      | configId | configName | vendorId | transmissionMethod | fileFormat | ftpFormat | accountNoList    |
      | configId | configName | orgId    | transMeth          | fileFormat | ftpFormat | ["#(accountNo)"] |
    * callonce createIntegrationDetails orgIntegrationDetails

    # 3. Create order with order line and open order
    * def orderId = call uuid
    * def orderData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/order.json')
    Given path '/orders/composite-orders'
    And request orderData
    When method POST
    Then status 201

    * def poLineId = call uuid
    * def poLineData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/order-line.json')
    Given path '/orders/order-lines'
    And request poLineData
    When method POST
    Then status 201

    * def v = callonce openOrder { orderId: '#(orderId)' }

    # 4. Create title and piece
    * def titleId = call uuid
    * def titleData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/title.json')
    Given path '/orders/titles'
    And request titleData
    When method POST
    Then status 201

    * def pieceData = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/piece.json')
    Given path '/orders/pieces'
    And request pieceData
    When method POST
    Then status 201


  @VerifyFileContentCsv
  Scenario: verifyFileContentCsv
    # parameters: jobId, _poLineNumber, _currentDate

    * def fileLineSeparator = '\n'
    * def systemLineSeparator = java.lang.System.lineSeparator()
    * table replacements
      | regex            | newString     |
      | '{poLineNumber}' | _poLineNumber |
      | '{currentDate}'  | _currentDate  |
    * def expectedCsvFile = karate.readAsString('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/claims.csv')
    * def expectedCsv = replaceRegex(expectedCsvFile, replacements)
    * def expectedCsv = convertStringToLines(expectedCsv, systemLineSeparator)

    Given path 'data-export-spring/jobs', jobId, 'download'
    When method GET
    Then status 200
    And string actualCsvFile = response
    * def actualCsv = replaceRegex(actualCsvFile, replacements)
    * def actualCsv = convertStringToLines(actualCsv, fileLineSeparator)
    * match expectedCsv == actualCsv


  @VerifyFileContentEdi
  Scenario: verifyFileContentEdi
    # parameters: jobId, _jobName, _poNumber, _poLineNumber

    * def fileLineSeparator = '\n'
    * def systemLineSeparator = java.lang.System.lineSeparator()

    # Get correct regex pattern and sample for interchange header with actual file id (job name)
    * table interchangeReplacements
      | regex      | newString |
      | '{fileId}' | _jobName  |
    * def interchangeHeaderRegex = replaceRegex(interchangeHeaderRegexTemplte, interchangeReplacements)
    * def interchangeHeaderSample = replaceRegex(interchangeHeaderSampleTemplate, interchangeReplacements)
    * table replacements
      | regex                  | newString               |
      | '{fileId}'             | _jobName                |
      | '{poNumber}'           | _poNumber               |
      | '{poLineNumber}'       | _poLineNumber           |
      | interchangeHeaderRegex | interchangeHeaderSample |
      | orderDateRegex         | orderDateSample         |
    * def expectedEdiFile = karate.readAsString('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/claims.edi')
    * def expectedEdi = replaceRegex(expectedEdiFile, replacements)
    * def expectedEdi = convertStringToLines(expectedEdi, systemLineSeparator)

    Given path 'data-export-spring/jobs', jobId, 'download'
    When method GET
    Then status 200
    And string actualEdiFile = response
    * def actualEdi = replaceRegex(actualEdiFile, replacements)
    * def actualEdi = convertStringToLines(actualEdi, fileLineSeparator)
    * match expectedEdi == actualEdi


  @CreatePiecesForPoLine
  Scenario: createPiecesForPoLine
    # parameters: _poLineNumber, _pieceIds

    # 1. Get poLine by poLineNumber
    Given path 'orders/order-lines'
    And param query = 'poLineNumber=' + _poLineNumber
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def poLineId = response.poLines[0].id

    # 2. Get title by poLineId
    Given path 'orders/titles'
    And param query = 'poLineId=' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def titleId = response.titles[0].id

    # 3. Create 249 pieces for the poLine
    * def pieceIdsTable = karate.map(_pieceIds, p => { return { pieceId: p, poLineId: poLineId, titleId: titleId } })
    * def v = call createPiece pieceIdsTable

    # 4. Set pieces status to Late
    * def v = call updatePiecesBatchStatus { pieceIds: "#(_pieceIds)", receivingStatus: 'Late' }