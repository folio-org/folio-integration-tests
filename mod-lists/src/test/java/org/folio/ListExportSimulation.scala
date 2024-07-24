package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class ListExportSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/users/{userId}" -> Nil,
    "/lists" -> Nil,
    "/lists/{listId}" -> Nil,
    "/lists/{listId}/exports" -> Nil,
    "/lists/{listId}/exports/{exportId}" -> Nil,
    "/lists/{listId}/refresh" -> Nil,
    "/lists/{listId}/contents" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:corsair/mod-lists/lists-junit.feature"))
  val export = scenario("export")
    .repeat(10) {
      exec(karateFeature("classpath:corsair/mod-lists/features/export.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(export.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
