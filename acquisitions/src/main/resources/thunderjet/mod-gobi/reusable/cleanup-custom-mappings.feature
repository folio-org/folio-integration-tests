@ignore
Feature: Delete every GOBI custom mapping the mod-gobi suite installs
  # No parameters. Tolerant of order types that have no custom mapping.
  # Used by gobi.feature, where the per-feature `configure afterScenario` cleanups never fire
  # because Karate skips those hooks for called features (see gobi.feature for details).

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Delete Custom Mappings Tolerantly
    * call login testUser
    * def deleteMapping = read('classpath:thunderjet/mod-gobi/reusable/delete-custom-mapping.feature')
    * call deleteMapping [{ orderType: 'UnlistedPrintMonograph' }, { orderType: 'UnlistedPrintSerial' }, { orderType: 'ListedElectronicMonograph' }]