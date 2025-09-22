Feature: Admin metadata

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Validate Admin metadata
    * def instanceGraphCall = call getResourceGraph { resourceId:  '#(instanceId)' }
    * def instanceGraph = instanceGraphCall.response
    * retry until karate.exists(instanceGraph.outgoingEdges.edges['http://bibfra.me/vocab/library/adminMetadata']) == true
    * def adminMetadataId = instanceGraph.outgoingEdges.edges['http://bibfra.me/vocab/library/adminMetadata'][0]

    * def adminMetadataGraphCall = call getResourceGraph { resourceId:  '#(adminMetadataId)' }
    * def adminMetadataGraph = adminMetadataGraphCall.response
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/lite/createdDate'][0] == currentDate
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber'][0] == hrid
