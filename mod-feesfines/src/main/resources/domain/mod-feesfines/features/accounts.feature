Feature: Fee/fine accounts tests

  # CRUD

  @Undefined
  Scenario: Create an account
    * print 'undefined'

  @Undefined
  Scenario: Get a list of accounts
    * print 'undefined'

  @Undefined
  Scenario: Get an account by ID
    * print 'undefined'

  @Undefined
  Scenario: Update an account
    * print 'undefined'

  @Undefined
  Scenario: Delete an account
    * print 'undefined'

  @Undefined
  Scenario: Can create an account without optional referenced entity IDs
    * print 'undefined'

  @Undefined
  Scenario: Can not create an account without required referenced entity IDs
    * print 'undefined'

  @Undefined
  Scenario: Can not create an account with invalid UUID for any of the referenced entities
    * print 'undefined'

  # Event publishing

  @Undefined
  Scenario: Event is published when account is created/updated/deleted
    * print 'undefined'

  @Undefined
  Scenario: Event is published when fee/fine related to a loan is paid fully and closed with no remaining amount
    * print 'undefined'

  @Undefined
  Scenario: Event is not published when fee/fine related to a loan is closed with remaining amount
    * print 'undefined'

  @Undefined
  Scenario: Event is not published when fee/fine not related to a loan is closed
    * print 'undefined'

  @Undefined
  Scenario: Event is not published when fee/fine is opened with zero remaining amount
    * print 'undefined'

  @Undefined
  Scenario: Can close a fee/fine related to a loan when there are no subscribers
    * print 'undefined'

  @Undefined
  Scenario: Pub-sub error on fee/fine closure is forwarded
    * print 'undefined'

  # Check actions

  @Undefined
  Scenario: "check-pay" amount should be allowed when it doesn't exceed the remaining amount
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" amount should not be allowed when it exceeds the remaining amount
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" amount should not be allowed when it is negative
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" amount should not be allowed when it is zero
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" amount should be numeric
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" should not fail for nonexistent account
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" should not be allowed for a closed account
    * print 'undefined'

  @Undefined
  Scenario: "check-pay" should handle long decimals correctly
    * print 'undefined'

  @Undefined
  Scenario: Failed "check-pay" return the initial requested amount
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" amount should be allowed when it doesn't exceed the remaining amount
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" amount should not be allowed when it exceeds the remaining amount
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" amount should not be allowed when it is negative
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" amount should not be allowed when it is zero
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" amount should be numeric
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" should not fail for nonexistent account
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" should not be allowed for a closed account
    * print 'undefined'

  @Undefined
  Scenario: "check-waive" should handle long decimals correctly
    * print 'undefined'

  @Undefined
  Scenario: Failed "check-waive" return the initial requested amount
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" amount should be allowed when it doesn't exceed the remaining amount
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" amount should not be allowed when it exceeds the remaining amount
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" amount should not be allowed when it is negative
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" amount should not be allowed when it is zero
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" amount should be numeric
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" should not fail for nonexistent account
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" should not be allowed for a closed account
    * print 'undefined'

  @Undefined
  Scenario: "check-transfer" should handle long decimals correctly
    * print 'undefined'

  @Undefined
  Scenario: Failed "check-transfer" return the initial requested amount
    * print 'undefined'

  # Bulk check actions

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should be allowed when amount not exceeded
    * print 'undefined'

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is negative
    * print 'undefined'

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is zero
    * print 'undefined'

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should not be allowed when amount is not numeric
    * print 'undefined'

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should succeed for nonexistent account
    * print 'undefined'

  @Undefined
  Scenario: Bulk check for pay, waive and transfer actions should not be allowed for closed account
    * print 'undefined'

  # Bulk check for refund action

  @Undefined
  Scenario: Bulk refund should be allowed when amount is not exceeded
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund should not be allowed when amount is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund should not be allowed when amount is negative
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund should not be allowed when amount is zero
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund should not be allowed when amount is not numeric
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund should be allowed when account is nonexistent
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund should return correct remaining amount with similar account IDs
    * print 'undefined'

  # Account pay, waive and transfer actions

  @Undefined
  Scenario: Pay, waive and transfer actions should return 404 when account doesn't exist
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should return 422 when amount is negative
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should return 422 when amount is zero
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should return 422 when amount is invalid
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should return 422 when account is closed
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should return 422 and account is effectively closed
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should handle long decimals correctly and close account
    * print 'undefined'

  @Undefined
  Scenario: Pay, waive and transfer actions should handle long decimals correctly
    * print 'undefined'

  @Undefined
  Scenario: Partial pay, waive and transfer actions should create action and update account
    * print 'undefined'

  @Undefined
  Scenario: Full pay, waive and transfer actions should create action and update account
    * print 'undefined'

  # Account cancel action

  @Undefined
  Scenario: Cancel action should cancel account
    * print 'undefined'

  @Undefined
  Scenario: Bulk cancel action should cancel account
    * print 'undefined'

  @Undefined
  Scenario: Cancel action should use cancellation reason
    * print 'undefined'

  @Undefined
  Scenario: Cancel action should return 404 when account doesn't exist
    * print 'undefined'

  @Undefined
  Scenario: Bulk cancel action should return 404 when account doesn't exist
    * print 'undefined'

  @Undefined
  Scenario: Cancel action should return 422 when account is closed
    * print 'undefined'

  @Undefined
  Scenario: Bulk cancel action should return 422 when account is closed
    * print 'undefined'

  # Account refund action

  @Undefined
  Scenario: Full refund of a closed account with payment
    * print 'undefined'

  @Undefined
  Scenario: Full refund of a closed account with transfer
    * print 'undefined'

  @Undefined
  Scenario: Full refund of a closed account with payment and transfer
    * print 'undefined'

  @Undefined
  Scenario: Full refund of an open account with payment
    * print 'undefined'

  @Undefined
  Scenario: Full refund of an open account with transfer
    * print 'undefined'

  @Undefined
  Scenario: Full refund of an open account with payment and transfer
    * print 'undefined'

  @Undefined
  Scenario: Partial refund of a closed account with payment
    * print 'undefined'

  @Undefined
  Scenario: Partial refund of a closed account with transfer
    * print 'undefined'

  @Undefined
  Scenario: Partial refund of a closed account with payment and transfer
    * print 'undefined'

  @Undefined
  Scenario: Partial refund of an open account with payment
    * print 'undefined'

  @Undefined
  Scenario: Partial refund of an open account with transfer
    * print 'undefined'

  @Undefined
  Scenario: Partial refund of an open account with payment and transfer
    * print 'undefined'

  @Undefined
  Scenario: Refund should fail when requested amount exceeds refundable amount
    * print 'undefined'

  @Undefined
  Scenario: Refund should fail when there are no refundable actions for account
    * print 'undefined'

  @Undefined
  Scenario: Refund should return 404 when account doesn't exist
    * print 'undefined'

  @Undefined
  Scenario: Refund should return 422 when requested amount is negative
    * print 'undefined'

  @Undefined
  Scenario: Refund should return 422 when requested amount is zero
    * print 'undefined'

  @Undefined
  Scenario: Refund should return 422 when requested amount is invalid
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund amount is distributed between accounts evenly recursively
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund fails when requested amount exceeds refundable amount
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund fails when there are no refundable actions for account
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund return 404 when account doesn't exist
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund return 422 when requested amount is negative
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund return 422 when requested amount is zero
    * print 'undefined'

  @Undefined
  Scenario: Bulk refund return 422 when requested amount is invalid
    * print 'undefined'

    @Undefined
  Scenario: Refund for transfers to multiple transfer accounts
    * print 'undefined'

    @Undefined
  Scenario: Bulk refund for transfers to multiple transfer accounts
    * print 'undefined'