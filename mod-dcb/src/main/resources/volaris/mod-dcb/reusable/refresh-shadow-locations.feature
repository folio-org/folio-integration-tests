Feature: Testing Lending Flow

  Background:
    * url baseUrl
    * def user = testUser
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
      # load global variables
    * callonce variables


  @DeleteShadowLocations
  Scenario: Fetch and Delete shadow Locations
    # Get all shadow institutions units
    * print 'START: Fetch and Delete shadow Locations'
    Given path '/locations'
    And param limit = 10
    And param offset = 0
    And param query = '(name==Location-* AND code==LOC-*)'
    And param includeShadowLocations = true
    When method GET
    Then status 200

    # Extract IDs from the response
    * def locationIds = karate.map(response.locations, function(location){ return location.id })
    * print 'LocationIds IDs to delete:', locationIds

    * def deleteLocationById =
    """
    function(id) {
      var result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLocation', { id: id });
      return result;
    }
    """

    # Execute deletion for each ID
    * karate.forEach(locationIds, deleteLocationById)
    * print 'END: Fetch and Delete shadow institutions'

  @DeleteLocation
  Scenario: Delete Location by locationId
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)'}
    * path '/locations/', id
    * method DELETE
    * status 204

  @DeleteShadowLibraries
  Scenario: Fetch and Delete shadow libraries
    # Get all shadow libraries units
    * print 'START: Fetch and Delete shadow libraries'
    Given path '/location-units/libraries'
    And param limit = 10
    And param offset = 0
    And param query = '(name==Agency-* AND code==AG-*)'
    And param includeShadow = true
    When method GET
    Then status 200

    # Extract IDs from the response
    * def libraryIds = karate.map(response.loclibs, function(library){ return library.id })
    * print 'Library IDs to delete:', libraryIds

    * def deleteLibraryById =
    """
    function(id) {
      var result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLibrary', { id: id });
      return result;
    }
    """

    # Execute deletion for each ID
    * karate.forEach(libraryIds, deleteLibraryById)
    * print 'END: Fetch and Delete shadow libraries'

  @DeleteLibrary
  Scenario: Delete library by libraryId
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)'}
    * path '/location-units/libraries/', id
    * method DELETE
    * status 204


  @DeleteShadowCampuses
  Scenario: Fetch and Delete shadow campuses
    # Get all shadow campuses units
    * print 'START: Fetch and Delete shadow campuses'
    Given path '/location-units/campuses'
    And param limit = 10
    And param offset = 0
    And param query = '(name==Agency-* AND code==AG-*)'
    And param includeShadow = true
    When method GET
    Then status 200

    # Extract IDs from the response
    * def campusIds = karate.map(response.loccamps, function(campus){ return campus.id })
    * print 'CampusIds IDs to delete:', campusIds

    * def deleteCampusIdsById =
    """
    function(id) {
      var result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteCampus', { id: id });
      return result;
    }
    """

    # Execute deletion for each ID
    * karate.forEach(campusIds, deleteCampusIdsById)
    * print 'END: Fetch and Delete shadow campuses'

  @DeleteCampus
  Scenario: Delete library by campusId
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)'}
    * path '/location-units/campuses/', id
    * method DELETE
    * status 204


  @DeleteShadowInstitutions
  Scenario: Fetch and Delete shadow institutions
    # Get all shadow institutions units
    * print 'START: Fetch and Delete shadow institutions'
    Given path '/location-units/institutions'
    And param limit = 10
    And param offset = 0
    And param query = '(name==Agency-* AND code==AG-*)'
    And param includeShadow = true
    When method GET
    Then status 200

    # Extract IDs from the response
    * def institutionIds = karate.map(response.locinsts, function(institution){ return institution.id })
    * print 'InstitutionsIds IDs to delete:', institutionIds

    * def deleteInstitutionById =
    """
    function(id) {
      var result = karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteInstitution', { id: id });
      return result;
    }
    """

    # Execute deletion for each ID
    * karate.forEach(institutionIds, deleteInstitutionById)
    * print 'END: Fetch and Delete shadow institutions'

  @DeleteInstitution
  Scenario: Delete institutions by institutionsId
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)'}
    * path '/location-units/institutions/', id
    * method DELETE
    * status 204



  @DeleteLocationByNameAndCode
  Scenario: Delete Location by name and code
    * print 'Deleting Location with name:', name, ' and code: ', code

    # First fetch the location ID by name
    Given path '/locations'
    And param query = '(name==' + name + ' AND code==' + code + ')'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    * assert response.totalRecords > 0

    * karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLocation', { id: response.locations[0].id })



  @DeleteLibraryByNameAndCode
  Scenario: Delete Library by name and code
    * print 'Deleting Library with name:', name, ' and code: ', code

    # First fetch the library ID by name
    Given path '/location-units/libraries'
    And param query = '(name==' + name + ' AND code==' + code + ')'
    And param includeShadow = true
    When method GET
    Then status 200
    * assert response.totalRecords > 0

    * karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteLibrary', { id: response.loclibs[0].id })


  @DeleteInstitutionByNameAndCode
  Scenario: Delete institution by name and code
    * print 'Deleting institution with name:', name, ' and code: ', code

    # First fetch the institution ID by name
    Given path '/location-units/institutions'
    And param query = '(name==' + name + ' AND code==' + code + ')'
    And param includeShadow = true
    When method GET
    Then status 200
    * assert response.totalRecords > 0

    * karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteInstitution', { id: response.locinsts[0].id })


  @DeleteCampusByNameAndCode
  Scenario: Delete Campus by name and code
    * print 'Deleting Campus with name:', name, ' and code: ', code

    # First fetch the Campus ID by name
    Given path '/location-units/campuses'
    And param query = '(name==' + name + ' AND code==' + code + ')'
    And param includeShadow = true
    When method GET
    Then status 200
    * assert response.totalRecords > 0

    * karate.call('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@DeleteCampus', { id: response.loccamps[0].id })


  @CreateMockServerShadowLocationsData
  Scenario: Create Mock Server Data for Shadow Locations
    # Read and update mock data
    * def dcbHubCredValue = '{\"client_id\":\"test\",\"client_secret\":\"test\",\"username\":\"test\",\"password\":\"test\",\"keycloak_url\":\"' + mockServerUrl + '/realms/master/protocol/openid-connect/token\"}'
    * def agencyOneCode = karate.get('agencyOneCode', null)
    * def agencyOneName = karate.get('agencyOneName', null)
    * def mockData = read('classpath:volaris/mod-dcb/features/samples/refresh-shadow-locations/mock-locations-data.json')
    * url mockServerUrl
    Given path '/mockserver/expectation'
    And request mockData
    When method PUT
    Then status 201