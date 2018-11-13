package task2_implementing_and_using_extended_F1LAE

import ExtendedF1LAE._

object Fibonacci {

  // --------------------------------------------
  // --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
  // --------------------------------------------

  // Define your function here
  // (the example definition always returns the argument n)











  val fibDefs = Map('fib -> FunDef('fib, 'n, If0(Sub(Id('n), Num(0)), Num(0), If0(Sub(Id('n), Num(1)), Num(1), Add(App('fib, Sub(Id('n), Num(1))), App('fib, Sub(Id('n), Num(2))))))))

}
