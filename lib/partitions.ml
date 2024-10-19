(**
  This module defines datatypes and functions for representing
  finite partitions with condition rates defined over them and
  combining these partitions and rate estimates.
*)
open! Core

module Info = struct
  (** Represents information about the entities grouped within an interval. *)
  type 'a t = {
    rate: 'a;
    proportion: float;
  }
  [@@deriving sexp]
end

module Interval = struct
  (** Represents a closed-open interval. *)
  type 'a t = {
    info: 'a Info.t;
    start: int;
    _end: int;
  }
  [@@deriving sexp]
end

(** Represents annotated partitions *)
type 'a t = 'a Interval.t list [@@deriving sexp]

let rec scan (xs : float t) (ys : float t) : (float * float) t =
  match xs, ys with
  | [], _ -> []
  | _, [] -> []
  | x :: xs', y :: ys' -> (
    match () with
    | () when x.start = y.start -> stretch x.start Info.{ rate = 0.0, 0.0; proportion = 0.0 } xs ys
    | () when x.start < y.start -> scan xs' ys
    | () when x.start > y.start -> scan xs ys'
    | _ -> failwiths ~here:[%here] "Error: an internal error occured." () [%sexp_of: unit] )

and stretch (start : int) (info : (float * float) Info.t) (xs : float t) (ys : float t) :
  (float * float) t =
  match xs, ys with
  | [], _ -> []
  | _, [] -> []
  | x :: xs', y :: ys' -> (
    match () with
    | () when x._end = y._end ->
      Interval.
        {
          info =
            Info.
              {
                rate =
                  ( fst info.rate +. (x.info.rate *. x.info.proportion),
                    snd info.rate +. (y.info.rate *. y.info.proportion) );
                proportion = info.proportion +. x.info.proportion;
              };
          start;
          _end = x._end;
        }
      :: scan xs' ys'
    | () when x._end < y._end ->
      stretch start
        Info.
          {
            rate = fst info.rate +. (x.info.rate *. x.info.proportion), snd info.rate;
            proportion = info.proportion +. x.info.proportion;
          }
        xs' ys
    | () when x._end > y._end ->
      stretch start
        Info.
          {
            rate = fst info.rate, snd info.rate +. (y.info.rate *. y.info.proportion);
            proportion = info.proportion;
          }
        xs ys'
    | _ -> failwiths ~here:[%here] "Error: an internal error occured." () [%sexp_of: unit] )

let%expect_test "scan" =
  let xs =
    [
      Interval.{ info = Info.{ rate = 25.7; proportion = 0.25 }; start = 0; _end = 14 };
      Interval.{ info = Info.{ rate = 2021.6; proportion = 0.25 }; start = 15; _end = 19 };
    ]
  and ys =
    [
      Interval.{ info = Info.{ rate = 25.7; proportion = 0.25 }; start = 0; _end = 14 };
      Interval.{ info = Info.{ rate = 2021.6; proportion = 0.25 }; start = 15; _end = 19 };
    ]
  in
  scan xs ys |> printf !"%{sexp: (float * float) t}";
  [%expect
    {|
    (((info ((rate (6.425 6.425)) (proportion 0.25))) (start 0) (_end 14))
     ((info ((rate (505.4 505.4)) (proportion 0.25))) (start 15) (_end 19)))
    |}]
