Feature: Automated patron blocks

  @Undefined
  Scenario: Should return 'Bad request' error when called with invalid user ID
    * print 'undefined'

  @Undefined
  Scenario: No blocks when user summary does not exist
    * print 'undefined'

  @Undefined
  Scenario: No blocks when no limits exist for patron group
    * print 'undefined'

  # Max number of items charged out

  @Undefined
  Scenario: No blocks when 'Max number of items charged out' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of items charged out' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of items charged out' limit is exceeded and all limits exist
    * print 'undefined'

  # Max number of lost items - declared lost

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items declared lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items declared lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items declared lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items declared lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items declared lost
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items declared lost and all limits exist
    * print 'undefined'

  # Max number of lost items - aged to lost

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items aged to lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is not reached with items aged to lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items aged to lost
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of lost items' limit is reached with items aged to lost and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items aged to lost
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of lost items' limit is exceeded with items aged to lost and all limits exist
    * print 'undefined'
    
  # Max number of overdue items

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue items' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue items' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue items' limit is exceeded and all limits exist
    * print 'undefined'
    
  # Max number of overdue recalls

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max number of overdue recalls' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue recalls' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max number of overdue recalls' limit is exceeded and all limits exist
    * print 'undefined'

  # Recall overdue by maximum number of days

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Recall overdue by maximum number of days' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Recall overdue by maximum number of days' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Recall overdue by maximum number of days' limit is exceeded and all limits exist
    * print 'undefined'
    
  # Max outstanding fee/fine balance

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is not reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is not reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is reached
    * print 'undefined'

  @Undefined
  Scenario: No block when 'Max outstanding fee/fine balance' limit is reached and all limits exist
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max outstanding fee/fine balance' limit is exceeded
    * print 'undefined'

  @Undefined
  Scenario: Block exists when 'Max outstanding fee/fine balance' limit is exceeded and all limits exist
    * print 'undefined'

  # All limits

  @Undefined
  Scenario: Everything is blocked when all limits are exceeded
    * print 'undefined'

  @Undefined
  Scenario: Nothing is blocked when all limits are exceeded for items claimed returned
    * print 'undefined'

  # Other

  @Undefined
  Scenario: Updated values from condition are passed to response
    * print 'undefined'

  @Undefined
  Scenario: No block when loan is not overdue
    * print 'undefined'

  @Undefined
  Scenario: No block when loan is not overdue because of grace period
    * print 'undefined'

  @Undefined
  Scenario: Block when loan is overdue
    * print 'undefined'

  @Undefined
  Scenario: Block when loan is overdue and grace period exists
    * print 'undefined'

  @Undefined
  Scenario: Items declared lost and aged to lost are combined for max number of lost items block
    * print 'undefined'
