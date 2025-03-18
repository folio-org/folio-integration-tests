Feature: mod-calendar integration tests

  Background:
    * url baseUrl
    * table userPermissions
      | name                                                  |
      | 'calendar.endpoint.calendars.post'                    |
      | 'calendar.endpoint.calendars.get'                     |
      | 'calendar.endpoint.calendars.delete'                  |
      | 'calendar.endpoint.calendars.calendarId.delete'       |
      | 'calendar.endpoint.calendars.calendarId.put'          |
      | 'calendar.endpoint.calendars.allOpenings.get'         |
      | 'calendar.endpoint.calendars.surroundingOpenings.get' |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')