let get_date () =
  let now = Unix.gettimeofday () in
  let times = Unix.localtime now in
  Printf.sprintf "%02d-%02d-%02d" (times.tm_year + 1900) (times.tm_mon + 1) times.tm_mday
;;

(* https://learnxbyexample.com/ocaml/time/ *)
