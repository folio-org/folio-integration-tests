@ignore @report=false
Feature: dev

  Scenario: init dev data
    * def testAdmin = { tenant: '#(tenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(tenant)', name: 'test-user', password: 'test' }

    * def dev = {}
    * set dev.uuid[0] = 'fa3feb3d-68a9-4b99-98e6-c97a155f0e9f'
    * set dev.uuid[1] = 'e5b4e4b1-0773-40c8-b38e-ad15029870b7'
    * set dev.uuid[2] = 'ca69aa58-9c60-479b-8285-422720a5aee4'
    * set dev.uuid[3] = '1fdc4ff3-0b3d-4b39-8b0b-1aacbb7fe50e'
    * set dev.uuid[4] = '0ad987e3-8a5c-4713-bc35-55542e1b1119'
    * set dev.uuid[5] = '3fb9911e-65d2-43f9-9e3b-c32be9c2d140'
    * set dev.uuid[6] = 'a0ccaa92-21b0-48bd-8767-5bd824275e8d'
    * set dev.uuid[7] = 'da56dbd6-b3a9-4255-a728-a06eb3e29564'
    * set dev.uuid[8] = '485bacda-f127-46b8-a70e-9f7f9f3a9da4'
    * set dev.uuid[9] = '5e56f16a-53fd-45c3-93ad-917bbee21ae6'
    * set dev.uuid[10] = '408d0dc4-fe4c-4e4d-8fe0-258f31fc7e10'
    * set dev.uuid[11] = '0ac59f7a-e1b2-4416-9521-22b091ddc558'
    * set dev.uuid[12] = 'b067cf95-b990-4b7e-8c99-ca21763d93a8'
    * set dev.uuid[13] = '44c39fd9-237e-446c-bedd-bc102967ed0b'
    * set dev.uuid[14] = '93ed9abc-8ac0-42db-a622-d741ff4f6154'
    * set dev.uuid[15] = '664e6a42-45a0-45df-bf05-fd231944a4e5'

