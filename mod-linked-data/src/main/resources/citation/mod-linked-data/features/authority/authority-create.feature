Feature: Import authority into graph

  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  * def validateResource =
    """
    function(resource, expectedDoc, expectedLabel) {
      assertTrue(resource != null, 'Resource is null');
      for (var key2 in expectedDoc) {
        var actualValue = resource.doc[key2] ? resource.doc[key2] : undefined;
        var expectedValue = expectedDoc[key2];
        assertMatch(actualValue, expectedValue, 'Resource doc field mismatch for ' + key2 + ': expected ' + JSON.stringify(expectedValue) + ', got ' + JSON.stringify(actualValue));
      }
      assertMatch(resource.label, expectedLabel, 'Resource label mismatch: expected ' + expectedLabel + ', got ' + resource.label);
      return true;
    }
    """

  * def validateAuthoritySubgraphSimple =
    """
    function(subgraph, expectedType, expectedDoc, expectedLabel, identifiers) {
      assertTrue(subgraph.types && subgraph.types.includes(expectedType), 'Type mismatch: expected ' + expectedType + ', got ' + JSON.stringify(subgraph.types));
      validateResource(subgraph, expectedDoc, expectedLabel);
      assertTrue(subgraph.outgoingEdges && subgraph.outgoingEdges.length > 0, 'No outgoing edges found');
      identifiers.forEach((identifier, idx) => {
        var outgoing = subgraph.outgoingEdges.find(edge => {
          var types = edge.target.types || [];
          return edge.predicate == 'MAP' && types.includes('IDENTIFIER') && types.includes(identifier.identifierType) && types.length === 2;
        });
        validateResource(outgoing.target, identifier.identifierDoc, identifier.identifierLabel);
      });
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
    * eval validateAuthoritySubgraphSimple(authoritySubgraph, params.expectedType, params.expectedDoc, params.expectedLabel, params.identifiers)

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
      identifiers: [
        {
          identifierType: 'ID_LCNAF',
          identifierDoc: {
            'http://bibfra.me/vocab/lite/link': ['http://id.loc.gov/authorities/n2023009652'],
            'http://bibfra.me/vocab/lite/name': ['n2023009652'],
            'http://bibfra.me/vocab/lite/label': ['n2023009652']
          },
          identifierLabel: 'n2023009652'
        }, {
          identifierType: 'ID_LOCAL',
          identifierDoc: {
            'http://bibfra.me/vocab/lite/name': ['12111953'],
            'http://bibfra.me/vocab/lite/label': ['12111953']
          },
          identifierLabel: '12111953'
        }
      ]
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
      identifiers: [
        {
          identifierType: 'ID_LCNAF',
          identifierDoc: {
            "http://bibfra.me/vocab/lite/link": [ "http://id.loc.gov/authorities/n96085736" ],
            "http://bibfra.me/vocab/lite/name": [ "n96085736" ],
            "http://bibfra.me/vocab/lite/label": [ "n96085736" ]
          },
          identifierLabel: 'n96085736'
        }, {
          identifierType: 'ID_LOCAL',
          identifierDoc: {
            'http://bibfra.me/vocab/lite/name': ['3179428'],
            'http://bibfra.me/vocab/lite/label': ['3179428']
          },
          identifierLabel: '3179428'
        }
      ]
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
        identifiers: [
          {
            identifierType: 'ID_LCNAF',
            identifierDoc: {
              "http://bibfra.me/vocab/lite/link": [ "http://id.loc.gov/authorities/n79006873" ],
              "http://bibfra.me/vocab/lite/name": [ "n79006873" ],
              "http://bibfra.me/vocab/lite/label": [ "n79006873" ]
            },
            identifierLabel: 'n79006873'
          }, {
            identifierType: 'ID_LOCAL',
            identifierDoc: {
              'http://bibfra.me/vocab/lite/name': ['3747060'],
              'http://bibfra.me/vocab/lite/label': ['3747060']
            },
            identifierLabel: '3747060'
          }
        ]
      }
      """
    * call read('authority-create.feature@validateAuthortiySubgraph') params
