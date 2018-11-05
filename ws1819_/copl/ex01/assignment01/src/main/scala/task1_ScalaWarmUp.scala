object ScalaWarmUp {

  // --------------------------------------------
  // --- PUT ALL YOUR CHANGES BELOW THIS LINE ---
  // --------------------------------------------


    def extender[A](a : List[A], b : List[List[A]]): List[A] = a match {
        case Nil => flatten(b)
        case x::s => x :: extender(s, b)
    }
    def flatten[A](xss : List[List[A]]) : List[A] =  xss match {
        case Nil => Nil
        case x::ss => extender(x, ss)

    }
    def reverser[A](l : List[A], c : List[A]) : List[A] = l match {
        case Nil => c
        case x::ss =>       val temp = x :: c
                            reverser(ss, temp)

    }
    def reverse[A](l: List[A]): List[A] = {
        reverser(l, Nil)
    }

    }