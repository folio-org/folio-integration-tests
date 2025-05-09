package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import scala.concurrent.duration._
import scala.language.postfixOps
import scala.util.Random

class ListLifecycleSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = Random.nextLong()
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
    "/lists/{listId}/versions" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:corsair/mod-lists/lists-junit.feature"))
  val perform = scenario("perform")
    .repeat(10) {
      exec(karateFeature("classpath:corsair/mod-lists/features/create.feature"))
    }
    .repeat(10) {
      exec(karateFeature("classpath:corsair/mod-lists/features/update.feature"))
    }
    .repeat(10) {
      exec(karateFeature("classpath:corsair/mod-lists/features/versions.feature"))
    }
    .repeat(10) {
      exec(karateFeature("classpath:corsair/mod-lists/features/delete.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(perform.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
