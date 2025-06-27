let () =
  let args = Sys.argv in
  let command = if Array.length args >= 2 then Some args.(1) else None in
  match command with
  | Some "server" -> Cameldream.Server.start_socket_server ()
  | Some "watch" -> Cameldream.Client.watch ()
  | _ -> Cameldream.Client.oneTime ()
;;
