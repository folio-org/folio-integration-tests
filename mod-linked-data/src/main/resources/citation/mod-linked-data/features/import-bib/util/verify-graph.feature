Feature: Verify Linked Data Graph
  Scenario: Fetch Instance Subgraph
    * def instanceResourceIdCall = call getResourceIdFromInventoryId { inventoryId:  '#(inventoryInstanceIdFromSearchResponse)' }
    * def instanceResourceId = instanceResourceIdCall.response.id
    * def subgraphCall = call getResourceGraph { resourceId: '#(instanceResourceId)' }
    * def instanceSubgraph = subgraphCall.response
    * def workSubgraph = instanceSubgraph.outgoingEdges.filter(x => x.predicate == 'INSTANTIATES')[0].target

  @C446125
  Scenario: Verify Creator of Work (MARC 100)
    * def creatorSubgraph = resolveSubgraphIfId(workSubgraph.outgoingEdges.filter(x => x.predicate == 'CREATOR')[0].target)
    * def authorSubgraph = resolveSubgraphIfId(workSubgraph.outgoingEdges.filter(x => x.predicate == 'AUTHOR')[0].target)
    * match creatorSubgraph.label == 'Edgell, David L., Sr., David Lee, 1938'
    * match creatorSubgraph.doc == { "http://bibfra.me/vocab/lite/date": ["1938-"], "http://bibfra.me/vocab/lite/name": ["Edgell, David L."], "http://bibfra.me/vocab/lite/label":["Edgell, David L., Sr., David Lee, 1938"], "http://bibfra.me/vocab/library/titles": ["Sr."], "http://bibfra.me/vocab/lite/nameAlternative": ["David Lee"] }
    * match creatorSubgraph.types == [ 'PERSON' ]
    * match authorSubgraph.id == creatorSubgraph.id
    * match authorSubgraph.label == creatorSubgraph.label
    * match authorSubgraph.doc == creatorSubgraph.doc
    * match authorSubgraph.types == creatorSubgraph.types

  @C446125
  Scenario: Verify Contributors of Work - Person & Family (MARC 700)
    * def contributorSubgraphs = workSubgraph.outgoingEdges.filter(x => x.predicate == 'CONTRIBUTOR').map(x => resolveSubgraphIfId(x.target))
    * def actualLabels = contributorSubgraphs.map(x => x.label)
    * match actualLabels contains 'Rinehart family, Rinehart, Family Rinehart'
    * match actualLabels contains 'VI, Edward, King of England, 1537-1553'
    * match actualLabels contains 'Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :'
    * match actualLabels contains 'International Business Engineering Conference, 2018, Legian, Bali, Indonesia'

    * def family = contributorSubgraphs.filter(x => x.label == 'Rinehart family, Rinehart, Family Rinehart')[0]
    * match family.doc == { "http://bibfra.me/vocab/lite/name": ["Rinehart family"], "http://bibfra.me/vocab/lite/label":["Rinehart family, Rinehart, Family Rinehart"], "http://bibfra.me/vocab/library/titles": ["Rinehart"], "http://bibfra.me/vocab/lite/nameAlternative": ["Family Rinehart"] }
    * match family.types == [ 'FAMILY' ]

    * def person = contributorSubgraphs.filter(x => x.label == 'VI, Edward, King of England, 1537-1553')[0]
    * match person.doc == { "http://bibfra.me/vocab/lite/date": ["1537-1553"], "http://bibfra.me/vocab/lite/name": ["Edward"],  "http://bibfra.me/vocab/lite/label": ["VI, Edward, King of England, 1537-1553"], "http://bibfra.me/vocab/library/titles": ["King of England"], "http://bibfra.me/vocab/library/numeration": ["VI"] }
    * match person.types == [ 'PERSON' ]

  @C446172
  Scenario: Verify Contributors of Work - Organization (MARC 710)
    * def organization = contributorSubgraphs.filter(x => x.label == 'Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :')[0]
    * match organization.doc == { "http://bibfra.me/vocab/lite/date": ["2017 :"], "http://bibfra.me/vocab/lite/name": ["Horror Writers Association"], "http://bibfra.me/vocab/lite/label": ["Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :"], "http://bibfra.me/vocab/library/place": ["Long Beach, Calif.)"], "http://bibfra.me/vocab/library/numberOfParts": ["(1st :"], "http://bibfra.me/vocab/library/subordinateUnit": ["Ann Radcliffe Academic"] }
    * match organization.types == [ 'ORGANIZATION' ]

  @C446172
  Scenario: Verify Contributors of Work - Meeting (MARC 711)
    * def meeting = contributorSubgraphs.filter(x => x.label == 'International Business Engineering Conference, 2018, Legian, Bali, Indonesia')[0]
    * match meeting.doc == { "http://bibfra.me/vocab/lite/date": ["2018"], "http://bibfra.me/vocab/lite/name": ["International Business Engineering Conference"], "http://bibfra.me/vocab/lite/label": ["International Business Engineering Conference, 2018, Legian, Bali, Indonesia"], "http://bibfra.me/vocab/library/place": ["Legian, Bali, Indonesia"], "http://bibfra.me/vocab/library/numberOfParts": ["2nd"] }
    * match meeting.types == [ 'MEETING' ]

  @C740246
  Scenario: Verify dimension, physical description and accompanying material
    * match instanceSubgraph.doc['http://bibfra.me/vocab/library/dimensions'] == ['31 cm +']
    * match instanceSubgraph.doc['http://bibfra.me/vocab/library/physicalDescription'] == ['illustrations']
    * match instanceSubgraph.doc['http://bibfra.me/vocab/library/accompanyingMaterial'] == ['1 computer disc (illustrations ; 4 3/4 in.)']

  @C535522
  Scenario: Verify extent (MARC 300)
    * def extentEdge = instanceSubgraph.outgoingEdges.filter(x => x.predicate == 'EXTENT')[0]
    * match extentEdge.target.label == '2 volumes'
    * match extentEdge.target.doc == { "http://bibfra.me/vocab/lite/label": ["2 volumes"], "http://bibfra.me/vocab/library/materialsSpecified": ["book"] }
    * match extentEdge.target.types == ['EXTENT']

  @C476844
  Scenario: Verify statement of responsibility (MARC 245 $c)
    * match instanceSubgraph.doc['http://bibfra.me/vocab/library/statementOfResponsibility'] == ['by Ernest Poole']

  @C736688
  Scenario: Verify admin history, biog data & note (MARC 545)
    * match instanceSubgraph.doc['http://bibfra.me/vocab/library/biogdata'] == ['Florence Mardirosian was American choral conductor of Armenian decent.']
    * match instanceSubgraph.doc['http://bibfra.me/vocab/library/adminhist'] == ['Co-published with the Australian War Memorial.']
    * match instanceSubgraph.doc['http://bibfra.me/vocab/lite/note'] contains 'Abstract also in English.'

  @C958464
  Scenario: Verify Hub created from MARC 600
    # 1. Find the SUBJECT edge with the expected label
    * def subjectEdgeMarc600 = workSubgraph.outgoingEdges.filter(x => x.predicate == 'SUBJECT' && x.target.label == 'Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin -- Drama -- Parodies, imitations, etc')[0]
    * def subjectMarc600 = subjectEdgeMarc600.target

    # Verify subject label and doc
    * match subjectMarc600.label == 'Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin -- Drama -- Parodies, imitations, etc'
    * match subjectMarc600.doc['http://bibfra.me/vocab/lite/name'][0] == 'Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin'
    * match subjectMarc600.doc['http://bibfra.me/vocab/lite/label'][0] == 'Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin -- Drama -- Parodies, imitations, etc'
    * match subjectMarc600.doc['http://bibfra.me/vocab/lite/language'][0] == 'German & Latin'
    * match subjectMarc600.doc['http://bibfra.me/vocab/library/formSubdivision'][0] == 'Drama'
    * match subjectMarc600.doc['http://bibfra.me/vocab/library/generalSubdivision'][0] == 'Parodies, imitations, etc'
    * match subjectMarc600.types contains 'CONCEPT'
    * match subjectMarc600.types contains 'HUB'

    # Verify SUB_FOCUS edges
    * def subFocusLabelsMarc600 = subjectMarc600.outgoingEdges.filter(x => x.predicate == 'SUB_FOCUS').map(x => x.target.label)
    * match subFocusLabelsMarc600 contains 'Drama'
    * match subFocusLabelsMarc600 contains 'Parodies, imitations, etc'

    # Verify FOCUS edge
    * def focusEdgeMarc600 = subjectMarc600.outgoingEdges.filter(x => x.predicate == 'FOCUS')[0]
    * def focusMarc600 = focusEdgeMarc600.target
    * match focusMarc600.label == 'Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin'
    * match focusMarc600.doc['http://bibfra.me/vocab/lite/label'][0] == 'Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin'
    * match focusMarc600.doc['http://bibfra.me/vocab/lite/language'][0] == 'German & Latin'
    * match focusMarc600.types contains 'HUB'

    # Verify TITLE edge from FOCUS
    * def titleEdgeMarc600 = focusMarc600.outgoingEdges.filter(x => x.predicate == 'TITLE')[0]
    * def titleMarc600 = titleEdgeMarc600.target
    * match titleMarc600.label == 'Medea'
    * match titleMarc600.doc['http://bibfra.me/vocab/library/mainTitle'][0] == 'Medea'
    * match titleMarc600.types contains 'TITLE'

    # Verify CREATOR edge from FOCUS
    * def creatorEdgeMarc600 = focusMarc600.outgoingEdges.filter(x => x.predicate == 'CREATOR')[0]
    * def creatorMarc600 = creatorEdgeMarc600.target
    * match creatorMarc600.label == 'Dracontius, Blossius Aemilius, active 5th century'
    * match creatorMarc600.doc['http://bibfra.me/vocab/lite/name'][0] == 'Dracontius, Blossius Aemilius'
    * match creatorMarc600.doc['http://bibfra.me/vocab/lite/date'][0] == 'active 5th century'
    * match creatorMarc600.types contains 'PERSON'
