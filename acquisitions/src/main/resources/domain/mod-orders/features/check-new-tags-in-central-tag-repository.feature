Feature: Check new tags created in central tag repository

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_orders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Check new tags created in central tag list
    # ============= create new composite order ===================

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.tags =
    """
    {
      "tagList": [
        "check - central - tag",
        " Another  _Tag"
      ]
    }
    """
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      compositePoLines: [#(orderLine)]
    }
    """
    When method POST
    Then status 201

    # ============= check tags in central repository (lowercase, no spaces) ===================
    Given path 'tags'
    And param query = "label==check-central-tag OR label==another_tag"

    When method GET
    Then status 200
    And match response.totalRecords == 2
