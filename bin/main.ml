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
  if Array.exists (fun x -> x = "server") args
  then Cameldream.Server.start_socket_server ();
  if Array.exists (fun x -> x = "watch") args then Cameldream.Client.watch ();
  if Array.exists (fun x -> x = "help") args then print_help ();
  if Array.length args = 1 then Cameldream.Client.oneTime ()
;;
