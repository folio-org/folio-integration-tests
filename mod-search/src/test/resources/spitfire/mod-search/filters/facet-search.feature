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
    And def facetPath = karate.get('facetPath', facetName)
    And param query = 'cql.allRecords=1'
    And param facet = facetName
    When method GET
    Then status 200
    And def actualFacet = response.facets[facetPath]
    Then match facetValues contains actualFacet.values


#   ================= Instance test cases =================

  Scenario: Can search by source facet
    * def facetValues = []
    * def facetName = "source"
    * facetValues[0] = facet("FOLIO", 12)
    * facetValues[1] = facet("MARC", 3)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by instanceTypeId facet
    * def facetValues = []
    * def facetName = "instanceTypeId"
    * facetValues[0] = facet("6312d172-f0cf-40f6-b27d-9fa8feaf332f", 9)
    * facetValues[1] = facet("82689e16-629d-47f7-94b5-d89736cf11f2", 4)
    * facetValues[2] = facet("8105bd44-e7bd-487e-a8f2-b804a361d92f", 2)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by instanceFormatIds facet
    * def facetValues = []
    * def facetName = "instanceFormatIds"
    * facetValues[0] = facet("f5e8210f-7640-459b-a71f-552567f92369", 2)
    * facetValues[1] = facet("5bfb7b4f-9cd5-4577-a364-f95352146a56", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by modeOfIssuanceId facet
    * def facetValues = []
    * def facetName = "modeOfIssuanceId"
    * facetValues[0] = facet("9d18a02f-5897-4c31-9106-c9abb5c7ae8b", 2)
    * facetValues[1] = facet("068b5344-e2a6-40df-9186-1829e13cd344", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by natureOfContentTermIds facet
    * def facetValues = []
    * def facetName = "natureOfContentTermIds"
    * facetValues[0] = facet("85657646-6b6f-4e71-b54c-d47f3b95a5ed", 1)
    * facetValues[1] = facet("44cd89f3-2e76-469f-a955-cc57cb9e0395", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by languages facet
    * def facetValues = []
    * def facetName = "languages"
    * facetValues[0] = facet("eng", 2)
    * facetValues[1] = facet("ua", 2)
    * facetValues[2] = facet("cn", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by instanceTags facet
    * def facetValues = []
    * def facetName = "instanceTags"
    * facetValues[0] = facet("book", 1)
    * facetValues[1] = facet("electronic", 1)
    * facetValues[2] = facet("electronic book", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by staffSuppress facet
    * def facetValues = []
    * def facetName = "staffSuppress"
    * facetValues[0] = facet("false", 12)
    * facetValues[1] = facet("true", 3)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by discoverySuppress facet
    * def facetValues = []
    * def facetName = "discoverySuppress"
    * facetValues[0] = facet("false", 14)
    * facetValues[1] = facet("true", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by statisticalCodes facet
    * def facetValues = []
    * def facetName = "statisticalCodes"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 2)
    * facetValues[1] = facet("b2c0e100-0485-43f2-b161-3c60aac9f68a", 2)
    * facetValues[2] = facet("3abd6fc2-b3e4-4879-b1e1-78be41769fe3", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by statisticalCodeIds facet
    * def facetValues = []
    * def facetName = "statisticalCodeIds"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 1)
    * facetValues[1] = facet("b2c0e100-0485-43f2-b161-3c60aac9f68a", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by statusId facet
    * def facetValues = []
    * def facetName = "statusId"
    * facetValues[0] = facet("9634a5ab-9228-4703-baf2-4d12ebc77d56", 1)
    * facetValues[1] = facet("26f5208e-110a-4394-be29-1569a8c84a65", 1)
    * call read(searchFacet) {recordsType: 'instances'}

#   ================= Holdings test cases =================

  Scenario: Can search by holdings.permanentLocationId facet
    * def facetValues = []
    * def facetName = "holdings.permanentLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 15)
    * facetValues[1] = facet("758258bc-ecc1-41b8-abca-f7b610822ffd", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by holdings.discoverySuppress facet
    * def facetValues = []
    * def facetName = "holdings.discoverySuppress"
    * facetValues[0] = facet("false", 12)
    * facetValues[1] = facet("true", 4)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by holdings.statisticalCodeIds facet
    * def facetValues = []
    * def facetName = "holdings.statisticalCodeIds"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 2)
    * facetValues[1] = facet("3abd6fc2-b3e4-4879-b1e1-78be41769fe3", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by holdings.sourceId facet
    * def facetValues = []
    * def facetName = "holdings.sourceId"
    * facetValues[0] = facet("f32d531e-df79-46b3-8932-cdd35f7a2264", 11)
    * facetValues[1] = facet("036ee84a-6afd-4c3c-9ad3-4a12ab875f59", 3)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by holdingsTags facet
    * def facetValues = []
    * def facetName = "holdingsTags"
    * facetValues[0] = facet("bound-with", 2)
    * facetValues[1] = facet("urgent", 2)
    * facetValues[2] = facet("important", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by holdingsTypeId facet
    * def facetValues = []
    * def facetName = "holdingsTypeId"
    * facetValues[0] = facet("996f93e2-5b5e-4cf2-9168-33ced1f95eed", 5)
    * facetValues[1] = facet("e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae", 3)
    * facetValues[2] = facet("03c9c400-b9e3-4a07-ac0e-05ab470233ed", 2)
    * call read(searchFacet) {recordsType: 'instances'}

#   ================= Item test cases =================

  Scenario: Can search by item.effectiveLocationId facet
    * def facetValues = []
    * def facetName = "item.effectiveLocationId"
    * def facetPath = "items.effectiveLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 14)
    * facetValues[1] = facet("184aae84-a5bf-4c6a-85ba-4a7c73026cd5", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by item.status.name facet
    * def facetValues = []
    * def facetName = "item.status.name"
    * def facetPath = "items.status.name"
    * facetValues[0] = facet("Available", 14)
    * facetValues[1] = facet("Checked out", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by item.materialTypeId facet
    * def facetValues = []
    * def facetName = "item.materialTypeId"
    * def facetPath = "items.materialTypeId"
    * facetValues[0] = facet("1a54b431-2e4f-452d-9cae-9cee66c9a892", 11)
    * facetValues[1] = facet("615b8413-82d5-4203-aa6e-e37984cb5ac3", 3)
    * facetValues[2] = facet("5ee11d91-f7e8-481d-b079-65d708582ccc", 2)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by item.statisticalCodeIds facet
    * def facetValues = []
    * def facetName = "item.statisticalCodeIds"
    * def facetPath = "items.statisticalCodeIds"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 1)
    * facetValues[1] = facet("b2c0e100-0485-43f2-b161-3c60aac9f68a", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by item.discoverySuppress facet
    * def facetValues = []
    * def facetName = "item.discoverySuppress"
    * def facetPath = "items.discoverySuppress"
    * facetValues[0] = facet("false", 10)
    * facetValues[1] = facet("true", 5)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by itemTags facet
    * def facetValues = []
    * def facetName = "itemTags"
    * facetValues[0] = facet("urgent", 2)
    * facetValues[1] = facet("important", 1)
    * call read(searchFacet) {recordsType: 'instances'}


#   ================= Items test cases (Backward compatibility) =================

  Scenario: Can search by items.effectiveLocationId facet
    * def facetValues = []
    * def facetName = "items.effectiveLocationId"
    * facetValues[0] = facet("fcd64ce1-6995-48f0-840e-89ffa2288371", 14)
    * facetValues[1] = facet("184aae84-a5bf-4c6a-85ba-4a7c73026cd5", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by items.status.name facet
    * def facetValues = []
    * def facetName = "items.status.name"
    * facetValues[0] = facet("Available", 14)
    * facetValues[1] = facet("Checked out", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by items.materialTypeId facet
    * def facetValues = []
    * def facetName = "items.materialTypeId"
    * facetValues[0] = facet("1a54b431-2e4f-452d-9cae-9cee66c9a892", 11)
    * facetValues[1] = facet("615b8413-82d5-4203-aa6e-e37984cb5ac3", 3)
    * facetValues[2] = facet("5ee11d91-f7e8-481d-b079-65d708582ccc", 2)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by items.statisticalCodeIds facet
    * def facetValues = []
    * def facetName = "items.statisticalCodeIds"
    * facetValues[0] = facet("b5968c9e-cddc-4576-99e3-8e60aed8b0dd", 1)
    * facetValues[1] = facet("b2c0e100-0485-43f2-b161-3c60aac9f68a", 1)
    * call read(searchFacet) {recordsType: 'instances'}

  Scenario: Can search by items.discoverySuppress facet
    * def facetValues = []
    * def facetName = "items.discoverySuppress"
    * facetValues[0] = facet("false", 10)
    * facetValues[1] = facet("true", 5)
    * call read(searchFacet) {recordsType: 'instances'}


#   ================= Authority test cases =================

  Scenario: Can search by headingType facet
    * def facetValues = []
    * def facetName = "headingType"
    * facetValues[0] = facet("Personal Name", 6)
    * facetValues[1] = facet("Corporate Name", 6)
    * facetValues[2] = facet("Conference Name", 6)
    * facetValues[3] = facet("Geographic Name", 3)
    * facetValues[4] = facet("Uniform Title", 3)
    * facetValues[5] = facet("Topical", 3)
    * facetValues[6] = facet("Genre", 3)
    * call read(searchFacet) {recordsType: 'authorities'}

  Scenario: Can search by subjectHeadings facet
    * def facetValues = []
    * def facetName = "subjectHeadings"
    * facetValues[0] = facet("c", 18)
    * facetValues[1] = facet("a", 6)
    * facetValues[2] = facet("b", 6)
    * call read(searchFacet) {recordsType: 'authorities'}
