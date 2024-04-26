package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import java.util.concurrent.ThreadLocalRandom
import scala.concurrent.duration._
import scala.language.postfixOps

class CrossModulesSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong =  ThreadLocalRandom.current().nextLong()
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/finance/fiscal-years/{fiscalYearId}" -> Nil,
    "/finance/fiscal-years" -> Nil,
    "/finance/budgets/{budgetId}" -> Nil,
    "/orders/composite-orders" -> Nil,
    "/orders/order-lines" -> Nil,
    "/invoice/invoices" -> Nil,
    "/invoice/invoices/{invoiceId}" -> Nil,
    "/invoice/invoice-lines" -> Nil,
    "/invoice/invoice-lines/{invoiceLineId}" -> Nil,
    "/invoice-storage/invoices{invoiceId}" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:thunderjet/cross-modules/cross-modules-junit.feature"))
  val create = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/cross-modules/features/approve-invoice-using-different-fiscal-years.feature"))
    }
  val after = scenario("after").exec(karateFeature("classpath:common/destroy-data.feature"))

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
      .andThen(after.inject(nothingFor(3 seconds), atOnceUsers(1))),
  ).protocols(protocol)

}
