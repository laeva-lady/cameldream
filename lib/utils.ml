let readcsv path_to_csv : Datas.processInfo list =
  let input = Csv.load path_to_csv in
  input
  |> List.map (fun row ->
    row |> Datas.list2processInfo_str |> Datas.processInfo_str_2_processInfo)
;;

let getPath () =
  let homeDir = Sys.getenv "HOME" in
  let cacheDir = ".cache/wellness/daily/" in
  homeDir ^ "/" ^ cacheDir
;;

let create_file_if_not_exists filename =
  let flags = [ Open_creat; Open_excl; Open_wronly ] in
  let perm = 0o644 in
  try
    let oc = open_out_gen flags perm filename in
    close_out oc;
    ()
  with
  | Sys_error _ -> ()
;;

(* to do *)
let writecsv path_to_csv (pinfos : Datas.processInfo list) =
  let oc = open_out path_to_csv in
  Datas.processInfo_list_2_string_list pinfos
  |> List.iter (fun s ->
    Printf.fprintf oc "%s\n" s
  );
  close_out oc;
  ()
;;
