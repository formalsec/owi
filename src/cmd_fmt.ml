(* SPDX-License-Identifier: AGPL-3.0-or-later *)

open Syntax

let get_printer filename =
  if not @@ Sys.file_exists filename then
    error_s "file `%s` doesn't exist" filename
  else
    let ext = Filename.extension filename in
    match ext with
    | ".wat" ->
      Result.bind (Parse.Module.from_file ~filename) (fun v ->
          Ok (fun fmt () -> Text.pp_modul fmt v) )
    | ".wast" ->
      Result.bind (Parse.Script.from_file ~filename) (fun v ->
          Ok (fun fmt () -> Text.pp_script fmt v) )
    | _ -> error_s "unsupported file extension"

let cmd inplace (file : string) =
  match get_printer file with
  | Error e ->
    Format.pp_err "%s@." e;
    exit 1
  | Ok pp ->
    if inplace then
      let chan = open_out file in
      Fun.protect
        ~finally:(fun () -> close_out chan)
        (fun () ->
          let fmt = Stdlib.Format.formatter_of_out_channel chan in
          Format.pp fmt "%a@\n" pp () )
    else Format.pp_std "%a@\n" pp ()
