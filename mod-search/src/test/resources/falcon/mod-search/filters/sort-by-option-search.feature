Feature: Tests that sorted by fields

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

    * def expectedIds = []

  @Ignore
  @SortByOption
  Scenario: Can sort by option
    Given path '/search/instances'
    And param query = 'cql.allRecords=1 sortBy '+sortOption+'/sort.'+order
    When method GET
    Then status 200
    Then match response.totalRecords == expectedIds.length
    Then match response.instances[*].id contains expectedIds

  @Ignore
  @SortInTwoOrders
  Scenario: Can sort by option
    * def order = 'ascending'
    * call read('sort-by-search.feature@SortByOption')

    * expectedIds.reverse()
    * def order = 'descending'
    * call read('sort-by-search.feature@SortByOption')

#   ================= Instance test cases =================

  @Ignore
  Scenario: Can sort by title
    * def sortOption = "title"
    * expectedIds[0] = '7e18b615-0e44-4307-ba78-76f3f447041c'
    * expectedIds[1] = 'af83c0ac-c3ba-4b11-95c8-4110235dec80'
    * expectedIds[2] = '100d10bf-2f06-4aa0-be15-0b95b2d9f9e3'
    * call read('sort-by-search.feature@SortInTwoOrders')

  @Ignore
  Scenario: Can sort by contributors
    * def sortOption = "contributors"
    * expectedIds[0] = '7e18b615-0e44-4307-ba78-76f3f447041c'
    * expectedIds[1] = 'af83c0ac-c3ba-4b11-95c8-4110235dec80'
    * expectedIds[2] = '100d10bf-2f06-4aa0-be15-0b95b2d9f9e3'
    * call read('sort-by-search.feature@SortInTwoOrders')

  @Ignore
  Scenario: Can sort by items.status.name
    * def sortOption = "items.status.name"
    * expectedIds[0] = '7212ba6a-8dcf-45a1-be9a-ffaa847c4423'
    * expectedIds[1] = '100d10bf-2f06-4aa0-be15-0b95b2d9f9e3'
    * call read('sort-by-search.feature@SortInTwoOrders')
