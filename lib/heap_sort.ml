open! Core

  (**
    Uses an array to represent a binary tree.
  *)
  type t = {
    mutable n: int;  (** the number of values stored within the tree. must be less than arr.length.*)
    arr: int array;  (** the array used to store tree values *)
  }
  [@@deriving sexp]

  let get_level i = Int.floor_log2 (i + 1)

  let%expect_test "get_level" =
    [| 0; 1; 2; 3; 7 |] |> Array.map ~f:get_level |> printf !"%{sexp: int array}";
    [%expect {| (0 1 1 2 3) |}]

  let get_level_start l = Int.(2 ** l) - 1

  let%expect_test "get_level_start" =
    [| 0; 1; 2; 7 |]
    |> Array.map ~f:(Fn.compose get_level get_level_start)
    |> printf !"%{sexp: int array}";
    [%expect {| (0 1 2 7) |}]

  let get_level_offset i = i - get_level_start (get_level i)

  let%expect_test "get_level_offset" =
    [| 0; 1; 2; 7; 8 |] |> Array.map ~f:get_level_offset |> printf !"%{sexp: int array}";
    [%expect {| (0 0 1 0 1) |}]

  (**
    Accepts one argument: the array index of a node [i] and returns
    the array indices of that node's children.
  *)
  let get_child_indices i =
    let offset = get_level_offset i
    and level = get_level i in
    let j = get_level_start (level + 1) + (2 * offset) in
    j, j + 1

  let%expect_test "get_child_indices" =
    [| 0; 1; 2; 9 |] |> Array.map ~f:get_child_indices |> printf !"%{sexp: (int * int) array}";
    [%expect {| ((1 2) (3 4) (5 6) (19 20)) |}]

  (**
    Accepts one argument: [i], a node's array index; and returns
    that node's parent's index.

    Note: if the node is the root node, this function returns None.
  *)
  let get_parent_index i =
    if i = 0
    then None
    else (
      let level = get_level i
      and offset = get_level_offset i in
      Some (get_level_start (level - 1) + (offset / 2)) )

  let%expect_test "get_parent_index" =
    [| 0; 1; 2; 3; 4; 5; 6; 8 |] |> Array.map ~f:get_parent_index |> printf !"%{sexp: int option array}";
    [%expect {| (() (0) (0) (1) (1) (2) (2) (3)) |}]

  (**
    Accepts two arguments: [h], a heap; and [i], a node's array
    index; and reorders the tree starting at [i] so that the tree
    is valid.
    
    Note: To be valid the binary tree must satisfy the following
    property: every node is greater than or equal to its children.
  *)
  let rec adjust_aux (h : t) i =
    let x = h.arr.(i) in
    match get_child_indices i with
    | j, _ when j >= h.n -> () (* in this case i refers to a leaf *)
    | j, k when k >= h.n && h.arr.(j) > h.arr.(i) ->
      (* lower the node *)
      h.arr.(i) <- h.arr.(j);
      h.arr.(j) <- x
    | j, k when h.arr.(j) > h.arr.(i) && h.arr.(j) >= h.arr.(k) ->
      (* sink the node to the left *)
      h.arr.(i) <- h.arr.(j);
      h.arr.(j) <- x;
      adjust_aux h j
    | j, k when h.arr.(k) > h.arr.(i) && h.arr.(k) >= h.arr.(j) ->
      (* sink the node to the right *)
      h.arr.(i) <- h.arr.(k);
      h.arr.(k) <- x;
      adjust_aux h k
    | _ -> () (* the tree is balanced *)

  let%expect_test "adjust_aux" =
    let heap = { n = 10; arr = [| 16; 4; 10; 14; 7; 9; 3; 2; 8; 1; 0; 0; 0; 0 |] } in
    adjust_aux heap 1;
    printf !"%{sexp: t}" heap;
    [%expect {| ((n 10) (arr (16 14 10 8 7 9 3 2 4 1 0 0 0 0))) |}]

  (**
    Accepts a heap that is disordered and reorders it so that it
    is valid - i.e. every node is greater than its children.
  *)
  let adjust (h : t) =
    let i = get_level_start (get_level h.n) - 1 in
    if i = -1
    then ()
    else
      for j = i downto 0 do
        adjust_aux h j
      done

  let%expect_test "adjust" =
    let heap = { n = 10; arr = [| 4; 1; 3; 2; 16; 9; 10; 14; 8; 7; 0; 0; 0; 0 |] } in
    adjust heap;
    printf !"%{sexp: t}" heap;
    [%expect {| ((n 10) (arr (16 14 10 8 7 9 3 2 4 1 0 0 0 0))) |}]

  let rec sort_aux h =
    if h.n = 0
    then ()
    else begin
      let x = h.arr.(0) in
      h.arr.(0) <- h.arr.(h.n - 1);
      h.arr.(h.n - 1) <- x;
      h.n <- h.n - 1;
      adjust_aux h 0;
      sort_aux h
    end

  (**
    Accepts an array and sorts it using heap sort.
  *)
  let sort xs = let h = { n = Array.length xs; arr = xs } in adjust h; sort_aux h

  let%expect_test "sort" =
    let xs = [| 10; 13; 9; 14; 4; 1; 2 |] in
    sort xs;
    printf !"%{sexp: int array}" xs;
    [%expect {| (1 2 4 9 10 13 14) |}]