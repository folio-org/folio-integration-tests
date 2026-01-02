Feature: Verify graph

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Validate Admin metadata
    * def instanceGraphCall = call getResourceGraph { resourceId:  '#(instanceId)' }
    * def instanceGraph = instanceGraphCall.response

    * def adminMetadataId = instanceGraph.outgoingEdges.filter(x => x.predicate == 'ADMIN_METADATA')[0].target.id
    * def adminMetadataGraphCall = call getResourceGraph { resourceId:  '#(adminMetadataId)' }
    * def adminMetadataGraph = adminMetadataGraphCall.response
    * retry until karate.exists(adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber']) == true
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber'][0] == hrid
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/modifyingAgency'] == ['LC', 'AGR']
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/catalogingAgency'][0] == 'DLC'
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/transcribingAgency'][0] == 'LoC'

    * def catalogingLanguageId = adminMetadataGraph.outgoingEdges.filter(x => x.predicate == 'CATALOGING_LANGUAGE')[0].target.id
    * def catalogingLanguageGraphCall = call getResourceGraph { resourceId:  '#(catalogingLanguageId)' }
    * def catalogingLanguageGraph = catalogingLanguageGraphCall.response
    * match catalogingLanguageGraph.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/languages/eng'
    * match catalogingLanguageGraph.doc['http://bibfra.me/vocab/library/code'][0] == 'eng'
    * match catalogingLanguageGraph.doc['http://bibfra.me/vocab/library/term'][0] == 'English'

  @C831966
  Scenario: Validate created date
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/lite/createdDate'][0] == currentDate

  @C476863
  Scenario: Validate media type
    * def mediaEdge = instanceGraph.outgoingEdges.find(x => x.predicate == 'MEDIA')
    * match mediaEdge != null
    * def mediaTarget = mediaEdge.target
    * match mediaTarget.types contains 'CATEGORY'
    * match mediaTarget.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/mediaTypes/z'
    * match mediaTarget.doc['http://bibfra.me/vocab/library/code'][0] == 'z'
    * match mediaTarget.doc['http://bibfra.me/vocab/library/term'][0] == 'unspecified'
    * def mediaCategorySetEdge = mediaTarget.outgoingEdges.find(x => x.predicate == 'IS_DEFINED_BY')
    * match mediaCategorySetEdge != null
    * def mediaCategorySet = mediaCategorySetEdge.target
    * match mediaCategorySet.types contains 'CATEGORY_SET'
    * match mediaCategorySet.label == 'rdamedia'
    * match mediaCategorySet.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/genreFormSchemes/rdamedia'
    * match mediaCategorySet.doc['http://bibfra.me/vocab/lite/label'][0] == 'rdamedia'

  @C476864
  Scenario: Validate carrier type
    * def carrierEdge = instanceGraph.outgoingEdges.find(x => x.predicate == 'CARRIER')
    * match carrierEdge != null
    * def carrierTarget = carrierEdge.target
    * match carrierTarget.types contains 'CATEGORY'
    * match carrierTarget.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/carriers/sb'
    * match carrierTarget.doc['http://bibfra.me/vocab/library/code'][0] == 'sb'
    * match carrierTarget.doc['http://bibfra.me/vocab/library/term'][0] == 'audio belt'
    * def carrierCategorySetEdge = carrierTarget.outgoingEdges.find(x => x.predicate == 'IS_DEFINED_BY')
    * match carrierCategorySetEdge != null
    * def carrierCategorySet = carrierCategorySetEdge.target
    * match carrierCategorySet.types contains 'CATEGORY_SET'
    * match carrierCategorySet.label == 'rdacarrier'
    * match carrierCategorySet.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/genreFormSchemes/rdacarrier'
    * match carrierCategorySet.doc['http://bibfra.me/vocab/lite/label'][0] == 'rdacarrier'
