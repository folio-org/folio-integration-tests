Feature: Create Work connected to Hubs as subjects via API
  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Hubs as subjects of a Work
    # Import two hubs into graph from LoC
    * configure headers = testUserHeaders
    * def hub1Uri = 'https://id.loc.gov/resources/hubs/4c7da18e-2f52-7f49-5405-0ca7a4c621ff.json'
    * def hub2Uri = 'https://id.loc.gov/resources/hubs/ca1e29ad-fc4a-07c4-435f-756b50ddfa15.json'
    * def importHubCall = call importHub { hubUri: '#(hub1Uri)' }
    * def importHubCall = call importHub { hubUri: '#(hub2Uri)' }

    * def query = 'label="Owen, Jerry"'
    * def searchHubCall = call searchLinkedDataHub
    * def hub1Id = searchHubCall.response.content[0].id

    * def query = 'label="Inglott, William"'
    * def searchHubCall = call searchLinkedDataHub
    * def hub2Id = searchHubCall.response.content[0].id

    # Create a Work with the two Hubs as subjects
    * def workRequest =
    """
    {
      "resource":{
        "http://bibfra.me/vocab/lite/Work":{
          "http://bibfra.me/vocab/library/title":[
            {
              "http://bibfra.me/vocab/library/Title":{
                "http://bibfra.me/vocab/library/mainTitle":[ "hub-as-subject-work" ]
              }
            }
          ],
          "http://bibfra.me/vocab/lite/subject":[
            { "id":"#(hub1Id)" },
            { "id":"#(hub2Id)" }
          ],
          "profileId":"2"
        }
      }
    }
    """

    * def postWorkCall = call postResource { resourceRequest: '#(workRequest)' }
    * def subjects = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work']['http://bibfra.me/vocab/lite/subject']
    * match subjects == '#[2]'
    * match subjects contains deep { label: 'Owen, Jerry, 1944-. Works', types: ['http://bibfra.me/vocab/lite/Concept', 'http://bibfra.me/vocab/lite/Hub'] }
    * match subjects contains deep { label: 'Inglott, William, 1554-1621. Short service. Magnificat', types: ['http://bibfra.me/vocab/lite/Concept', 'http://bibfra.me/vocab/lite/Hub'] }

    # Verify the shape of the graph
    * def owenSubject = subjects.filter(x => x.label == 'Owen, Jerry, 1944-. Works')[0]
    * match owenSubject != null
    * def owenSubjectId = owenSubject.id
    * def owenSubjectGraphCall = call getResourceGraph { resourceId: '#(owenSubjectId)' }
    * def owenSubjectGraph = owenSubjectGraphCall.response
    * def focusEdgeToHub1 = owenSubjectGraph.outgoingEdges.filter(x => x.predicate && x.predicate.toLowerCase() == 'focus' && ('' + resolveSubgraphIfId(x.target).id) == ('' + hub1Id))[0]
    * match focusEdgeToHub1 != null

    * def hubGraphCall = call getResourceGraph { resourceId: '#(hub1Id)' }
    * def hubGraph = hubGraphCall.response
    * match hubGraph.label == 'Owen, Jerry, 1944-. Works'
    * match hubGraph.doc['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/resources/hubs/4c7da18e-2f52-7f49-5405-0ca7a4c621ff'
    * match hubGraph.doc['http://bibfra.me/vocab/lite/label'][0] == 'Owen, Jerry, 1944-. Works'

    * def creatorEdge = hubGraph.outgoingEdges.filter(x => x.predicate == 'CREATOR')[0]
    * match creatorEdge != null
    * def creatorTarget = resolveSubgraphIfId(creatorEdge.target)
    * match creatorTarget.label == 'Owen, Jerry, 1944-'
    * match creatorTarget.types contains 'PERSON'
    * match creatorTarget.doc['http://bibfra.me/vocab/lite/name'][0] == 'Owen, Jerry, 1944-'
    * match creatorTarget.doc['http://bibfra.me/vocab/lite/label'][0] == 'Owen, Jerry, 1944-'

    * def titleEdge = hubGraph.outgoingEdges.filter(x => x.predicate == 'TITLE')[0]
    * match titleEdge != null
    * def titleTarget = resolveSubgraphIfId(titleEdge.target)
    * match titleTarget.label == 'Works'
    * match titleTarget.types contains 'TITLE'
    * match titleTarget.doc['http://bibfra.me/vocab/library/mainTitle'][0] == 'Works'

    # Create an Instance linked to the created Work
    * def workId = postWorkCall.response.resource['http://bibfra.me/vocab/lite/Work'].id
    * def instanceRequest =
    """
    {
      "resource":{
        "http://bibfra.me/vocab/lite/Instance":{
          "profileId": 3,
          "http://bibfra.me/vocab/library/title":[
            {
              "http://bibfra.me/vocab/library/Title":{
                "http://bibfra.me/vocab/library/mainTitle":[
                  "hub-as-subject-instance"
                ]
              }
            }
          ],
          "_workReference":[
            {
              "id":"#(workId)"
            }
          ]
        }
      }
    }
    """
    * def postInstanceCall = call postResource { resourceRequest: '#(instanceRequest)' }
    * def instanceId = postInstanceCall.response.resource['http://bibfra.me/vocab/lite/Instance'].id

    # Derive the marc record for the instance
    * def derivedMarcCall = call getDerivedMarc { resourceId: '#(instanceId)' }
    * match derivedMarcCall.response != null
    * def fields = derivedMarcCall.response.parsedRecord.content.fields
    * match fields contains { 600: { subfields: [ { a: 'Owen, Jerry, 1944-' }, { t: 'Works' } ], ind1: ' ', ind2: ' ' } }
    * match fields contains { 600: { subfields: [ { a: 'Inglott, William, 1554-1621' }, { t: 'Magnificat and Nunc dimittis' } ], ind1: ' ', ind2: ' ' } }
