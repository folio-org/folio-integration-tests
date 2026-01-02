Feature: Import authority into graph

  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  * def validateAuthoritySubgraphSimple =
    """
    function(subgraph, expectedType, expectedDoc, expectedLabel, expectedOutgoingType, expectedOutgoingDoc, expectedOutgoingLabel) {
      assertTrue(subgraph.types && subgraph.types.includes(expectedType), 'Type mismatch: expected ' + expectedType + ', got ' + JSON.stringify(subgraph.types));
      for (var key in expectedDoc) {
        var actualArr = subgraph.doc[key] ? subgraph.doc[key] : undefined;
        var expectedArr = expectedDoc[key];
        assertMatch(actualArr, expectedArr, 'Doc field mismatch for ' + key + ': expected ' + JSON.stringify(expectedArr) + ', got ' + JSON.stringify(actualArr));
      }
      assertMatch(subgraph.label, expectedLabel, 'Label mismatch: expected ' + expectedLabel + ', got ' + subgraph.label);
      assertTrue(subgraph.outgoingEdges && subgraph.outgoingEdges.length > 0, 'No outgoing edges found');
      var outgoing = subgraph.outgoingEdges[0];
      var expectedTypes = ['IDENTIFIER', expectedOutgoingType];
      assertMatch(outgoing.target.types ? outgoing.target.types.sort() : [], expectedTypes.sort(), 'Outgoing types mismatch: expected ["IDENTIFIER", ' + expectedOutgoingType + '], got ' + JSON.stringify(outgoing.target.types));
      for (var key2 in expectedOutgoingDoc) {
        var actualOutgoingArr = outgoing.target.doc[key2] ? outgoing.target.doc[key2] : undefined;
        var expectedOutgoingArr = expectedOutgoingDoc[key2];
        assertMatch(actualOutgoingArr, expectedOutgoingArr, 'Outgoing doc field mismatch for ' + key2 + ': expected ' + JSON.stringify(expectedOutgoingArr) + ', got ' + JSON.stringify(actualOutgoingArr));
      }
      assertMatch(outgoing.target.label, expectedOutgoingLabel, 'Outgoing label mismatch: expected ' + expectedOutgoingLabel + ', got ' + outgoing.target.label);
      return true;
    }
    """

  @ignore
  @validateAuthortiySubgraph
  Scenario: Common authority subgraph validation
    * def params = __arg
    * configure headers = testAdminHeaders
    * def sourceRecordRequest = read(params.sourceRecordPath)
    * def postAuthorityCall = call postSourceRecordToStorage
    And match postAuthorityCall.response.qmRecordId == '#notnull'

    * def query = params.query
    * def searchAuthorityCall = call searchAuthority
    * def authorityId = searchAuthorityCall.response.authorities[0].id

    * configure headers = testUserHeaders
    * def authorityResourceIdCall = call getResourceIdFromInventoryId { inventoryId:  '#(authorityId)' }
    * def authorityResourceId = authorityResourceIdCall.response.id
    * def subgraphCall = call getResourceGraph { resourceId: '#(authorityResourceId)' }
    * def authoritySubgraph = subgraphCall.response
    * eval validateAuthoritySubgraphSimple(authoritySubgraph, params.expectedType, params.expectedDoc, params.expectedLabel, params.expectedOutgoingType, params.expectedOutgoingDoc, params.expectedOutgoingLabel)

  @C569567
  Scenario: create & verify meeting authortity - no $v, $x, $y or $z present
    * def params =
    """
    {
      sourceRecordPath: 'samples/authority_meeting.json',
      query: '(lccn="n2023009652")',
      expectedType: 'MEETING',
      expectedDoc: {
        'http://bibfra.me/vocab/lite/date': ['2015'],
        'http://bibfra.me/vocab/lite/name': ['Feria Internacional del Libro de La Paz'],
        'http://bibfra.me/vocab/lite/label': ['Feria Internacional del Libro de La Paz, 2015, La Paz, Bolivia'],
        'http://bibfra.me/vocab/library/place': ['La Paz, Bolivia'],
        'http://library.link/vocab/resourcePreferred': ['true'],
        'http://bibfra.me/vocab/library/numberOfParts': ['20th :']
      },
      expectedLabel: 'Feria Internacional del Libro de La Paz, 2015, La Paz, Bolivia',
      expectedOutgoingType: 'ID_LCCN',
      expectedOutgoingDoc: {
        'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/n2023009652'],
        'http://bibfra.me/vocab/lite/name': ['n2023009652'],
        'http://bibfra.me/vocab/lite/label': ['n2023009652']
      },
      expectedOutgoingLabel: 'n2023009652'
    }
    """
    * call read('authority-create.feature@validateAuthortiySubgraph') params

  @C553042
  Scenario: create & verify jurisdiction authortity - no $v, $x, $y or $z present
    * def params =
    """
    {
      sourceRecordPath: 'samples/authority_jurisdiction.json',
      query: '(lccn="n96085736")',
      expectedType: 'JURISDICTION',
      expectedDoc: {
        'http://bibfra.me/vocab/lite/name': ['Alaska'],
        'http://bibfra.me/vocab/lite/label': ['Alaska, Department of Natural Resources, Land Records Information Section'],
        'http://library.link/vocab/resourcePreferred': ['true'],
        'http://bibfra.me/vocab/library/subordinateUnit': ['Department of Natural Resources', 'Land Records Information Section']
      },
      expectedLabel: 'Alaska, Department of Natural Resources, Land Records Information Section',
      expectedOutgoingType: 'ID_LCCN',
      expectedOutgoingDoc: {
        "http://bibfra.me/vocab/lite/link": [ "http://id.loc.gov/authorities/n96085736" ],
        "http://bibfra.me/vocab/lite/name": [ "n96085736" ],
        "http://bibfra.me/vocab/lite/label": [ "n96085736" ]
      },
      expectedOutgoingLabel: 'n96085736'
    }
    """
    * call read('authority-create.feature@validateAuthortiySubgraph') params

  @C740215
  Scenario: create & verify place authortity - no $v, $x, $y or $z present
    * def params =
      """
      {
        sourceRecordPath: 'samples/authority_place.json',
        query: '(lccn="n79006873")',
        expectedType: 'PLACE',
        expectedDoc: {
          'http://bibfra.me/vocab/lite/name': ['Valley Forge (Pa.)'],
          'http://bibfra.me/vocab/lite/label': ['Valley Forge (Pa.)'],
          'http://library.link/vocab/resourcePreferred': ['true'],
        },
        expectedLabel: 'Valley Forge (Pa.)',
        expectedOutgoingType: 'ID_LCCN',
        expectedOutgoingDoc: {
          "http://bibfra.me/vocab/lite/link": [ "http://id.loc.gov/authorities/n79006873" ],
          "http://bibfra.me/vocab/lite/name": [ "n79006873" ],
          "http://bibfra.me/vocab/lite/label": [ "n79006873" ]
        },
        expectedOutgoingLabel: 'n79006873'
      }
      """
    * call read('authority-create.feature@validateAuthortiySubgraph') params
