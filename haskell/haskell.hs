-- This module defines a function named solution that accepts two
-- maps, m and n, that contain maps storing lists, and merges them
-- so that
--
--   forall k j : string,
--     o.get (k).get (j) =
--     m.get (k).get (j) ++ n.get (k).get (j)
-- 
-- Where o represents the resulting map.
--
-- For simplicity, we represent maps using Haskell's associative
-- lists. Maps are represented as sorted lists of two-tuples,
-- [(k, v), ...], where the first value within each tuple
-- represents the value's key.

module Interview where

import Data.List
import Test.HUnit

--- Represents a map with string keys.
type StringMap a = [(String, a)]

--- Accepts a string map and returns a sorted
-- string map - i.e. a string map sorted by key.
sortMap :: StringMap a -> StringMap a
sortMap = sortOn fst

-- Accepts two arguments: f, a function that
-- transforms map values; and m, a string map;
-- and replaces all values, x, within m with `f x`.
mapMap :: (a -> a) -> StringMap a -> StringMap a
mapMap f = map (\(k, x) -> (k, f x))

-- Accepts three arguments: f, a function that
-- combines values stored within a map; m, a sorted
-- string map; and n, another sorted string map;
-- and returns a new sorted string map, o, that
-- satisfies the following property:
--
--   forall k : string,
--     o.get (k) = f (m.get (k), n.get (k))
--
-- This function arranges the two sorted string
-- maps as a double headed stack, as illustrated
-- below:
--
-- a, 1 | b, 6 <- compare and pop left-most stack
-- b, 2 | d, 9
-- c, 3 |
-- 
-- It then examines the entries at the top of both
-- stacks. If the key of the left-most stack is
-- less than that of the entry on the right-most
-- stack, we prepend the left-most entry to the
-- result, pop the entry from the left-most stack
-- and recurse. We proceed similarily if the key
-- on the entry on the right-most stack is less
-- than that on the left-most stack.
-- 
-- If both entries have the same key we call f
-- to combine their values, prepend the resulting
-- entry to our output map, and recurse.
--
-- When either of the two stacks is empty,
-- we simply return the remaining stack.
merge :: (a -> a -> a) -> StringMap a -> StringMap a -> StringMap a
merge _ [] ys = ys
merge _ xs [] = xs
merge f (x@(j, m):xs) (y@(k, n):ys)
  | j < k
    = x:(merge f xs (y:ys))
  | k < j
    = y:(merge f (x:xs) ys)
  | otherwise -- j = k
    = (j, f m n):(merge f xs ys)

-- Accepts two sorted string maps, m and n,
-- that contain sorted string maps storing lists,
-- and merges them so that:
--
-- forall k j : string,
--   o.get (k).get (j)
--     = m.get (k).get (j) ++
--       n.get (k).get (j)
--
-- where o represents the resulting sorted
-- string map.
solutionAux :: StringMap (StringMap [a]) -> StringMap (StringMap [a]) -> StringMap (StringMap [a])
solutionAux = merge (merge (++))

-- Accepts two string maps, m and n, that
-- contain string maps storing lists, and merges
-- them so that
--
-- forall k j : string,
--   o.get (k).get (j)
--     = m.get (k).get (j) ++
--       n.get (k).get (j)
--
-- where o represents the resulting sorted
-- string map.
solution :: StringMap (StringMap [a]) -> StringMap (StringMap [a]) -> StringMap (StringMap [a])
solution m n
  = solutionAux
      (mapMap sortMap $ sortMap m)
      (mapMap sortMap $ sortMap n)

-- unit tests
test0 = TestCase $ assertEqual "first test"
  [("a",
    [("1", [1, 2, 3, 4]),
     ("2", [5, 6, 7, 8])])] $
  solution
    [("a",
      [("1", [1, 2])])]
    [("a",
      [("1", [3, 4]),
       ("2", [5, 6, 7, 8])])]

test1 = TestCase $ assertEqual "second test"
  [("a", []),
   ("b", [
     ("1", [1, 2, 3]),
     ("2", [4, 5, 6]),
     ("3", [])]),
   ("c", [
     ("7", [8, 9])])] $
  solution
   [("b", [
      ("3", []),
      ("2", [4])]),
    ("a", [])]
   [("c", [
      ("7", [8, 9])]),
    ("b", [
      ("1", [1, 2, 3]),
      ("2", [5, 6])])]

unittests = TestList [
  TestLabel "test0" test0,
  TestLabel "test1" test1]
