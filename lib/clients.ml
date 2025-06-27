let get_output_single_line cmd =
  let ic = Unix.open_process_in cmd in
  let result = input_line ic in
  let _ = Unix.close_process_in ic in
  result
;;

let get_output cmd =
  let ic = Unix.open_process_in cmd in
  let buf = Buffer.create 1024 in
  (try
     while true do
       Buffer.add_string buf (input_line ic);
       Buffer.add_char buf '\n'
     done
   with
   | End_of_file -> ());
  let _ = Unix.close_process_in ic in
  let result = Buffer.contents buf in
  let len = String.length result in
  if len > 0 && result.[len - 1] = '\n' then String.sub result 0 (len - 1) else result
;;

let get_active_client () =
  let desk_env = Sys.getenv "XDG_CURRENT_DESKTOP" in
  match desk_env with
  | "Hyprland" ->
    get_output_single_line "hyprctl activewindow | grep \"class:\\s\" | awk '{print $2}'"
  | _ -> failwith "Only Hyprland is supported"
;;

let get_clients () =
  let desk_env = Sys.getenv "XDG_CURRENT_DESKTOP" in
  match desk_env with
  | "Hyprland" ->
    let results = get_output "hyprctl clients | grep \"class:\\s\" | awk '{print $2}'" in
    String.split_on_char '\n' results |> List.sort_uniq compare
  | _ -> failwith "Only Hyprland is supported"
;;

let contains_client (title : string) (pinfos : Datas.processInfo list) =
  pinfos |> List.exists (fun (pinfo : Datas.processInfo) -> pinfo.name = title)
;;
