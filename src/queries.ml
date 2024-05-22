type path = { mutable d : Fpath.t }

let queries_path = { d = Fpath.v "queries" }

let serialize =
  let counter = Atomic.make 0 in
  fun pc ->
    let count = Atomic.fetch_and_add counter 1 in
    let path =
      Fpath.(queries_path.d / Format.sprintf "query-%05d.smtml" count)
    in
    match Bos.OS.File.writef path "%a" Smtml.Expr.pp_smt pc with
    | Ok () -> ()
    | Error (`Msg m) -> Format.pp_err "Error: %s@." m
