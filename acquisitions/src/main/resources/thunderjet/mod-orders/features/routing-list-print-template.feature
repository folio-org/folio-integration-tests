  # for MODORDERS-1026
  Feature: Should check processing of printing routing list functionlity

    Background:
      * url baseUrl
      * callonce loginAdmin testAdmin
      * def okapitokenAdmin = okapitoken

      * callonce loginRegularUser testUser
      * def okapitokenUser = okapitoken

      * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
      * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

      * configure headers = headersUser

      * callonce variables
      * def routingListId = "a1d13648-347b-4ac9-8c2f-5bc47248b87e"
      * def userId1 = '50bc2807-4d5b-4a27-a2b5-b7b1ba431cc4'
      * def userId2 = '00bc2807-4d5b-4a27-a2b5-b7b1ba431cc4'
      * def userId3 = '011dc219-6b7f-4d93-ae7f-f512ed651493'
      * def templateId = '9465105a-e8a1-470c-9817-142d33bc4fcd'
      * def orderId = callonce uuid1
      * def poLineId = callonce uuid2
      * def homeAddressTypeId = callonce uuid3
      * def homeAddressLine1V1 = '1235 Iowa str'
      * def homeAddressLine1V2 = '1550 Austin str'
      * def homeAddressLine1V3 = '1552 Loa str'
      * def officeAddressTypeId = callonce uuid4
      * def officeAddressLine1V1 = '113 Law'
      * def officeAddressLine1V2 = '143 Law'
      * def officeAddressLine1V3 = '188 Law'

      * def user1 = read('classpath:samples/mod-users/' + userId1 + '.json')
      * def user2 = read('classpath:samples/mod-users/' + userId2 + '.json')
      * def user3 = read('classpath:samples/mod-users/' + userId3 + '.json')
      * def routingList = read('classpath:samples/mod-orders/routingLists/' + routingListId + '.json')


    Scenario: Prepare required data
    1. Create addressType for user
    2. Create two users with different addressType are related to routingLists
    3. Create composite order to use in routing list
    4. Create order line for composite order that will be used in routingList
    5. Create Routing Lists with two user 'user1', 'user2'
    6. POST setting with addressTypId
    7. POST template config in mod-template-engine to use
      * print "Create 'office' addressType for user"
      * configure headers = headersAdmin
      Given path '/addresstypes'
      And request
        """
        {
          "addressType": "routing",
          "desc": "Office addresss",
          "id": "#(officeAddressTypeId)"
        }
        """
      When method POST
      Then status 201
      And match $.id == officeAddressTypeId


      * print "Create 'home' addressType for user"
      Given path '/addresstypes'
      And request
        """
        {
          "addressType": "home",
          "desc": "Hone addresss",
          "id": "#(homeAddressTypeId)"
        }
        """
      When method POST
      Then status 201
      And match $.id == homeAddressTypeId


      * print "Create two users with different addressType are related to routingLists"
      * configure headers = headersAdmin
      * set user1.personal.addresses[0].addressTypeId = officeAddressTypeId
      * set user1.personal.addresses[0].addressLine1 = officeAddressLine1V1
      * set user1.personal.addresses[1].addressTypeId = homeAddressTypeId
      * set user1.personal.addresses[1].addressLine1 = homeAddressLine1V1
      * set user2.personal.addresses[0].addressTypeId = officeAddressTypeId
      * set user2.personal.addresses[0].addressLine1 = officeAddressLine1V2
      * set user2.personal.addresses[1].addressTypeId = homeAddressTypeId
      * set user2.personal.addresses[1].addressLine1 = homeAddressLine1V2
      * set user3.personal.addresses[0].addressTypeId = officeAddressTypeId
      * set user3.personal.addresses[0].addressLine1 = officeAddressLine1V3
      * set user3.personal.addresses[1].addressTypeId = homeAddressTypeId
      * set user3.personal.addresses[1].addressLine1 = homeAddressLine1V3

      Given path 'users'
      And request user1
      When method POST
      Then status 201
      And match response.personal.addresses[*].addressTypeId contains officeAddressTypeId
      And match response.personal.addresses[*].addressLine1 contains officeAddressLine1V1
      And match response.personal.addresses[*].addressTypeId contains homeAddressTypeId
      And match response.personal.addresses[*].addressLine1 contains homeAddressLine1V1

      Given path 'users'
      And request user2
      When method POST
      Then status 201
      And match response.personal.addresses[*].addressTypeId contains officeAddressTypeId
      And match response.personal.addresses[*].addressLine1 contains officeAddressLine1V2
      And match response.personal.addresses[*].addressTypeId contains homeAddressTypeId
      And match response.personal.addresses[*].addressLine1 contains homeAddressLine1V2

      Given path 'users'
      And request user3
      When method POST
      Then status 201
      And match response.personal.addresses[*].addressTypeId contains officeAddressTypeId
      And match response.personal.addresses[*].addressLine1 contains officeAddressLine1V3
      And match response.personal.addresses[*].addressTypeId contains homeAddressTypeId
      And match response.personal.addresses[*].addressLine1 contains homeAddressLine1V3


      * print "Create composite order to use in routing list"
      * configure headers = headersUser
      Given path 'orders/composite-orders'
      And request
        """
        {
          id: '#(orderId)',
          vendor: '#(globalVendorId)',
          orderType: 'One-Time'
        }
        """
      When method POST
      Then status 201

      * print "Create order line for composite order that will be used in routingList"
      Given path 'orders/order-lines'

      * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
      * set orderLine.id = poLineId
      * set orderLine.purchaseOrderId = orderId

      And request orderLine
      When method POST
      Then status 201
      * def response = $
      And match response.paymentStatus == "Pending"


      * print "POST setting with addressTypId"
      * configure headers = headersAdmin
      Given path 'orders-storage/settings'
      And request
        """
        {
          "key": "ROUTING_USER_ADDRESS_TYPE_ID",
          "value": "#(officeAddressTypeId)"
        }
        """
      When method POST
      Then status 201
      And match response.key == 'ROUTING_USER_ADDRESS_TYPE_ID'
      And match response.value == officeAddressTypeId


      * print "POST template config in mod-template-engine to use"
      * configure headers = headersAdmin
      * def templateRequest = read('classpath:samples/mod-orders/routingLists/template-config.json')
      * set templateRequest.id = templateId
      Given path 'templates'
      And request templateRequest
      When method POST
      Then status 201
      And match response.id == templateId


    Scenario: Verify GET template functionality
    1. Create Routing list
    2. Get template for this routing list
    3. Verify details of template response

      * print "Create Routing Lists with three user 'user1', 'user2', 'user3'"
      * set routingList.id = routingListId
      * set routingList.poLineId = poLineId
      * set routingList.userIds[0] = user1.id
      * set routingList.userIds[1] = user2.id
      * set routingList.userIds[2] = user3.id
      * configure headers = headersAdmin

      Given path 'orders-storage/routing-lists'
      And request routingList
      When method POST
      Then status 201
      And match response.id == routingListId


      * print "Verify GET template feature"
      * configure headers = headersUser
      Given path 'orders/routing-lists/' + routingListId + '/template'
      When method GET
      Then status 200
      And match response.map.result.body == '<div><p>Biography room</p> <p>test</p> <p>Falcon Denesik - 113 Law</p><p>Artimus Denesik - 143 Law</p><p>John Huels - 188 Law</p><p>Some note</p></div>'
