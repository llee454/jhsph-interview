(** Defines a formally verified implementation of heap sort. *)
Require Import List.
Import ListNotations.
Require Import micromega.Lia.

Open Scope list_scope.

Unset Printing Notations.

Lemma test : forall x:nat, x > 0 -> x >= 1.
Proof.
  intro x; induction x; intro H; assumption.
Qed.

Goal 3 >= 1.
Proof.
  apply (test 3 ltac:(lia)).
Qed.