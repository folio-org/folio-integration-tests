package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import java.util.concurrent.ThreadLocalRandom
import scala.concurrent.duration._
import scala.language.postfixOps

class BulkOperationsSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = ThreadLocalRandom.current().nextLong(Long.MaxValue)
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/bulk-operations/upload" -> Nil,
    "/bulk-operations/{operationId}/start" -> Nil,
    "/bulk-operations/{operationId}/download" -> Nil,
    "/bulk-operations/{operationId}/preview" -> Nil,
    "/bulk-operations/{operationId}/content-update" -> Nil,
    "/bulk-operations/{operationId}/errors" -> Nil
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:firebird/mod-bulk-operations/mod-bulk-operations-junit.feature"))
  val init = scenario("init")
    .exec(karateFeature("classpath:firebird/mod-bulk-operations/features/init-data/init-data-for-users-gatling.feature"))
  val create = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:firebird/mod-bulk-operations/features/users-positive-scenarios.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(init.inject(nothingFor(3 seconds), atOnceUsers(1)))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)
}
