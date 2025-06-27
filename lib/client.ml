let oneTime () =
  let date = Dates.get_date in
  Utils.getPath () ^ date ^ ".csv"
  |> Utils.readcsv
  |> Datas.print_processInfo
;;

let rec watch () =
  print_endline "\027[H\027[2J";
  let date = Dates.get_date in
  Utils.getPath () ^ date ^ ".csv"
  |> Utils.readcsv
  |> Datas.print_processInfo;
  print_endline "";
  Unix.sleep 1;
  watch ()
