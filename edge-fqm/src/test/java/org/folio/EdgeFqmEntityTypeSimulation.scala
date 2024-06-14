package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class EdgeFqmEntityTypeSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/query" -> Nil,
    "/query/{queryId}" -> Nil,
    "/query/purge" -> Nil,
    "/entity-types" -> Nil,
    "/entity-types/{entityTypeId}" -> Nil,
    "/entity-types/{entityTypeId}/columns/{columnName}/values" -> Nil,
    "/users/{userId}" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:corsair/edge-fqm/edge-fqm-junit.feature"))
  val perform = scenario("perform")
    .repeat(10) {
      exec(karateFeature("classpath:corsair/edge-fqm/features/edge-entity-types.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(perform.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
