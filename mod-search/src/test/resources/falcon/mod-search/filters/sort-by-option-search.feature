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
    * def expectedOrder = new Array(21);

    * expectedOrder[0] = 'a conference name'
    * expectedOrder[1] = 'a corporate name'
    * expectedOrder[2] = 'a genre term'
    * expectedOrder[3] = 'a geographic name'
    * expectedOrder[4] = 'a personal name'

    * expectedOrder[5] = 'a saft conference name'
    * expectedOrder[6] = 'a saft corporate name'
    * expectedOrder[7] = 'a saft genre term'
    * expectedOrder[8] = 'a saft geographic name'
    * expectedOrder[9] = 'a saft personal name'
    * expectedOrder[10] = 'a saft topical term'
    * expectedOrder[11] = 'a saft uniform title'

    * expectedOrder[12] = 'a sft conference name'
    * expectedOrder[13] = 'a sft corporate name'
    * expectedOrder[14] = 'a sft genre term'
    * expectedOrder[15] = 'a sft geographic name'
    * expectedOrder[16] = 'a sft personal name'
    * expectedOrder[17] = 'a sft topical term'
    * expectedOrder[18] = 'a sft uniform title'
    * expectedOrder[19] = 'a topical term'
    * expectedOrder[20] = 'an uniform title'
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by headingType
    * def sortOption = "headingType"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(21);

    * expectedOrder.fill('Conference Name', 0, 2)
    * expectedOrder.fill('Corporate Name', 2, 4)
    * expectedOrder.fill('Genre', 4, 6)
    * expectedOrder.fill('Geographic Name', 6, 8)
    * expectedOrder.fill('Other', 8, 15)
    * expectedOrder.fill('Personal Name', 15, 17)
    * expectedOrder.fill('Topical', 17, 19)
    * expectedOrder.fill('Uniform Title', 19, 21)
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by authRefType
    * def sortOption = "authRefType"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(21);

    * expectedOrder.fill('Auth/Ref', 0, 7)
    * expectedOrder.fill('Authorized', 7, 14)
    * expectedOrder.fill('Reference', 14, 21)
    * call read('sort-by-option-search.feature@SortInTwoOrders')
