Feature: Import Bibframe2 RDF - Verify Get instance API

  Scenario: Get instance data using API
    * def getInstanceResourceCall = call getResource { id: "#(resourceId)" }
    * def instanceResource = getInstanceResourceCall.response
    * print instanceResource

  @C788734
  Scenario: Verify Identifiers (LCCN, ISBN, IAN)
    * def getInstanceResourceCall = call getResource { id: "#(resourceId)" }
    * def instanceResource = getInstanceResourceCall.response
    * def mapArray = instanceResource.resource['http://bibfra.me/vocab/lite/Instance']['http://library.link/vocab/map']
    # Validate Active ISBN
    * def activeIsbn = mapArray.find(x => x['http://library.link/identifier/ISBN'] && x['http://library.link/identifier/ISBN']['http://bibfra.me/vocab/lite/name'][0].trim() == '9781452152448')['http://library.link/identifier/ISBN']
    * match activeIsbn['http://bibfra.me/vocab/lite/name'][0].trim() == '9781452152448'
    * match activeIsbn['http://bibfra.me/vocab/library/qualifier'][0].trim() == 'board bk'
    # Validate LCCN
    * def lccn = mapArray.find(x => x['http://library.link/identifier/LCCN'])['http://library.link/identifier/LCCN']
    * match lccn['http://bibfra.me/vocab/lite/name'][0].trim() == '2015047302'
    # Validate IAN
    * def ianObj = mapArray.find(x => x['http://library.link/identifier/IAN'] && x['http://library.link/identifier/IAN']['http://bibfra.me/vocab/lite/name'][0].trim() == '9783957861153')['http://library.link/identifier/IAN']
    * match ianObj['http://bibfra.me/vocab/lite/name'][0].trim() == '9783957861153'
    * match ianObj['http://bibfra.me/vocab/library/qualifier'][0].trim() == 'paperback'
    # Validate cancelled ISBN
    * def cancelledIsbnObj = mapArray.find(x => x['http://library.link/identifier/ISBN'] && x['http://library.link/identifier/ISBN']['http://bibfra.me/vocab/lite/name'][0].trim() == '9783958296879')['http://library.link/identifier/ISBN']
    * match cancelledIsbnObj['http://bibfra.me/vocab/lite/name'][0].trim() == '9783958296879'
    * match cancelledIsbnObj['http://bibfra.me/vocab/library/qualifier'][0].trim() == 'ePub'
    * match cancelledIsbnObj['http://bibfra.me/vocab/library/status'][0]['http://bibfra.me/vocab/lite/label'][0] == 'cancinv'
    * match cancelledIsbnObj['http://bibfra.me/vocab/library/status'][0]['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/mstatus/cancinv'

  @C813006
  Scenario: Verify provision activity (publication, manufacture, production, distrubution)
    # Validate publicaion
    * def publicationArray = instanceResource.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/library/publication']
    * def publication = publicationArray[0]
    * match publication['http://bibfra.me/vocab/lite/date'][0] == '[2016]'
    * match publication['http://bibfra.me/vocab/lite/name'][0] == 'Chronicle Books LLC'
    * match publication['http://bibfra.me/vocab/lite/providerDate'][0] == '2016'
    * match publication['http://bibfra.me/vocab/lite/place'][0] == 'San Francisco, CA'
    * def providerPlace = publication['http://bibfra.me/vocab/lite/providerPlace'][0]
    * match providerPlace['http://bibfra.me/vocab/lite/name'][0] == 'California'
    * match providerPlace['http://bibfra.me/vocab/library/code'][0] == 'cau'
    * match providerPlace['http://bibfra.me/vocab/lite/label'][0] == 'California'
    * match providerPlace['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/countries/cau'

    # Validate manufacture
    * def manufactureArray = instanceResource.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/library/manufacture']
    * def manufacture = manufactureArray[0]
    * match manufacture['http://bibfra.me/vocab/lite/name'][0] == 'Arion Press'
    * match manufacture['http://bibfra.me/vocab/lite/place'][0] == 'San Francisco'

    # Validate production
    * def productionArray = instanceResource.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/library/production']
    * def production = productionArray[0]
    * match production['http://bibfra.me/vocab/lite/date'][0] == '[1965?]'
    * match production['http://bibfra.me/vocab/lite/name'][0] == 'Kenneth Raymond Wight Associates'
    * match production['http://bibfra.me/vocab/lite/providerDate'][0] == '1965'
    * match production['http://bibfra.me/vocab/lite/place'][0] == 'Princeton, New Jersey'

    # Validate distribution (order-independent)
    * def distributionArray = instanceResource.resource['http://bibfra.me/vocab/lite/Instance']['http://bibfra.me/vocab/library/distribution']

    * def dist1 = distributionArray.find(x => x['http://bibfra.me/vocab/lite/date'] && x['http://bibfra.me/vocab/lite/date'][0] == '[2013]')
    * match dist1['http://bibfra.me/vocab/lite/name'][0] == 'Distributed by Allegro Corporation'
    * match dist1['http://bibfra.me/vocab/lite/place'][0] == 'Portland, OR'

    * def dist2 = distributionArray.find(x => x['http://bibfra.me/vocab/lite/providerDate'] && x['http://bibfra.me/vocab/lite/providerDate'][0] == '1965')
    * def distProviderPlace = dist2['http://bibfra.me/vocab/lite/providerPlace'][0]
    * match distProviderPlace['http://bibfra.me/vocab/lite/name'][0] == 'Massachusetts'
    * match distProviderPlace['http://bibfra.me/vocab/library/code'][0] == 'mau'
    * match distProviderPlace['http://bibfra.me/vocab/lite/label'][0] == 'Massachusetts'
    * match distProviderPlace['http://bibfra.me/vocab/lite/link'][0] == 'http://id.loc.gov/vocabulary/countries/mau'