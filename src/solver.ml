module Z3 = Encoding.Solver.Batch (Encoding.Z3_mappings2)

type solver = Z3.t

let fresh_solver () = Z3.create ~logic:QF_BVFP ()
