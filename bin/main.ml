let print_help () =
  Printf.printf "Usage:\n";
  Printf.printf "  cameldream <command>\n\n";
  Printf.printf "Commands:\n";
  Printf.printf "  server       Start the server\n";
  Printf.printf "  watch        Print the usage in a loop\n\n";
  Printf.printf "If no command or an unknown command is passed, usage will be printed.\n"
;;

let () =
  let args = Sys.argv in
  let command = if Array.length args >= 2 then Some args.(1) else None in
  match command with
  | Some "server" -> Cameldream.Server.start_socket_server ()
  | Some "watch" -> Cameldream.Client.watch ()
  | Some "--help" -> print_help ()
  | _ -> Cameldream.Client.oneTime ()
;;
