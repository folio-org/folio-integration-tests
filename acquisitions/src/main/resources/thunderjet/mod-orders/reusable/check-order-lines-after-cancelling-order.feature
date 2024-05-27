@ignore
Feature: Check order lines after cancelling order
  # parameters: orderId, fundId

  Background: checkOrderLinesAfterCancelingOrder
    * url baseUrl

  Scenario: Check order lines after cancelling order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def poLines = $.compositePoLines
    * def line1 = poLines[0]
    * match line1.paymentStatus == 'Cancelled'
    * match line1.receiptStatus == 'Cancelled'
    * def line2 = poLines[1]
    * match line2.paymentStatus == 'Payment Not Required'
    * match line2.receiptStatus == 'Cancelled'
    * def line3 = poLines[2]
    * match line3.paymentStatus == 'Fully Paid'
    * match line3.receiptStatus == 'Receipt Not Required'
    * def line4 = poLines[3]
    * match line4.paymentStatus == 'Cancelled'
    * match line4.receiptStatus == 'Fully Received'