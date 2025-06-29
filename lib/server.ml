let getSocketPath () =
  Sys.getenv "XDG_RUNTIME_DIR"
  ^ "/hypr/"
  ^ Sys.getenv "HYPRLAND_INSTANCE_SIGNATURE"
  ^ "/.socket2.sock"
;;

let active_window = ref (Clients.get_active_client ())

let rec socketloop_activewindow sock =
  (* read from the buffer *)
  let buffer =
    try Bytes.create 1024 with
    | Invalid_argument e -> failwith ("Invalid argument or something: " ^ e)
  in
  let bytes_read = Unix.read sock buffer 0 1024 in
  (* Return the data as a string *)
  let msg = Bytes.sub_string buffer 0 bytes_read in
  let lines = String.split_on_char '\n' msg in
  List.iter
    (fun line ->
       if String.starts_with ~prefix:"activewindow>>" line
       then (
         match
           String.split_on_char ',' (String.sub line 14 (String.length line - 14))
         with
         | name :: _ -> if !active_window <> name then active_window := name
         | _ -> ()))
    lines;
  socketloop_activewindow sock
;;

let cacheDir = Utils.getPath ()

let rec update_data_loop () =
  let now = Unix.gettimeofday () in
  let times = Unix.localtime now in
  let date =
    Printf.sprintf
      "%02d-%02d-%02d"
      (times.tm_year + 1900)
      (times.tm_mon + 1)
      times.tm_mday
  in
  let file = cacheDir ^ date ^ ".csv" in
  Utils.create_file_if_not_exists file;
  let clients : string list = Clients.get_clients () in
  let current_client = !active_window in
  (* Handles the data *)
  Utils.readcsv file
  |> Clients.add_clients clients
  |> List.map (fun (pinfo : Datas.processInfo * bool) ->
    (* usage time / clients *)
    if List.exists (fun client -> (fst pinfo).name = client) clients
    then (
      let one_second : Datas.time = { hour = 0; minutes = 0; seconds = 1 } in
      let new_pinfo : Datas.processInfo =
        { name = (fst pinfo).name
        ; usage_time = Datas.add_time (fst pinfo).usage_time one_second
        ; active_time = (fst pinfo).active_time
        }
      in
      new_pinfo, false)
    else pinfo)
  |> List.map (fun (pinfo : Datas.processInfo * bool) ->
    (* active time / current client *)
    if (fst pinfo).name = current_client
    then (
      let one_second : Datas.time = { hour = 0; minutes = 0; seconds = 1 } in
      let new_pinfo : Datas.processInfo =
        { name = (fst pinfo).name
        ; usage_time = (fst pinfo).usage_time
        ; active_time = Datas.add_time (fst pinfo).active_time one_second
        }
      in
      new_pinfo, false)
    else pinfo)
  |> List.map (fun (pinfopt : Datas.processInfo * bool) ->
    fst pinfopt, (fst pinfopt).name = current_client)
  |> Utils.writecsv file;
  Unix.sleep 1;
  update_data_loop ()
;;


let rec wait_forever () =
  Thread.delay 5.0;
  wait_forever ()
;;

let start_socket_server () =
  (* create a local socket *)
  let sock = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
  (* binds the local socket to the socketPath and connect to it*)
  Unix.connect sock (Unix.ADDR_UNIX (getSocketPath ()));
  (*
     |
     |
     |
     |
  *)
  let _activewindow_thread = Thread.create (fun () -> socketloop_activewindow sock) () in
  let _update_stuff_thread = Thread.create (fun () -> update_data_loop ()) () in
  wait_forever ()
;;
