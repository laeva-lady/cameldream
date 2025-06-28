let print_help () =
  Printf.printf "Usage:\n";
  Printf.printf "\tcameldream <commands>\n\n";
  Printf.printf "Commands:\n";
  Printf.printf "\tserver       Start the server\n";
  Printf.printf "\twatch        Print the usage in a loop\n";
  Printf.printf
    "\thelp         Print this message (cannot be used with other commands)\n\n";
  Printf.printf
    "\tmonth        add `month` to display this month's usage (avoid using it with \
     `watch` since the output can be pretty long)\n\n";
  Printf.printf
    "\t(more than one command can be added, no need to be in a specific order either:\n";
  Printf.printf "\te.g. `cameldream server watch`)\n\n";
  Printf.printf "If no command or an unknown command is passed, usage will be printed.\n"
;;

let () =
  let flags = Cameldream.Utils.handle_flags Sys.argv in
  if flags.help
  then print_help ()
  else (
    let threads = ref [] in
    if flags.server
    then (
      let t = Thread.create (fun () -> Cameldream.Server.start_socket_server ()) () in
      threads := t :: !threads);
    if flags.watch
    then (
      let t =
        Thread.create
          (fun () ->
             if not flags.monthly
             then Cameldream.Client.watch ()
             else Cameldream.Monthly.watch ())
          ()
      in
      threads := t :: !threads);
    if flags.server || flags.watch
    then List.iter Thread.join !threads
    else if not flags.monthly
    then Cameldream.Client.oneTime ()
    else Cameldream.Monthly.monthly ())
;;
