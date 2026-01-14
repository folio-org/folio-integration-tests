Feature: Import Bibframe2 RDF - Verify graph

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Validate HRID and created Date
    * def instanceGraphCall = call getResourceGraph
    * def instanceGraph = instanceGraphCall.response
    * def workGraph = instanceGraph.outgoingEdges.filter(x => x.predicate == 'INSTANTIATES')[0].target

    * def adminMetadataId = instanceGraph.outgoingEdges.filter(x => x.predicate == 'ADMIN_METADATA')[0].target.id
    * def adminMetadataGraphCall = call getResourceGraph { resourceId:  '#(adminMetadataId)' }
    * def adminMetadataGraph = adminMetadataGraphCall.response
    * retry until karate.exists(adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber']) == true
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/lite/createdDate'][0] == currentDate
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber'][0] == hrid

  @C805751
  Scenario: Validate subjects of Work
    * def subjectGraphs = workGraph.outgoingEdges.filter(x => x.predicate == 'SUBJECT').map(x => x.target)

    * def validateSubjectGraph =
    """
    function(subjectGraphs, label, conceptDoc, focusType, focusTargetDoc, focusLccn) {
      var subject = subjectGraphs.filter(x => x.label == label)[0];
      assertTrue(subject != null);
      assertMatch(subject.doc, conceptDoc);
      assertTrue(subject.types.length === 2 && subject.types.includes("CONCEPT") && subject.types.includes(focusType));
      var focusEdge = subject.outgoingEdges.filter(x => x.predicate == 'FOCUS')[0];
      assertTrue(focusEdge != null);
      var target = resolveSubgraphIfId(focusEdge.target);
      assertTrue(target.types.length === 1 && target.types.includes(focusType));
      assertMatch(target.doc, focusTargetDoc);
      if (focusLccn) {
        var lccnEdge = target.outgoingEdges.filter(x => x.predicate == 'MAP')[0];
        assertTrue(lccnEdge != null);
        var lccnTarget = resolveSubgraphIfId(lccnEdge.target);
        assertMatch(lccnTarget.label, focusLccn.label);
        assertTrue(focusLccn.types.every(x => lccnTarget.types.includes(x)));
        assertMatch(lccnTarget.doc, focusLccn.doc);
      }
    }
    """
    # Validate Middle East subject
    * def middleEastDoc = { 'http://bibfra.me/vocab/lite/name': ['Middle East'], 'http://bibfra.me/vocab/lite/label': ['Middle East'] }
    * eval validateSubjectGraph(subjectGraphs, 'Middle East', middleEastDoc, 'PLACE', middleEastDoc, null)

    # Validate Austria (AT) subject
    * def austriaDoc = { 'http://bibfra.me/vocab/lite/name': ['Austria (AT)'], 'http://bibfra.me/vocab/lite/label': ['Austria (AT), Austria'] }
    * def austriaFocusTargetDoc = { 'http://bibfra.me/vocab/lite/name': ['Austria (AT)'], 'http://bibfra.me/vocab/lite/label': ['Austria (AT)', 'Austria'] }
    * eval validateSubjectGraph(subjectGraphs, 'Austria (AT), Austria', austriaDoc, 'PLACE', austriaFocusTargetDoc, null)

    # Validate Delaware. General Assembly. subject
    * def delawareDoc = { 'http://bibfra.me/vocab/lite/name': ['Delaware. General Assembly. House of representatives.'], 'http://bibfra.me/vocab/lite/label': ['Delaware. General Assembly., Delaware. General Assembly. House of representatives.'] }
    * def delawareTargetDoc = { 'http://bibfra.me/vocab/lite/name': ['Delaware. General Assembly. House of representatives.'], 'http://bibfra.me/vocab/lite/label': ['Delaware. General Assembly.', 'Delaware. General Assembly. House of representatives.'] }
    * eval validateSubjectGraph(subjectGraphs, 'Delaware. General Assembly., Delaware. General Assembly. House of representatives.', delawareDoc, 'JURISDICTION', delawareTargetDoc, null)

    # Validate Readers (Primary) subject with LCCN
    * def readersDoc = { 'http://bibfra.me/vocab/lite/name': ['Readers (Primary)'], 'http://bibfra.me/vocab/lite/label': ['Readers (Primary)'] }
    * def readersTargetDoc = { 'http://bibfra.me/vocab/lite/name': ['Readers (Primary)'], 'http://bibfra.me/vocab/lite/label': ['Readers (Primary)'], 'http://library.link/vocab/resourcePreferred': ['true'] }
    * def readersLccn = { label: 'sh85111655', types: ['ID_LCSH'], doc: { 'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/sh85111655'], 'http://bibfra.me/vocab/lite/name': ['sh85111655'], 'http://bibfra.me/vocab/lite/label': ['sh85111655'] } }
    * eval validateSubjectGraph(subjectGraphs, 'Readers (Primary)', readersDoc, 'TOPIC', readersTargetDoc, readersLccn)

    # Validate Wang, Jack, 1972 subject with LCCN
    * def wangDoc = { 'http://bibfra.me/vocab/lite/date': ['1972-'], 'http://bibfra.me/vocab/lite/name': ['Wang, Jack'], 'http://bibfra.me/vocab/lite/label': ['Wang, Jack, 1972'] }
    * def wangTargetDoc = { 'http://bibfra.me/vocab/lite/label': ['Wang, Jack, 1972'], 'http://bibfra.me/vocab/lite/date': ['1972-'], 'http://bibfra.me/vocab/lite/name': ['Wang, Jack'], 'http://library.link/vocab/resourcePreferred': ['true'] }
    * def wangLccn = { label: 'no2012142443', types: ['ID_LCNAF'], doc: { 'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/no2012142443'], 'http://bibfra.me/vocab/lite/name': ['no2012142443'], 'http://bibfra.me/vocab/lite/label': ['no2012142443'] } }
    * eval validateSubjectGraph(subjectGraphs, 'Wang, Jack, 1972', wangDoc, 'PERSON', wangTargetDoc, wangLccn)

    # Validate Private flying -- Periodicals -- Accidents -- United States subject with LCCN and sub-focuses
    * def conceptDoc =
      """
      {
        'http://bibfra.me/vocab/lite/name': [ 'Private flying' ],
        'http://bibfra.me/vocab/lite/label': [ 'Private flying -- Periodicals -- Accidents -- United States' ],
        'http://library.link/vocab/resourcePreferred': [ 'true' ],
        'http://bibfra.me/vocab/library/formSubdivision': [ 'Periodicals' ],
        'http://bibfra.me/vocab/library/generalSubdivision': [ 'Accidents' ],
        'http://bibfra.me/vocab/library/geographicSubdivision': [ 'United States' ]
      }
      """
    * def focusDoc =
      """
      {
        'http://bibfra.me/vocab/lite/name': ['Private flying'],
        'http://bibfra.me/vocab/lite/label': ['Private flying']
      }
      """
    * def lccnDoc =
      """
      {
      'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/sh2008001841'],
      'http://bibfra.me/vocab/lite/name': ['sh2008001841'],
      'http://bibfra.me/vocab/lite/label': ['sh2008001841']
      }
      """
    * eval validateSubjectGraph(subjectGraphs, 'Private flying -- Periodicals -- Accidents -- United States', conceptDoc, 'TOPIC', focusDoc, null)
    * def subject = subjectGraphs.filter(x => x.label == 'Private flying -- Periodicals -- Accidents -- United States')[0]
    * def subjectLccnDoc = subject.outgoingEdges.filter(x => x.predicate == 'MAP').map(x => x.target.doc)
    * def subFocusLabels = subject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS').map(x => x.target.label)
    * match subFocusLabels contains 'Accidents'
    * match subFocusLabels contains 'Periodicals'
    * match subFocusLabels contains 'United States'
    * match subjectLccnDoc contains lccnDoc
