Feature: Admin metadata

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Validate Admin metadata
    * def instanceGraphCall = call getResourceGraph { resourceId:  '#(instanceId)' }
    * def instanceGraph = instanceGraphCall.response

    * def adminMetadataId = instanceGraph.outgoingEdges.edges['http://bibfra.me/vocab/marc/adminMetadata'][0]
    * def adminMetadataGraphCall = call getResourceGraph { resourceId:  '#(adminMetadataId)' }
    * def adminMetadataGraph = adminMetadataGraphCall.response
    * retry until karate.exists(adminMetadataGraph.doc['http://bibfra.me/vocab/marc/controlNumber']) == true
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/lite/createdDate'][0] == currentDate
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/marc/controlNumber'][0] == hrid
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/marc/modifyingAgency'] == ['LC', 'AGR']
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/marc/catalogingAgency'][0] == 'DLC'
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/marc/transcribingAgency'][0] == 'LoC'

    * def catalogingLanguageId = adminMetadataGraph.outgoingEdges.edges['http://bibfra.me/vocab/lite/catalogingLanguage'][0]
    * def catalogingLanguageGraphCall = call getResourceGraph { resourceId:  '#(catalogingLanguageId)' }
    * def catalogingLanguageGraph = catalogingLanguageGraphCall.response
    * match catalogingLanguageGraph.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/languages/eng'
    * match catalogingLanguageGraph.doc['http://bibfra.me/vocab/marc/code'][0] == 'eng'
    * match catalogingLanguageGraph.doc['http://bibfra.me/vocab/marc/term'][0] == 'English'