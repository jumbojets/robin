open Base
open Bigarray

type t = { b : float; qs : ndarray }
and ndarray = (float, float64_elt, c_layout) Genarray.t

let init ~b ~nevents ~noutcomes =
  let dims = Array.create ~len:nevents noutcomes in
  let qs = Genarray.create Float64 C_layout dims in
  Genarray.fill qs 0.;
  { b; qs }

type event_id = int [@@deriving compare]
type outcome_id = int [@@deriving compare]

type proposition = Atomic of atom | Given of atom * condition list
and condition = Is of atom | Not of atom
and atom = { event : event_id; outcome : outcome_id } [@@deriving compare]

type valid_proposition = proposition

let validate_proposition = function
  | Given (target, conditions) as given ->
      let all_conditions = Is target :: conditions in
      let contains_dup_atoms =
        all_conditions
        |> List.map ~f:(function Is e | Not e -> e)
        |> List.contains_dup ~compare:compare_atom
      in
      let contains_dup_pos_events =
        all_conditions
        |> List.filter_map ~f:(function
          | Is { event; _ } -> Some event
          | _ -> None)
        |> List.contains_dup ~compare:compare_event_id
      in
      if contains_dup_atoms || contains_dup_pos_events then None else Some given
  | atom -> Some atom

let spot_price market ~prop =
  (* TODO *)
  0.0
