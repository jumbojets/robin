open Base

type t = { b : float; qs : float array }

let init ~b ~n = { b; qs = Array.create ~len:n 0.0 }

let lse ~logits ~temp =
  let max_q = Array.fold logits ~init:Float.neg_infinity ~f:Float.max in
  Array.fold logits ~init:0.0 ~f:(fun acc q ->
      acc +. Float.exp ((q -. max_q) /. temp))
  |> Float.log
  |> fun x -> x +. (max_q /. temp)

let cost_function market = market.b *. lse ~logits:market.qs ~temp:market.b

let spot_price market ~outcome =
  Float.exp
    ((market.qs.(outcome) /. market.b) -. lse ~logits:market.qs ~temp:market.b)

let trade_cost market ~outcome ~nshares =
  let qs' = Array.copy market.qs in
  qs'.(outcome) <- qs'.(outcome) +. nshares;
  let market' = { market with qs = qs' } in
  cost_function market' -. cost_function market

let move_to_price market ~outcome ~price =
  let logit_price = Float.log (price /. (1. -. price)) in
  let qs' = Array.copy market.qs in
  qs'.(outcome) <- 0.;
  let qi_new = market.b *. (logit_price +. lse ~logits:qs' ~temp:market.b) in
  qi_new -. market.qs.(outcome)

let execute_buy market ~outcome ~nshares =
  let qs' = Array.copy market.qs in
  qs'.(outcome) <- qs'.(outcome) +. nshares;
  { market with qs = qs' }
