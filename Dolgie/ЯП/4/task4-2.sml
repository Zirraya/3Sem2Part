fun f4 (lst : real list) : (real * real) option =
    if null lst then
        NONE
    else
        let
            val h = hd lst
            (* Recursive helper: processes the tail, accumulates current min and max *)
            fun findMinMax (l : real list) (min : real) (max : real) : (real * real) =
                if null l then
                    (min, max)
                else
                    let
                        val x = hd l
                        val xs = tl l
                        val new_min = if x < min then x else min
                        val new_max = if x > max then x else max
                    in
                        findMinMax xs new_min new_max
                    end
        in
            SOME (findMinMax (tl lst) h h)
        end

(* Tests *)
val test0 = f4 []                                 (* NONE *)
val test1 = f4 [12.0]                             (* SOME (12.0, 12.0) *)

val test2 = f4 [1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 4.0, 5.0, 7.9]
                                                (* SOME (1.0, 7.9) *)

val test3 = f4 [115.5, 111.7, 111.0, 0.5, 2.0, 2.0, 3.0, 3.0, 3.0,
                2.0, 2.0, 1.0, 2.0, 3.0, 3.0, 43.0, 4.0, 5.0, 6.0,
                6.0, 4.0, 7.0]                    (* SOME (0.5, 115.5) *)

val test4 = f4 [~100.5, 3.2, 0.0, ~2.1, 10.7]     (* SOME (~100.5, 10.7) *)

val test5 = f4 [~5.4, 500.0, 55.5, ~5.4]          (* SOME (~5.4, 500.0) *)

val test6 = f4 []                                  (* NONE *)



