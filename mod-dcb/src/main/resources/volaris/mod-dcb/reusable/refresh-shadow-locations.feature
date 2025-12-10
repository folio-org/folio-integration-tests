Feature: Refresh shadow location helpers

  Background:
    * url baseUrl
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * def cqlByNameAndCode =
      """
      function(name, code) {
        const query = 'name=="' + name + '" and code=="' + code + '"';
        karate.log(query);
        return query;
      }
      """

  @PostRefreshShadowLocation
  Scenario: POST refresh shadow locations
    Given path '/dcb/shadow-locations/refresh'
    * print 'Setup - Location:', location
    * request { locations: [ '#(location)' ] }
    When method POST
    Then status 201
    * match $.locations[*].code contains only ['#(location.code)']
    * match $.locations[*].status contains only ['SUCCESS']
    * match $['location-units'].institutions[*].code contains only ['#(location.agency.code)']
    * match $['location-units'].institutions[*].status contains only ['SUCCESS']
    * match $['location-units'].campuses[*].code contains only ['#(location.agency.code)']
    * match $['location-units'].campuses[*].status contains only ['SUCCESS']
    * match $['location-units'].libraries[*].code contains only ['#(location.agency.code)']
    * match $['location-units'].libraries[*].status contains only ['SUCCESS']

    * def args = { name: '#(location.name)', code: '#(location.code)', isShadow: true }
    Given call read('classpath:volaris/mod-dcb/reusable/refresh-shadow-locations.feature@GetLocationByNameAndCode') args
    * def dcbLocationId = response.locations[0].id
    * print 'Setup - Location ID:', dcbLocationId

  @GetInstitutionByNameAndCode
  Scenario: Get institution by name and code
    Given path '/location-units/institutions'
    * param query = cqlByNameAndCode(name, code)
    * param includeShadow = true
    When method GET
    * status 200
    * match $.totalRecords == 1
    * match $.locinsts[0].name == name
    * match $.locinsts[0].code == code
    * match $.locinsts[0].isShadow == isShadow

  @GetCampusByNameAndCode
  Scenario: Get institution by name and code
    Given path '/location-units/campuses'
    * param query = cqlByNameAndCode(name, code)
    * param includeShadow = true
    When method GET
    * status 200
    * match $.totalRecords == 1
    * match $.loccamps[0].name == name
    * match $.loccamps[0].code == code
    * match $.loccamps[0].isShadow == isShadow

  @GetLibraryByNameAndCode
  Scenario: Get institution by name and code
    Given path '/location-units/libraries'
    * param query = cqlByNameAndCode(name, code)
    * param includeShadow = true
    When method GET
    * status 200
    * match $.totalRecords == 1
    * match $.loclibs[0].name == name
    * match $.loclibs[0].code == code
    * match $.loclibs[0].isShadow == isShadow

  @GetLocationByNameAndCode
  Scenario: Get institution by name and code
    Given path '/locations'
    * param query = cqlByNameAndCode(name, code)
    * param includeShadowLocations = true
    When method GET
    * status 200
    * match $.totalRecords == 1
    * match $.locations[0].name == name
    * match $.locations[0].code == code
    * match $.locations[0].isShadow == isShadow
