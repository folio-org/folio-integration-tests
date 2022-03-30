Feature: Tests that searches by facet

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

    * def searchFacet = 'facet-search.feature@SearchFacet'

  @Ignore
  @SearchFacet
  Scenario: Can search by facet
    Given path '/search/'+recordsType+'/facets'
    And param query = 'cql.allRecords=1'
    And param facet = facetName
    When method GET
    Then status 200
    And def actualFacet = response.facets[facetName]
    Then match facetValues contains actualFacet.values


#   ================= Instance test cases =================

  Scenario: Can search by source facet
    * def facetValues = []
    * def facetName = "source"
    * facetValues[0] = facet("FOLIO", 14)
    * facetValues[1] = facet("MARC", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by instanceTypeId facet
    * def facetValues = []
    * def facetName = "instanceTypeId"
    * facetValues[0] = facet("6312d172-f0cf-40f6-b27d-9fa8feaf332f", 15)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by instanceFormatIds facet
    * def facetValues = []
    * def facetName = "instanceFormatIds"
    * facetValues[0] = facet("f5e8210f-7640-459b-a71f-552567f92369", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by modeOfIssuanceId facet
    * def facetValues = []
    * def facetName = "modeOfIssuanceId"
    * facetValues[0] = facet("9d18a02f-5897-4c31-9106-c9abb5c7ae8b", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by natureOfContentTermIds facet
    * def facetValues = []
    * def facetName = "natureOfContentTermIds"
    * facetValues[0] = facet("85657646-6b6f-4e71-b54c-d47f3b95a5ed", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by languages facet
    * def facetValues = []
    * def facetName = "languages"
    * facetValues[0] = facet("eng", 2)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by instanceTags facet
    * def facetValues = []
    * def facetName = "instanceTags"
    * facetValues[0] = facet("book", 1)
    * facetValues[1] = facet("electronic", 1)
    * facetValues[2] = facet("electronic book", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by staffSuppress facet
    * def facetValues = []
    * def facetName = "staffSuppress"
    * facetValues[0] = facet("false", 15)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by discoverySuppress facet
    * def facetValues = []
    * def facetName = "discoverySuppress"
    * facetValues[0] = facet("false", 14)
    * facetValues[1] = facet("true", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by statisticalCodes facet
    * def facetValues = []
    * def facetName = "statisticalCodes"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 2)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}


#   ================= Holdings test cases =================

  Scenario: Can search by holdings.permanentLocationId facet
    * def facetValues = []
    * def facetName = "holdings.permanentLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 15)
    * facetValues[1] = facet("758258bc-ecc1-41b8-abca-f7b610822ffd", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by holdings.discoverySuppress facet
    * def facetValues = []
    * def facetName = "holdings.discoverySuppress"
    * facetValues[0] = facet("false", 15)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by holdings.sourceId facet
    * def facetValues = []
    * def facetName = "holdings.sourceId"
    * facetValues[0] = facet("f32d531e-df79-46b3-8932-cdd35f7a2264", 14)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by holdingsTags facet
    * def facetValues = []
    * def facetName = "holdingsTags"
    * facetValues[0] = facet("bound-with", 2)
    * facetValues[1] = facet("urgent", 2)
    * facetValues[2] = facet("important", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}


#   ================= Item test cases =================

  Scenario: Can search by items.effectiveLocationId facet
    * def facetValues = []
    * def facetName = "items.effectiveLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 15)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by items.status.name facet
    * def facetValues = []
    * def facetName = "items.status.name"
    * facetValues[0] = facet("Available", 14)
    * facetValues[1] = facet("Checked out", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by items.materialTypeId facet
    * def facetValues = []
    * def facetName = "items.materialTypeId"
    * facetValues[0] = facet("1a54b431-2e4f-452d-9cae-9cee66c9a892", 11)
    * facetValues[1] = facet("615b8413-82d5-4203-aa6e-e37984cb5ac3", 3)
    * facetValues[2] = facet("5ee11d91-f7e8-481d-b079-65d708582ccc", 2)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by items.discoverySuppress facet
    * def facetValues = []
    * def facetName = "items.discoverySuppress"
    * facetValues[0] = facet("false", 15)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}

  Scenario: Can search by itemTags facet
    * def facetValues = []
    * def facetName = "itemTags"
    * facetValues[0] = facet("urgent", 2)
    * facetValues[1] = facet("important", 1)
    * call read(searchFacet) {recordsType: 'instances', facetValues: '#(facetValues)'}


#   ================= Authority test cases =================

  Scenario: Can search by headingType facet
    * def facetValues = []
    * def facetName = "headingType"
    * facetValues[0] = facet("Personal Name", 3)
    * facetValues[1] = facet("Corporate Name", 3)
    * facetValues[2] = facet("Conference Name", 3)
    * facetValues[3] = facet("Geographic Name", 3)
    * facetValues[4] = facet("Uniform Title", 3)
    * facetValues[5] = facet("Topical", 3)
    * facetValues[6] = facet("Genre", 3)
    * call read(searchFacet) {recordsType: 'authorities', facetValues: '#(facetValues)'}
