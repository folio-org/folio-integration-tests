Feature: Tests that searches by facet

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

    * def facet = function(id, totalRecords) {return read('classpath:samples/facet/facet.json');}
    * def facetValues = []

  @Ignore
  @SearchFacet
  Scenario: Can search by facet
    Given path '/search/instances/facets'
    And param query = 'cql.allRecords=1'
    And param facet = facetName
    When method GET
    Then status 200
    And def actualFacet = response.facets[facetName]
    Then match actualFacet.values contains facetValues


#   ================= Instance test cases =================

  Scenario: Can search by source facet
    * def facetName = "source"
    * facetValues[0] = facet("FOLIO", 1)
    * facetValues[1] = facet("MARC", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by instanceTypeId facet
    * def facetName = "instanceTypeId"
    * facetValues[0] = facet("6312d172-f0cf-40f6-b27d-9fa8feaf332f", 2)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by instanceFormatIds facet
    * def facetName = "instanceFormatIds"
    * facetValues[0] = facet("f5e8210f-7640-459b-a71f-552567f92369", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by modeOfIssuanceId facet
    * def facetName = "modeOfIssuanceId"
    * facetValues[0] = facet("9d18a02f-5897-4c31-9106-c9abb5c7ae8b", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by natureOfContentTermIds facet
    * def facetName = "natureOfContentTermIds"
    * facetValues[0] = facet("85657646-6b6f-4e71-b54c-d47f3b95a5ed", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by languages facet
    * def facetName = "languages"
    * facetValues[0] = facet("eng", 2)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by instanceTags facet
    * def facetName = "instanceTags"
    * facetValues[0] = facet("book", 1)
    * facetValues[1] = facet("electronic", 1)
    * facetValues[1] = facet("electronic book", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by staffSuppress facet
    * def facetName = "staffSuppress"
    * facetValues[0] = facet("false", 2)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by discoverySuppress facet
    * def facetName = "discoverySuppress"
    * facetValues[0] = facet("false", 2)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by statisticalCodes facet
    * def facetName = "statisticalCodes"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 2)
    * call read('facet-search.feature@SearchFacet')


#   ================= Holdings test cases =================

  Scenario: Can search by holdings.permanentLocationId facet
    * def facetName = "holdings.permanentLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 2)
    * facetValues[0] = facet("758258bc-ecc1-41b8-abca-f7b610822ffd", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by holdings.discoverySuppress facet
    * def facetName = "holdings.discoverySuppress"
    * facetValues[0] = facet("false", 2)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by holdings.sourceId facet
    * def facetName = "holdings.sourceId"
    * facetValues[0] = facet("f32d531e-df79-46b3-8932-cdd35f7a2264", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by holdingTags facet
    * def facetName = "holdingTags"
    * facetValues[0] = facet("bound-with", 1)
    * call read('facet-search.feature@SearchFacet')


#   ================= Item test cases =================

  Scenario: Can search by items.effectiveLocationId facet
    * def facetName = "items.effectiveLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by items.status.name facet
    * def facetName = "items.status.name"
    * facetValues[0] = facet("Available", 1)
    * facetValues[0] = facet("Checked out", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by items.materialTypeId facet
    * def facetName = "items.materialTypeId"
    * facetValues[0] = facet("1a54b431-2e4f-452d-9cae-9cee66c9a892", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by items.discoverySuppress facet
    * def facetName = "items.discoverySuppress"
    * facetValues[0] = facet("false", 1)
    * call read('facet-search.feature@SearchFacet')

  Scenario: Can search by itemTags facet
    * def facetName = "itemTags"
    * facetValues[0] = facet("urgent", 1)
    * call read('facet-search.feature@SearchFacet')