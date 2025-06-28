type time =
  { hour : int
  ; minutes : int
  ; seconds : int
  }

let compare_time (t1 : time) (t2 : time) : int =
  match compare t1.hour t2.hour with
  | 0 ->
    (match compare t1.minutes t2.minutes with
     | 0 -> compare t1.seconds t2.seconds
     | c -> c)
  | c -> c
;;

let add_time t1 t2 =
  let total_seconds = t1.seconds + t2.seconds in
  let carry_minutes, seconds = total_seconds / 60, total_seconds mod 60 in
  let total_minutes = t1.minutes + t2.minutes + carry_minutes in
  let carry_hours, minutes = total_minutes / 60, total_minutes mod 60 in
  let hour = t1.hour + t2.hour + carry_hours in
  { hour; minutes; seconds }
;;

type processInfo_str =
  { name : string
  ; usage_time : string (* in format : HH:MM:SS *)
  ; active_time : string (* in format : HH:MM:SS *)
  }

type processInfo =
  { name : string
  ; usage_time : time
  ; active_time : time
  }

let new_processInfo title =
  { name = title
  ; usage_time = { hour = 0; minutes = 0; seconds = 0 }
  ; active_time = { hour = 0; minutes = 0; seconds = 0 }
  }
;;

let merge_process_info p1 p2 =
  { name = p1.name
  ; usage_time = add_time p1.usage_time p2.usage_time
  ; active_time = add_time p1.active_time p2.active_time
  }
;;

let list2time xs =
  xs
  |> List.map int_of_string
  |> function
  | [ a; b; c ] -> { hour = a; minutes = b; seconds = c }
  | _ -> failwith "List must have exactly 3 elements"
;;

let time2string t = Printf.sprintf "%02d:%02d:%02d" t.hour t.minutes t.seconds

let processInfo_str_2_processInfo (pis : processInfo_str) =
  let usagetimelist = String.split_on_char ':' pis.usage_time in
  let activetimelist = String.split_on_char ':' pis.active_time in
  { name = pis.name
  ; usage_time = list2time usagetimelist
  ; active_time = list2time activetimelist
  }
;;

let list2processInfo_str xs : processInfo_str =
  match xs with
  | [ a; b; c ] -> { name = a; usage_time = b; active_time = c }
  | _ -> failwith "List must have exactly 3 elements"
;;

let processInfo_2_processInfo_str (pis : processInfo) : processInfo_str =
  { name = pis.name
  ; usage_time = time2string pis.usage_time
  ; active_time = time2string pis.active_time
  }
;;

let processInfo_list_2_string_list (ps : processInfo list) =
  ps
  |> List.map (fun (p : processInfo) ->
    let str_info = processInfo_2_processInfo_str p in
    str_info.name ^ "," ^ str_info.usage_time ^ "," ^ str_info.active_time)
;;

let sum_process (f : processInfo -> time) (pinfos : processInfo list) : time =
  List.fold_left
    (fun acc pinfo -> add_time acc (f pinfo))
    { hour = 0; minutes = 0; seconds = 0 }
    pinfos
;;

let blue = "\027[34m"
let active_color = "\027[0;95m"
let green = "\027[32m"
let red = "\027[31m"
let reset = "\027[0m"
let yellow = "\027[33m"

(* for centering "Cameldream" *)
let width = 82
let text = "Cameldream"
let pad_total = width - String.length text - 2 (* for the pipes *)
let pad_left = pad_total / 2
let pad_right = pad_total - pad_left

let print_processInfo pinfos =
  Printf.printf "\027[H\027[2J";
  let line = red ^ "|" ^ String.make 80 '-' ^ red ^ "|" ^ reset in
  Printf.printf "%s\n" line;
  Printf.printf "%s|%s%*s%s%*s%s|%s\n" red blue pad_left "" text pad_right "" red reset;
  Printf.printf "%s\n" line;
  Printf.printf
    "%s|%s Today's Active Time : %10s %-51s|%s\n"
    red
    reset
    (sum_process (fun p -> p.active_time) pinfos |> time2string)
    red
    reset;
  Printf.printf
    "%s|%s Today's Total Usage : %10s %-51s|%s\n"
    red
    reset
    (sum_process (fun p -> p.usage_time) pinfos |> time2string)
    red
    reset;
  Printf.printf "%s\n" line;
  Printf.printf
    "%s|%s%-30s%20s%30s%s|%s\n"
    red
    yellow
    "Clients"
    "Clients' lifetime"
    "Clients' Active Time"
    red
    reset;
  Printf.printf "%s\n" line;
  pinfos
  |> List.sort (fun (x : processInfo) (y : processInfo) ->
    compare_time y.active_time x.active_time)
  |> List.iter (fun pinfo ->
    let str_info = processInfo_2_processInfo_str pinfo in
    Printf.printf
      "%s|%s%-30s%s%s%20s%s%s%30s%s|%s\n"
      red
      (if pinfo.name = "kitty" then active_color else blue)
      str_info.name
      reset
      green
      str_info.usage_time
      reset
      green
      str_info.active_time
      red
      reset);
  Printf.printf "%s\n" line;
  flush stdout
;;
