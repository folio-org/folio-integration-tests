Feature: Create organization integration details
  # parameters: vendorId, tenantId?, configId?, configName?, transmissionMethod?, fileFormat?, accountNoList?, defaultAcquisitionMethods?, ftpFormat?

  Background:
    * url baseUrl

  Scenario: createOrgIntegrationDetails
    * def claimsConfig = karate.read('classpath:thunderjet/mod-data-export-spring/features/samples/export-claims/claims-export-config.json')
    * def config = karate.get('config', claimsConfig)

    * def tenantId = karate.get('tenantId', 'testTenant')
    * def configId = karate.get('configId', null)
    * def configName = karate.get('configName', 'testConfig')
    * def vendorId = karate.get('vendorId')
    * def transmissionMethod = karate.get('transmissionMethod', "File Download")
    * def fileFormat = karate.get('fileFormat', "EDI")
    * def accountNoList = karate.get('accountNoList', null)
    * def defaultAcquisitionMethods = karate.get('defaultAcquisitionMethods', [globalPurchaseAcqMethodId])
    * def ftpFormat = karate.get('ftpFormat', "FTP")
    * def serverAddress = (ftpFormat == "FTP" ? "" : "s") + ftpUrl

    * set config.tenantId = tenantId
    * set config.id = configId
    * set config.configName = configName
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.vendorId = vendorId
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.transmissionMethod = transmissionMethod
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.fileFormat = fileFormat
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.accountNoList = accountNoList
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediConfig.defaultAcquisitionMethods = defaultAcquisitionMethods
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.ftpFormat = ftpFormat
    * set config.exportTypeSpecificParameters.vendorEdiOrdersExportConfig.ediFtp.serverAddress = serverAddress

    Given path 'data-export-spring/configs'
    And request config
    When method POST
    Then status 201
