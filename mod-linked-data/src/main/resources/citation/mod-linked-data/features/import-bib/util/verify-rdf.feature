Feature: Verify exported Bibframe2 RDF
  Background:
    * def baseResourceUrl = 'http://localhost:8081/linked-data-editor/resources/'

  Scenario: Fetch Instance Subgraph
    * def rdfCall = call getRdf { resourceId:  '#(instanceResourceId)' }
    * def rdf = rdfCall.response
    * def instanceRdf = rdf.filter(x => x['@id'] == baseResourceUrl + instanceResourceId)[0]
    * def workId = instanceRdf['http://id.loc.gov/ontologies/bibframe/instanceOf'][0]['@id']
    * def workRdf = rdf.filter(x => x['@id'] == workId)[0]

  @C794523
  Scenario: Verify statement of responsibility, dimensions and titles
    * match instanceRdf['http://id.loc.gov/ontologies/bibframe/dimensions'] == [{ '@value': '31 cm +' }]
    * match instanceRdf['http://id.loc.gov/ontologies/bibframe/responsibilityStatement'] == [{ '@value': 'by Ernest Poole' }]

    * def validateTitleResource =
      """
      function(rdf, instanceRdf, workRdf, type, additionalType, mainTitle, subTitle, partName, partNumber, date, note, nonSortNum) {
        var candidates = rdf.filter(x =>  x['@type'] && x['@type'].indexOf(type) > -1 &&
          (!additionalType || x['@type'].indexOf(additionalType) > -1) &&
          x['http://id.loc.gov/ontologies/bibframe/mainTitle'] &&
          x['http://id.loc.gov/ontologies/bibframe/mainTitle'][0]['@value'] === mainTitle);
        assertMatch(candidates.length, 1);
        var resource = candidates[0];
        if (subTitle != null) {
          assertMatch(resource['http://id.loc.gov/ontologies/bibframe/subtitle'][0]['@value'], subTitle, 'Subtitle do not match: ' + subTitle);
        }
        if (partName != null) {
          assertMatch(resource['http://id.loc.gov/ontologies/bibframe/partName'][0]['@value'], partName, 'PartName do not match: ' + partName);
        }
        if (partNumber != null) {
          assertMatch(resource['http://id.loc.gov/ontologies/bibframe/partNumber'][0]['@value'], partNumber, 'PartNumber do not match: ' + partNumber);
        }
        if (date != null) {
          assertMatch(resource['http://id.loc.gov/ontologies/bibframe/date'][0]['@value'], date, 'Date do not match: ' + date);
        }
        if (nonSortNum!= null) {
          assertMatch(resource['http://id.loc.gov/ontologies/bflc/nonSortNum'][0]['@value'], nonSortNum, 'Non sort number do not match: ' + nonSortNum);
        }
        if (note != null) {
          var noteRef = resource['http://id.loc.gov/ontologies/bibframe/note'] && resource['http://id.loc.gov/ontologies/bibframe/note'][0];
          assertTrue(noteRef != null);
          var noteId = noteRef['@id'];
          var noteResource = rdf.filter(x => x['@id'] === noteId )[0];
          assertTrue(noteResource['@type'].includes("http://id.loc.gov/ontologies/bibframe/Note"));
          assertMatch(noteResource['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'], note);
        }
        var resourceId = resource['@id'];
        assertTrue(instanceRdf['http://id.loc.gov/ontologies/bibframe/title'].map(x => x['@id']).includes(resourceId));
        assertTrue(workRdf['http://id.loc.gov/ontologies/bibframe/title'].map(x => x['@id']).includes(resourceId));
      }
      """
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/Title', null, 'Silent storms,', null, null, null, null, null, '0')
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/ParallelTitle', null, 'Yehudim, Elohim ṿe-hisṭoryah', null, null, null, null, 'Title facing title page', null)
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/VariantTitle', 'http://id.loc.gov/vocabulary/vartitletype/dis', 'Capital y derechos de la naturaleza--y la humanidad--en México y Nuestra América en el siglo XXI', 'esencia, complejidad y dialéctica de la esclavitud y exterminio sistémico de los animales', null, null, 'tomo II', null, null)
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/VariantTitle', 'http://id.loc.gov/vocabulary/vartitletype/cov', 'Teenage mutant ninja turtles', null, 'Battle lines', 'Vol. 21', null, null, null)
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/VariantTitle', null, 'Zhongguo yuedu tongshi', null, 'Mingdai juan', null, null, 'Colophon title also in pinyin', null)
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/VariantTitle', 'http://id.loc.gov/vocabulary/vartitletype/spi', 'Drama uygulamaları', null, null, null, null, null, null)
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/VariantTitle', 'http://id.loc.gov/vocabulary/vartitletype/run', 'Nrithya vidhyaa', null, null, null, null, null)
    * eval validateTitleResource(rdf, instanceRdf, workRdf, 'http://id.loc.gov/ontologies/bibframe/VariantTitle', 'http://id.loc.gov/vocabulary/vartitletype/cap', 'Padenie Parizha', 'roman', null, null, null, null)

  @C805758
  Scenario: Verify Creator (LCCN present)
    * def contributionIds = workRdf['http://id.loc.gov/ontologies/bibframe/contribution'].map(x => x['@id'])
    * def contributorsRdfs = contributionIds.map(id => rdf.filter(x => x['@id'] == id)[0])
    * def creator = contributorsRdfs.filter(x => x['@type'].includes('http://id.loc.gov/ontologies/bibframe/PrimaryContribution'))[0]
    * match creator['http://id.loc.gov/ontologies/bibframe/role'][0]['@id'] == 'http://id.loc.gov/vocabulary/relators/aut'
    * def creatorAgentId = creator['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * match creatorAgentId == 'http://id.loc.gov/rwo/agents/n87116094'

  @C805759
  Scenario: Verify Contrinutors (LCCN Not present)
    * def contributors = contributorsRdfs.filter(x => !x['@type'].includes('http://id.loc.gov/ontologies/bibframe/PrimaryContribution'))

    * def familyContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Rinehart family, Rinehart, Family Rinehart')[0]
    * def familyAgentId = familyContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def familyAgent = rdf.filter(x => x['@id'] == familyAgentId)[0]
    * match familyAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match familyAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Family'
    * match familyAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Rinehart family, Rinehart, Family Rinehart'

    * def personContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'VI, Edward, King of England, 1537-1553')[0]
    * def personAgentId = personContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def personAgent = rdf.filter(x => x['@id'] == personAgentId)[0]
    * match personAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match personAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Person'
    * match personAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'VI, Edward, King of England, 1537-1553'

    * def organizationContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :')[0]
    * def organizationAgentId = organizationContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def organizationAgent = rdf.filter(x => x['@id'] == organizationAgentId)[0]
    * match organizationAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match organizationAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Organization'
    * match organizationAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'Horror Writers Association, Ann Radcliffe Academic, Long Beach, Calif.), 2017 :'

    * def meetingContributor = contributors.filter(x => rdf.filter(a => a['@id'] == x['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id'])[0]['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'International Business Engineering Conference, 2018, Legian, Bali, Indonesia')[0]
    * def meetingAgentId = meetingContributor['http://id.loc.gov/ontologies/bibframe/agent'][0]['@id']
    * def meetingAgent = rdf.filter(x => x['@id'] == meetingAgentId)[0]
    * match meetingAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Agent'
    * match meetingAgent['@type'] contains 'http://id.loc.gov/ontologies/bibframe/Meeting'
    * match meetingAgent['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'International Business Engineering Conference, 2018, Legian, Bali, Indonesia'

  Scenario: Verify provision activity
    * def provisionActivityIds = instanceRdf['http://id.loc.gov/ontologies/bibframe/provisionActivity'].map(x => x['@id'])

    * def mcmillan = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/ProvisionActivity') && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Publication') && x['http://id.loc.gov/ontologies/bflc/simpleAgent'] && x['http://id.loc.gov/ontologies/bflc/simpleAgent'][0]['@value'] == 'The Macmillan Company')
    * match mcmillan == '#[1]'
    * def mcmillan = mcmillan[0]
    * match provisionActivityIds contains mcmillan['@id']
    * match mcmillan['http://id.loc.gov/ontologies/bibframe/date'] == [{ '@value': '1927' }]
    * match mcmillan['http://id.loc.gov/ontologies/bflc/simpleDate'] == [{ '@value': '1927' }]
    * match mcmillan['http://id.loc.gov/ontologies/bflc/simplePlace'] == [{ '@value': 'New York' }]
    * match mcmillan['http://id.loc.gov/ontologies/bibframe/place'] == [{ '@id': 'http://id.loc.gov/vocabulary/countries/nyu' }]

    # Verification for ProvisionActivity/Publication object with simpleDate 2000
    * eval provision2000 = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/ProvisionActivity') && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Publication') && x['http://id.loc.gov/ontologies/bflc/simpleDate'] && x['http://id.loc.gov/ontologies/bflc/simpleDate'][0]['@value'] == '2000')
    * match provision2000 == '#[1]'
    * def provision2000 = provision2000[0]
    * match provisionActivityIds contains provision2000['@id']
    * match provision2000['http://id.loc.gov/ontologies/bibframe/date'] == [{ '@value': '1927' }]
    * match provision2000['http://id.loc.gov/ontologies/bibframe/place'] == [{ '@id': 'http://id.loc.gov/vocabulary/countries/nyu' }]

    # Verification for ProvisionActivity/Publication object with simpleAgent 'Academic Press is an Imprint of Elsevier'
    * eval elsevier = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/ProvisionActivity') && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Publication') && x['http://id.loc.gov/ontologies/bflc/simpleAgent'] && x['http://id.loc.gov/ontologies/bflc/simpleAgent'][0]['@value'] == 'Academic Press is an Imprint of Elsevier')
    * match elsevier == '#[1]'
    * def elsevier = elsevier[0]
    * match provisionActivityIds contains elsevier['@id']
    * match elsevier['http://id.loc.gov/ontologies/bibframe/date'] == [{ '@value': '1927' }]
    * match elsevier['http://id.loc.gov/ontologies/bflc/simpleDate'] == [{ '@value': '2019' }]
    * match elsevier['http://id.loc.gov/ontologies/bflc/simplePlace'] == [{ '@value': 'San Diego' }]
    * match elsevier['http://id.loc.gov/ontologies/bibframe/place'] == [{ '@id': 'http://id.loc.gov/vocabulary/countries/nyu' }]

    # Verification for ProvisionActivity/Distribution object with simpleAgent 'For sale by the Superintendent of Documents, U.S. Government Publishing Office'
    * eval gpo = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/ProvisionActivity') && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Distribution') && x['http://id.loc.gov/ontologies/bflc/simpleAgent'] && x['http://id.loc.gov/ontologies/bflc/simpleAgent'][0]['@value'] == 'For sale by the Superintendent of Documents, U.S. Government Publishing Office')
    * match gpo == '#[1]'
    * def gpo = gpo[0]
    * match provisionActivityIds contains gpo['@id']
    * match gpo['http://id.loc.gov/ontologies/bibframe/date'] == [{ '@value': '1927' }]
    * match gpo['http://id.loc.gov/ontologies/bflc/simplePlace'] == [{ '@value': 'Washington, DC' }]
    * match gpo['http://id.loc.gov/ontologies/bibframe/place'] == [{ '@id': 'http://id.loc.gov/vocabulary/countries/nyu' }]

    # Verification for ProvisionActivity/Manufacture object with simpleAgent 'Imp. Nounagnon & Fils'
    * eval nounagnon = rdf.filter(x => x['@type'] && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/ProvisionActivity') && x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Manufacture') && x['http://id.loc.gov/ontologies/bflc/simpleAgent'] && x['http://id.loc.gov/ontologies/bflc/simpleAgent'][0]['@value'] == 'Imp. Nounagnon & Fils')
    * match nounagnon == '#[1]'
    * def nounagnon = nounagnon[0]
    * match provisionActivityIds contains nounagnon['@id']
    * match nounagnon['http://id.loc.gov/ontologies/bibframe/date'] == [{ '@value': '1927' }]
    * match nounagnon['http://id.loc.gov/ontologies/bflc/simpleDate'] == [{ '@value': '2018' }]
    * match nounagnon['http://id.loc.gov/ontologies/bflc/simplePlace'] == [{ '@value': 'Benin' }]
    * match nounagnon['http://id.loc.gov/ontologies/bibframe/place'] == [{ '@id': 'http://id.loc.gov/vocabulary/countries/nyu' }]