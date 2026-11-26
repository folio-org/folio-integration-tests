Feature: Import local KB package into mod-agreements
  # parameters: packageName, packageReference, packageSource, titleName
  # returns: packageId, pciId
  Background:
    * url baseUrl

  Scenario: Import local KB package
    Given path 'erm/packages/import'
    And request read('classpath:athena/mod-lists/features/samples/erm-package.json')
    When method POST
    Then status 200
    And match $.packageId == '#string'
    * def packageId = $.packageId

    Given path 'erm/pci'
    And param filters = 'pkg.id==' + packageId
    When method GET
    Then status 200
    And match $ == '#[1]'
    * def pciId = response[0].id
