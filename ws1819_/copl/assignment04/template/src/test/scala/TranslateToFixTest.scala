import org.scalatest.FunSuite
import org.scalatest.prop.TableDrivenPropertyChecks._
import TranslateToFix._

class TranslateToFixTest extends FunSuite {

  def doesNotUseLetRec(e: RCFLAE): Boolean = e match {
    case Num(_) => true
    case Add(lhs, rhs) => doesNotUseLetRec(lhs) && doesNotUseLetRec(rhs)
    case Sub(lhs, rhs) => doesNotUseLetRec(lhs) && doesNotUseLetRec(rhs)
    case Mult(lhs, rhs) => doesNotUseLetRec(lhs) && doesNotUseLetRec(rhs)
    case Let(_, namedExpr, body) => doesNotUseLetRec(namedExpr) && doesNotUseLetRec(body)
    case Id(_) => true
    case Fun(_, body) => doesNotUseLetRec(body)
    case If0(test, posBody, negBody) => doesNotUseLetRec(test) && doesNotUseLetRec(posBody) && doesNotUseLetRec(negBody)
    case LetRec(_, _, _) => false
    case App(funExpr, argExpr) => doesNotUseLetRec(funExpr) && doesNotUseLetRec(argExpr)
  }

  val factorial = LetRec('fac,
    Fun('n,
      If0('n,
        1,
        Mult('n, App('fac, Add('n, -1))))),
    'fac)

  test ("Factorial") {
    val translatedFactorial = translate2Fix(factorial)

    assertResult(false) {
      doesNotUseLetRec(factorial)
    }
    assertResult(NumV(120)) {
      interp(App(factorial, Num(5)))
    }

    assertResult(true) {
      doesNotUseLetRec(translatedFactorial)
    }

    val factorials = Table(("n", "r"), (1, 1), (2, 2), (3, 6), (4, 24), (5, 120), (6, 720))

    forAll(factorials) { (n: Int, r: Int) => assertResult(NumV(r)) {
      interp(App(translatedFactorial, Num(n)))
    }
    }
  }

  test ("Factorial with alternative name") {
    val factorialAlt = LetRec('facAlt,
      Fun('n,
        If0('n,
          1,
          Mult('n, App('facAlt, Add('n, -1))))),
      'facAlt)
    val translatedFactorial = translate2Fix(factorialAlt)

    assertResult(true) {
      doesNotUseLetRec(translatedFactorial)
    }

    val factorials = Table(("n", "r"), (1, 1), (2, 2), (3, 6), (4, 24), (5, 120), (6, 720))

    forAll(factorials) { (n: Int, r: Int) => assertResult(NumV(r)) {
      interp(App(translatedFactorial, Num(n)))
    }
    }
  }

  test("LetRec like normal Let") {
    val program = LetRec('x, Num(5), Add(Num(4), Id('x)))
    val translatedProgram = translate2Fix(program)
    assertResult(true) {
      doesNotUseLetRec(translatedProgram)
    }
    assertResult(interp(program)) {
      interp(translatedProgram)
    }
    assertResult(NumV(9)) {
      interp(translatedProgram)
    }
  }

  test("Shadowing") {
    val program =
      LetRec('fac,
        Fun('n, If0('n, 1, Mult('n, App('fac, Add('n, +1))))), // broken, non-terminating version of factorial
        LetRec('fac,
          Fun('n, If0('n, 1, Mult('n, App('fac, Add('n, -1))))), // working factorial
          App('fac, 5)))
    val translatedProgram = translate2Fix(program)

    assertResult(true) {
      doesNotUseLetRec(translatedProgram)
    }
    assertResult(NumV(120)) {
      interp(program)
    }
    assertResult(NumV(120)) {
      interp(translatedProgram)
    }
  }

  val nestingTestPrograms = Map(
    "Add LHS" -> Add(App(factorial, 5), 1),
    "Add RHS" -> Add(1, App(factorial, 5)),
    "Sub LHS" -> Sub(App(factorial, 5), 1),
    "Sub RHS" -> Sub(1, App(factorial, 5)),
    "Mult LHS" -> Mult(App(factorial, 5), 1),
    "Mult RHS" -> Mult(1, App(factorial, 5)),
    "If0 cond" -> If0(App(factorial, 5), 1, 2),
    "If0 then" -> If0(0, App(factorial, 5), 2),
    "If0 else" -> If0(1, 1, App(factorial, 5)),
    "Let" -> Let('x, App(factorial, 5), Add('x, App(factorial, 5))),
    "App LHS" -> App(factorial, 5),
    "App RHS" -> App(factorial, App(factorial, 5)),
    // have to apply Fun because the resulting closures would obviously be different
    "Fun" -> App(Fun('x, App(factorial, 5)), 1),
    "LetRec namedExpr" ->
      LetRec('fac, LetRec('fac2, Fun('n, If0('n, 1, Mult('n, App('fac2, Add('n, -1))))), App('fac2, 5)), 'fac),
    "LetRec body" ->
      LetRec('fac, Fun('n, If0('n, 1, Mult('n, App('fac, Add('n, -1))))),
        LetRec('fac2, Fun('n, If0('n, 1, Mult('n, App('fac, Add('n, -1))))),
          App('fac2, 5)))
  )

  for ((name, program) <- nestingTestPrograms) {
    test(s"Nesting $name") {
      val translatedProgram = translate2Fix(program)
      assertResult(true) {
        doesNotUseLetRec(translatedProgram)
      }
      assertResult(interp(program)) {
        interp(translatedProgram)
      }
    }
  }
}
