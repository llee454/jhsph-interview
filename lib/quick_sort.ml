open! Core

let rec pivot_aux xs start len i j =
  if j = start + len
  then ()
  else (
    let r = xs.(start + len - 1) in
    if xs.(j) <= r
    then (
      let x = xs.(i) in
      xs.(i) <- xs.(j);
      xs.(j) <- x;
      pivot_aux xs start len (i + 1) (j + 1) )
    else 
      pivot_aux xs start len i (j + 1) )

let pivot xs start len = pivot_aux xs start len start start

let%expect_test "pivot" =
  let xs = [| 2; 8; 7; 1; 3; 5; 6; 4 |] in
  pivot xs 0 (Array.length xs);
  printf !"%{sexp: int array}" xs;
  [%expect {| (2 1 3 4 7 5 6 8) |}]

let rec sort_aux xs start len =
  pivot xs start len;
  if len <= 2
  then ()
  else (
    let i = (len - 1) / 2 in
    sort_aux xs start (i + 1);
    sort_aux xs (start + i + 1) (len - i - 1) )

let sort xs = sort_aux xs 0 (Array.length xs)

let%expect_test "sort null" =
  let xs = [||] in
  sort xs;
  printf !"%{sexp: int array}" xs;
  [%expect {| () |}]

let%expect_test "sort even" =
  let xs = [| 2; 8; 7; 1; 3; 5; 6; 4 |] in
  sort xs;
  printf !"%{sexp: int array}" xs;
  [%expect {| (1 2 3 4 5 7 6 8) |}]

let%expect_test "sort odd" =
  let xs = [| 2; 8; 7; 1; 3; 5; 6 |] in
  sort xs;
  printf !"%{sexp: int array}" xs;
  [%expect {| (1 2 3 5 6 7 8) |}]