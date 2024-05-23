type path = { mutable d : Fpath.t }

let queries_path = { d = Fpath.v "queries" }

let serialize =
  let counter = Atomic.make 0 in
  fun (pc : Smtml.Expr.t list) (answer : Smtml.Solver.satisfiability) ->
    let pp_ans fmt = function
      | `Sat -> Format.pp fmt "sat"
      | `Unsat -> Format.pp fmt "unsat"
      | `Unknown -> Format.pp fmt "unknown"
    in
    let count = Atomic.fetch_and_add counter 1 in
    let path =
      Fpath.(queries_path.d / Format.sprintf "query-%05d.smtml" count)
    in
    match Bos.OS.File.writef path "; %a@\n%a" pp_ans answer Smtml.Expr.pp_smt pc with
    | Ok () -> ()
    | Error (`Msg m) -> Format.pp_err "Error: %s@." m
