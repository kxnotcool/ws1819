import org.scalatest.FunSuite
import LetRecWithMultipleDefinitions._

class LetRecWithMultipleDefinitionsTest extends FunSuite {
  test("Simple Recursion") {
    assertResult(NumV(120)) {
      interp(LetRec(List('fac -> Fun('n,
                                  If0('n,
                                      1,
                                      Mult('n, App('fac, Add('n, -1)))))),
                 App('fac, 5))) }}

  test("Mutual Recursion 1") { assertResult(NumV(1)) {
    interp(LetRec(List('odd -> Fun('n,
                                  If0('n,
                                      0,
                                      App('even, Sub('n, 1)))),
                      'even -> Fun('n,
                                   If0('n,
                                       1,
                                       App('odd, Sub('n, 1))))),
                 App('odd, 5))) }}

  test("Mutual Recursion 2") { assertResult(NumV(0)) {
    interp(LetRec(List('mod3 -> Fun('n,
                                   If0('n,
                                       0,
                                       App('mod3_1, Sub('n, 1)))),
                      'mod3_1 -> Fun('n,
                                     If0('n,
                                         1,
                                         App('mod3_2, Sub('n, 1)))),
                      'mod3_2 -> Fun('n,
                                     If0('n,
                                         2,
                                         App('mod3, Sub('n, 1))))),
                 App('mod3, 42))) }}

  test("Nested LetRec") { assertResult(NumV(5040)) {
    interp(LetRec(List('fac -> Fun('n,
                                  If0('n,
                                      1,
                                      Mult('n, App('fac, Add('n, -1)))))),
                 LetRec(List('odd -> Fun('n,
                                      If0('n,
                                          0,
                                          App('even, Sub('n, 1)))),
                          'even -> Fun('n,
                                       If0('n,
                                           1,
                                           App('odd, Sub('n, 1))))),
                     If0(App('odd, 7), App('fac, 12), App('fac, 7))))) }}

  test("Shadowing") { assertResult(NumV(105)) {
    interp(LetRec(List('a -> Fun('x, App('sub3, 'x)),
                      'sub3 -> Fun('x, Sub('x, 3))),
                 LetRec(List('sub3 -> Fun('x, Mult('x, 9)),
                          'x -> Fun('y, Mult(3, 'y))),
                     App('a, App('sub3, 12))))) }}
}
