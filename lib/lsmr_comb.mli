type t

val init : b:float -> nevents:int -> noutcomes:int -> t

type event_id = int
type outcome_id = int

type proposition = Atomic of atom | Given of atom * condition list
and condition = Is of atom | Not of atom
and atom = { event : event_id; outcome : outcome_id }

type valid_proposition

val validate_proposition : proposition -> valid_proposition option
