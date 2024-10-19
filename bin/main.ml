open! Core
open! Lib

let () =
  let open Lib.Heap_sort in
  let xs = [| 10; 13; 9; 14; 4; 1; 2 |] in
  sort xs;
  printf !"%{sexp: int array}" xs
