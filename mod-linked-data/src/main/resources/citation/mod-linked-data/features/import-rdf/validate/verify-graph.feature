Feature: Import Bibframe2 RDF - Verify graph

  Background:
    * url baseUrl
    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

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

  Scenario: Validate HRID and created Date
    * def instanceGraphCall = call getResourceGraph
    * def instanceGraph = instanceGraphCall.response
    * def workGraph = resolveSubgraphIfId(instanceGraph.outgoingEdges.filter(x => x.predicate == 'INSTANTIATES')[0].target)

    * def adminMetadataId = resolveSubgraphIfId(instanceGraph.outgoingEdges.filter(x => x.predicate == 'ADMIN_METADATA')[0].target).id
    * def adminMetadataGraphCall = call getResourceGraph { resourceId:  '#(adminMetadataId)' }
    * def adminMetadataGraph = adminMetadataGraphCall.response
    * retry until karate.exists(adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber']) == true
    * def currentDate = new java.text.SimpleDateFormat('yyyy-MM-dd').format(new java.util.Date())
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/lite/createdDate'][0] == currentDate
    * match adminMetadataGraph.doc['http://bibfra.me/vocab/library/controlNumber'][0] == hrid

  @C805751
  Scenario: Validate subjects of Work
    * def subjectGraphs = workGraph.outgoingEdges.filter(x => x.predicate == 'SUBJECT').map(x => resolveSubgraphIfId(x.target))

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
    * def readersTargetDoc = { 'http://bibfra.me/vocab/lite/name': ['Readers (Primary)'], 'http://bibfra.me/vocab/lite/label': ['Readers (Primary)'] }
    * def readersLccn = { label: 'sh85111655', types: ['ID_LCSH'], doc: { 'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/subjects/sh85111655'], 'http://bibfra.me/vocab/lite/name': ['sh85111655'], 'http://bibfra.me/vocab/lite/label': ['sh85111655'] } }
    * eval validateSubjectGraph(subjectGraphs, 'Readers (Primary)', readersDoc, 'TOPIC', readersTargetDoc, readersLccn)

    # Validate Wang, Jack, 1972 subject with LCCN
    * def wangDoc = { 'http://bibfra.me/vocab/lite/date': ['1972-'], 'http://bibfra.me/vocab/lite/name': ['Wang, Jack'], 'http://bibfra.me/vocab/lite/label': ['Wang, Jack, 1972'] }
    * def wangTargetDoc = { 'http://bibfra.me/vocab/lite/label': ['Wang, Jack, 1972'], 'http://bibfra.me/vocab/lite/date': ['1972-'], 'http://bibfra.me/vocab/lite/name': ['Wang, Jack'] }
    * def wangLccn = { label: 'no2012142443', types: ['ID_LCNAF'], doc: { 'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/names/no2012142443'], 'http://bibfra.me/vocab/lite/name': ['no2012142443'], 'http://bibfra.me/vocab/lite/label': ['no2012142443'] } }
    * eval validateSubjectGraph(subjectGraphs, 'Wang, Jack, 1972', wangDoc, 'PERSON', wangTargetDoc, wangLccn)

    # Validate Private flying -- Accidents -- United States -- Periodicals subject with LCCN and sub-focuses
    * def conceptDoc =
      """
      {
        'http://bibfra.me/vocab/lite/name': [ 'Private flying' ],
        'http://bibfra.me/vocab/lite/label': [ 'Private flying -- Accidents -- United States -- Periodicals' ],
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
      'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/subjects/sh2008001841'],
      'http://bibfra.me/vocab/lite/name': ['sh2008001841'],
      'http://bibfra.me/vocab/lite/label': ['sh2008001841']
      }
      """
    * eval validateSubjectGraph(subjectGraphs, 'Private flying -- Accidents -- United States -- Periodicals', conceptDoc, 'TOPIC', focusDoc, null)
    * def subject = subjectGraphs.filter(x => x.label == 'Private flying -- Accidents -- United States -- Periodicals')[0]
    * match subject.folioMetadata.inventoryId == '#notnull'
    * def subjectLccnDoc = subject.outgoingEdges.filter(x => x.predicate == 'MAP').map(x => resolveSubgraphIfId(x.target).doc)
    * def subFocusLabels = subject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS').map(x => resolveSubgraphIfId(x.target).label)
    * match subFocusLabels contains 'Accidents'
    * match subFocusLabels contains 'Periodicals'
    * match subFocusLabels contains 'United States'
    * match subjectLccnDoc contains lccnDoc

  @C986305
  Scenario: Validate blank node complex subject imported into graph
    # Validate Dyes and dyeing -- History -- Textile fibers -- Japan -- 19th century -- Exhibitions subject with flexible label order
    * def dyesSubject = subjectGraphs.filter(x => x.label.startsWith('Dyes and dyeing'))[0]
    * def dyesDoc = { 'http://bibfra.me/vocab/lite/name': ['Dyes and dyeing'], 'http://bibfra.me/vocab/lite/label': [#(dyesSubject.label)], 'http://bibfra.me/vocab/library/formSubdivision': ['Exhibitions'], 'http://bibfra.me/vocab/library/generalSubdivision': ['Textile fibers', 'History'], 'http://bibfra.me/vocab/library/geographicSubdivision': ['Japan'], 'http://bibfra.me/vocab/library/chronologicalSubdivision': ['19th century'] }

    * def dyesFocusDoc =
      """
      {
        "http://bibfra.me/vocab/lite/name": ["Dyes and dyeing"],
        "http://bibfra.me/vocab/lite/label": ["Dyes and dyeing"]
      }
      """
    * def dyesLccn = { label: 'sh85040281', types: ['ID_LCSH'], doc: { 'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/subjects/sh85040281'], 'http://bibfra.me/vocab/lite/name': ['sh85040281'], 'http://bibfra.me/vocab/lite/label': ['sh85040281'] } }
    * eval validateSubjectGraph(subjectGraphs, dyesSubject.label, dyesDoc, 'TOPIC', dyesFocusDoc, dyesLccn)

    # Validate 'Textile fibers' subfocus
    * def textileFibersTarget = resolveSubgraphIfId(dyesSubject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS' && resolveSubgraphIfId(x.target).label == 'Textile fibers')[0].target)
    * match textileFibersTarget.doc == { "http://bibfra.me/vocab/lite/name": ["Textile fibers"], "http://bibfra.me/vocab/lite/label": ["Textile fibers"] }
    * match textileFibersTarget.types contains 'TOPIC'

    # Validate  '19th century' subfocus
    * def nineteenthCenturyTarget = resolveSubgraphIfId(dyesSubject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS' && resolveSubgraphIfId(x.target).label == '19th century')[0].target)
    * match nineteenthCenturyTarget.doc == { "http://bibfra.me/vocab/lite/name": ["19th century"], "http://bibfra.me/vocab/lite/label": ["19th century"] }
    * match nineteenthCenturyTarget.types contains 'TEMPORAL'

    # Validate 'Exhibitions' subfocus
    * def exhibitionsTarget = resolveSubgraphIfId(dyesSubject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS' && resolveSubgraphIfId(x.target).label == 'Exhibitions')[0].target)
    * match exhibitionsTarget.doc == { "http://bibfra.me/vocab/lite/name": ["Exhibitions"], "http://bibfra.me/vocab/lite/label": ["Exhibitions"] }
    * match exhibitionsTarget.types contains 'FORM'

    # Validate 'History' subfocus
    * def historyTarget = resolveSubgraphIfId(dyesSubject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS' && resolveSubgraphIfId(x.target).label == 'History')[0].target)
    * match historyTarget.doc == { "http://bibfra.me/vocab/lite/name": ["History"], "http://bibfra.me/vocab/lite/label": ["History"] }
    * match historyTarget.types contains 'TOPIC'

    # Validate 'Japan' subfocus
    * def japanTarget = resolveSubgraphIfId(dyesSubject.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS' && resolveSubgraphIfId(x.target).label == 'Japan')[0].target)
    * match japanTarget.doc == { "http://bibfra.me/vocab/lite/name": ["Japan"], "http://bibfra.me/vocab/lite/label": ["Japan"] }
    * match japanTarget.types contains 'PLACE'
    # Validate Japan's connection to FAST authority record
    * def fastTarget = resolveSubgraphIfId(japanTarget.outgoingEdges.filter(x => x.predicate == 'MAP' && resolveSubgraphIfId(x.target).label == 'fst01204082')[0].target)
    * match fastTarget.doc == { "http://bibfra.me/vocab/lite/link": ["http://id.worldcat.org/fast/fst01204082"], "http://bibfra.me/vocab/lite/name": ["fst01204082"], "http://bibfra.me/vocab/lite/label": ["fst01204082"] }
    * match fastTarget.types contains 'ID_FAST'
    * match fastTarget.types contains 'IDENTIFIER'
