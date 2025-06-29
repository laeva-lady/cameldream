let get_path name =
  let homeDir = Sys.getenv "HOME" in
  let cacheDir = ".cache/wellness/" ^ name ^ "/" in
  homeDir ^ "/" ^ cacheDir
;;

let get_files_prefix dir prefix =
  Sys.readdir dir
  |> Array.to_list
  |> List.filter (fun name -> String.starts_with ~prefix name)
;;

let get_month () =
  let date = Dates.get_date () in
  String.sub date 0 7
;;

module StringMap = Map.Make (String)

let add_dailys () =
  let pinfos =
    get_files_prefix (get_path "daily") (get_month ())
    (* get the data of daily's files*)
    |> List.map (fun x -> get_path "daily" ^ x)
    |> List.map Utils.readcsv (* (pinfo * bool) list list *)
    |> List.flatten
    |> List.fold_left
         (fun (acc : (Datas.processInfo * bool) StringMap.t)
           (pinfo : Datas.processInfo * bool) ->
            let name = (fst pinfo).name in
            let combined =
              match StringMap.find_opt name acc with
              | Some existing ->
                Datas.merge_process_info (fst existing) (fst pinfo),
                snd existing || snd pinfo
              | None -> (fst pinfo, snd pinfo)
            in
            StringMap.add name combined acc)
         StringMap.empty
    |> StringMap.bindings
    |> List.map snd
  in
  pinfos |> Utils.writecsv (get_path "month" ^ get_month () ^ ".csv");
  pinfos
;;

let monthly () = add_dailys () |> Datas.print_processInfo

let rec watch () =
  monthly ();
  Thread.delay 1.;
  watch ()
;;
