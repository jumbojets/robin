open Base
open Bigarray
open Lsmr

type ndarray = (float, float64_elt, c_layout) Genarray.t
type t = { b : float; qs : ndarray }

let init ~b ~nevents ~noutcomes =
  {
    b;
    qs =
      Genarray.init Float64 C_layout (Array.create ~len:nevents noutcomes)
        (fun _ -> 0.);
  }

type event_id = int [@@deriving compare]
type outcome_id = int [@@deriving compare]

type atom = { event : event_id; outcome : outcome_id } [@@deriving compare]
and proposition = Atomic of atom | Given of atom * condition list
and condition = Is of atom | Not of atom

type valid_proposition = proposition

let validate_proposition = function
  | Given (target, conditions) as given ->
      let all_conditions = Is target :: conditions in
      let has_dup_atoms =
        all_conditions
        |> List.map ~f:(function Is e | Not e -> e)
        |> List.contains_dup ~compare:compare_atom
      in
      let has_dup_pos_event =
        all_conditions
        |> List.filter_map ~f:(function
          | Is { event; _ } -> Some event
          | _ -> None)
        |> List.contains_dup ~compare:compare_event_id
      in
      if has_dup_atoms || has_dup_pos_event then None else Some given
  | atom -> Some atom

let spot_price market ~prop =
  (* TODO *)
  0.0
