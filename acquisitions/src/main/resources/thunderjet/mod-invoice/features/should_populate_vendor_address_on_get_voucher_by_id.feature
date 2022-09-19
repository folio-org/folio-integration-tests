Feature: Should populate vendor address when retrieve voucher by id

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testinvoices2222'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }


    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')

    # initialize common invoice data
    * def twoAddressesVendor = callonce uuid1
    * def primaryAddressVendor = callonce uuid2
    * def noAddressesVendor = callonce uuid3

    * def twoAddressesInvoice = callonce uuid4
    * def primaryAddressInvoice = callonce uuid5
    * def noAddressInvoice = callonce uuid6

    * def primaryAddress = { addressLine1: "10 Estes Street", addressLine2: "", city: "Ipswich", stateRegion: "MA", zipCode: "01938", country: "USA",  isPrimary: true  }
    * def additionalAddress = { addressLine1: "1 Estes Street", addressLine2: "12", city: "Ipswich", stateRegion: "MA", zipCode: "01937", country: "USA",  isPrimary: false  }


  Scenario Outline: Create vendor <vendorId> with <address1> and <address2>

    * def vendorId = <vendorId>
    * def address1 = <address1>
    * def address2 = <address2>

    * def addresses = []
    * def void = (address1 == null ? null : karate.appendTo(addresses, address1))
    * def void = (address2 == null ? null : karate.appendTo(addresses, address2))
    
    Given path '/organizations-storage/organizations'
    And headers headersAdmin
    And request
    """
    {
      id: '#(vendorId)',
      name: '#(vendorId)',
      code: '#(vendorId)',
      isVendor: true,
      status: 'Active',
      addresses: #(addresses)
    }
    """
    When method POST
    Then status 201
    
    
    Examples: 
    | vendorId             | address1           | address2          |
    | twoAddressesVendor   | additionalAddress  | primaryAddress    |
    | primaryAddressVendor | primaryAddress     | null              |
    | noAddressesVendor    | null               | null              |

  Scenario Outline: Create invoice with line and approve it. invoice <invoiceId>, vendor <vendorId>
    * def invoiceId = <invoiceId>
    * def vendorId = <vendorId>

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And headers headersUser
    And request
    """
    {
      id: '#(invoiceId)',
      vendorId: '#(vendorId)',
      batchGroupId: #(globalBatchGroupId),
      currency: 'USD',
      invoiceDate: '2022-07-20T00:00:00.000+0000',
      paymentMethod: 'EFT',
      status: 'Open',
      source: 'User',
      vendorInvoiceNo: '#(invoiceId)'
    }
    """
    When method POST
    Then status 201

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And headers headersUser
    And request
    """
    {
      "invoiceId": "#(invoiceId)",
      "invoiceLineStatus": "Open",
      "fundDistributions": [
        {
          "distributionType": "percentage",
          "fundId": "#(globalFundId)",
          "value": "100"
        }
      ],
      "subTotal": "1",
      "description": "line 1",
      "quantity": "1"
    }
    """
    When method POST
    Then status 201


    # ============= get invoice to approve ===================
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"

    # ============= put approved invoice ===================
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    And request invoiceBody
    When method PUT
    Then status 204

    Examples:

    | invoiceId             | vendorId             |
    | twoAddressesInvoice   | twoAddressesVendor   |
    | primaryAddressInvoice | primaryAddressVendor |
    | noAddressInvoice      | noAddressesVendor    |

  Scenario Outline: Check vouchers populated with vendorAddress and vendorId
    * def invoiceId = <invoiceId>
    * def address = <address>
    * def vendorId = <vendorId>

    # ============= Verify vouchers ===================
    Given path '/voucher/vouchers'
    And headers headersUser
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    * def voucherId = $.vouchers[0].id

    Given path '/voucher/vouchers', voucherId
    And headers headersUser
    When method GET
    Then status 200
    And match $.vendorId == vendorId
    And if (response.vendorAddress == null && address == null) karate.abort()
    And match $.vendorAddress.addressLine1 == address.addressLine1
    * match $.vendorAddress.addressLine2 == address.addressLine2
    * match $.vendorAddress.city == address.city
    * match $.vendorAddress.stateRegion == address.stateRegion
    * match $.vendorAddress.zipCode == address.zipCode
    * match $.vendorAddress.country == address.country

    Examples:
      | invoiceId             | address        | vendorId             |
      | twoAddressesInvoice   | primaryAddress | twoAddressesVendor   |
      | noAddressInvoice      | null           | noAddressesVendor    |
      | primaryAddressInvoice | primaryAddress | primaryAddressVendor |

