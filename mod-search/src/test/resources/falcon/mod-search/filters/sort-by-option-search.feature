Feature: Tests that sorted by fields

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  @Ignore
  @SortByOption
  Scenario: Can sort by option
    Given path '/search/' + recordsType
    And param query = 'cql.allRecords=1 sortBy '+sortOption+'/sort.'+order
    And param expandAll = true
    When method GET
    Then status 200
    And def actualOrder = karate.jsonPath(response, "$."+ recordsType +'[*].'+ sortPath)
    Then match actualOrder == expectedOrder

  @Ignore
  @SortInTwoOrders
  Scenario: Can sort by option
    * def order = 'ascending'
    * call read('sort-by-option-search.feature@SortByOption')

    * expectedOrder.reverse()
    * def order = 'descending'
    * call read('sort-by-option-search.feature@SortByOption')

#   ================= Instance test cases =================

  Scenario: Can sort by title
    * def sortOption = "title"
    * def sortPath = sortOption
    * def recordsType = "instances"
    * def expectedOrder = new Array(2);

    * expectedOrder[0] = 'A semantic web primer'
    * expectedOrder[1] = "The web of metaphor :studies in the imagery of Montaigne Essais /by Carol Clark."
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by contributors
    * def sortOption = "contributors"
    * def sortPath = "contributors[*].name"
    * def order = 'ascending'
    * def recordsType = "instances"
    * def expectedOrder = new Array(2);

    * expectedOrder[0] = 'Antoniou, Grigoris'
    * expectedOrder[1] = 'Van Harmelen, Frank'
    * expectedOrder[2] = 'Clark, Carol (Carol E.)'
    * call read('sort-by-option-search.feature@SortByOption')

  Scenario: Can sort by items.status.name
    * def sortOption = "items.status.name"
    * def sortPath = "items[*].status.name"
    * def order = 'ascending'
    * def recordsType = "instances"
    * def expectedOrder = new Array(2);

    * expectedOrder[0] = 'Available'
    * expectedOrder[1] = 'Checked out'
    * call read('sort-by-option-search.feature@SortByOption')


#   ================= Authority test cases =================

  Scenario: Can sort by headingRef
    * def sortOption = "headingRef"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(30);

    * expectedOrder[0] = 'a conference name'
    * expectedOrder[1] = 'a conference title'
    * expectedOrder[2] = 'a corporate name'
    * expectedOrder[3] = 'a corporate title'
    * expectedOrder[4] = 'a genre term'
    * expectedOrder[5] = 'a geographic name'
    * expectedOrder[6] = 'a personal name'
    * expectedOrder[7] = 'a personal title'

    * expectedOrder[8] = 'a saft conference name'
    * expectedOrder[9] = 'a saft conference title'
    * expectedOrder[10] = 'a saft corporate name'
    * expectedOrder[11] = 'a saft corporate title'
    * expectedOrder[12] = 'a saft genre term'
    * expectedOrder[13] = 'a saft geographic name'
    * expectedOrder[14] = 'a saft personal name'
    * expectedOrder[15] = 'a saft personal title'
    * expectedOrder[16] = 'a saft topical term'
    * expectedOrder[17] = 'a saft uniform title'

    * expectedOrder[18] = 'a sft conference name'
    * expectedOrder[19] = 'a sft conference title'
    * expectedOrder[20] = 'a sft corporate name'
    * expectedOrder[21] = 'a sft corporate title'
    * expectedOrder[22] = 'a sft genre term'
    * expectedOrder[23] = 'a sft geographic name'
    * expectedOrder[24] = 'a sft personal name'
    * expectedOrder[25] = 'a sft personal title'
    * expectedOrder[26] = 'a sft topical term'
    * expectedOrder[27] = 'a sft uniform title'
    * expectedOrder[28] = 'a topical term'
    * expectedOrder[29] = 'an uniform title'

    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by headingType
    * def sortOption = "headingType"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(30);

    * expectedOrder.fill('Conference Name', 0, 6)
    * expectedOrder.fill('Corporate Name', 6, 12)
    * expectedOrder.fill('Genre', 12, 15)
    * expectedOrder.fill('Geographic Name', 15, 18)
    * expectedOrder.fill('Personal Name', 18, 24)
    * expectedOrder.fill('Topical', 24, 27)
    * expectedOrder.fill('Uniform Title', 27, 30)
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by authRefType
    * def sortOption = "authRefType"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(30);

    * expectedOrder.fill('Auth/Ref', 0, 10)
    * expectedOrder.fill('Authorized', 10, 20)
    * expectedOrder.fill('Reference', 20, 30)
    * call read('sort-by-option-search.feature@SortInTwoOrders')
