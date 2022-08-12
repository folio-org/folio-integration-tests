Feature: Tests that sorted by fields

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  @Ignore
  @SortByOption
  Scenario: Can sort by option
    Given path '/search/' + recordsType
    And param query = 'cql.allRecords=1 sortBy ' + sortOption+'/sort.' + order
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
    * def expectedOrder = new Array(15);

    * expectedOrder[0] = 'A semantic web primer'
    * expectedOrder[1] = 'Test Instance#10'
    * expectedOrder[2] = 'Test Instance#11'
    * expectedOrder[3] = 'Test Instance#12'
    * expectedOrder[4] = 'Test Instance#13'
    * expectedOrder[5] = 'Test Instance#14'
    * expectedOrder[6] = 'Test Instance#15'
    * expectedOrder[7] = 'Test Instance#3'
    * expectedOrder[8] = 'Test Instance#4'
    * expectedOrder[9] = 'Test Instance#5'
    * expectedOrder[10] = 'Test Instance#6'
    * expectedOrder[11] = 'Test Instance#7'
    * expectedOrder[12] = 'Test Instance#8'
    * expectedOrder[13] = 'Test Instance#9'
    * expectedOrder[14] = 'The web of metaphor :studies in the imagery of Montaigne Essais /by Carol Clark.'
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by contributors
    * def expectedOrder = new Array(11);

    * expectedOrder[0] = 'Abraham'
    * expectedOrder[1] = 'Antoniou, Grigoris'
    * expectedOrder[2] = 'Antoniou, Grigoris'
    * expectedOrder[3] = 'Ben'
    * expectedOrder[4] = 'Celin, Cerol (Cerol E.)'
    * expectedOrder[5] = 'Clark, Carol (Carol E.)'
    * expectedOrder[6] = 'Darth Vader (The father)'
    * expectedOrder[7] = 'Falcon Griffin'
    * expectedOrder[8] = 'Falcon Griffin'
    * expectedOrder[9] = 'Farmer'
    * expectedOrder[10] = 'John, Lennon'

    Given path '/search/instances'
    And param query = 'cql.allRecords=1 sortBy contributors/sort.ascending'
    And param expandAll = true
    When method GET
    Then status 200
    And def contributorArrays = karate.jsonPath(response, "$.instances[*].contributors").filter(e => e.length)
    And def actualOrder = contributorArrays.flatMap(contributors => [karate.jsonPath(contributors, "$[0].name")])
    Then match actualOrder == expectedOrder

  Scenario: Can sort by items.status.name
    * def sortOption = "items.status.name"
    * def sortPath = "items[*].status.name"
    * def order = 'ascending'
    * def recordsType = "instances"
    * def expectedOrder = new Array(26);

    * expectedOrder.fill('Available', 0, 26)
    * expectedOrder[26] = 'Checked out'
    * call read('sort-by-option-search.feature@SortByOption')

  Scenario: Can sort by item.status.name
    * def sortOption = "item.status.name"
    * def sortPath = "items[*].status.name"
    * def order = 'ascending'
    * def recordsType = "instances"
    * def expectedOrder = new Array(26);

    * expectedOrder.fill('Available', 0, 26)
    * expectedOrder[26] = 'Checked out'
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
