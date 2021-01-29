Feature: Check needReEncumber flag populated correctly

  Background:
    * url baseUrl
    # uncomment below line for development
    # * callonce dev {tenant: 'test_orders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def plannedFiscalYearId = karate.get('plannedFiscalYearId', globalPlannedFiscalYearId)

    * def approvalsFundTypeId = karate.get('approvalsFundTypeId', globalFundType)

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def rolloverId = callonce uuid5
    * def rolloverErrorId = callonce uuid6

    * def fundId = callonce uuid7
    * def budgetId = callonce uuid8

  Scenario Outline: prepare finances for fiscal year with <fiscalYearId>

    Examples:
      | fiscalYearId |

  Scenario Outline: prepare finances for ledger with <ledgerId>

    Examples:
      | ledgerId |

  Scenario Outline: prepare finances for rollover with <rolloverId>

    Examples:
      | rolloverId |

  Scenario Outline: prepare finances for orders transaction summary with <orderId>

    Examples:
      | orderId |

  Scenario Outline: prepare finance for transactions with <transactionId>

    Examples:
      | transactionId |

  Scenario Outline: prepare order with orderId <orderId>

    Examples:
      | orderId |

  Scenario Outline: prepare order lines with orderLineId <orderLineId>

    Examples:
      | orderLineId |

  Scenario Outline: open orders with orderId <orderId>

    Examples:
      | orderId |

  Scenario Outline: re-encumber orders with orderId <orderId>

    Examples:
      | orderId |


  Scenario Outline: check orderLines after re-encumber

    Examples:
      | orderLindId |

  Scenario Outline: check encumbrances after re-encumber

    Examples:
      | orderLineId |

  Scenario Outline: check rollover errors after re-encumbrance

    Examples:
      | rolloverId |

