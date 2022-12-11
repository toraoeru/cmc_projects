program shit_code;

Uses 
    sysutils;

type
    STATES = (ST_EXP, CL_QUOTES_EXP, NUM_EXP);

type arr = array of array of char;

type link = ^edge;

edge = record 
    _to: link;
    tr_name: integer;
    tc: real; mc: real; 
end;

type vertex = record 
    namec: integer;
    edges: array of edge;
end;

var 
    graph: array of vertex;  cities, types_transport: array of array of char; n_links: array of integer;

function min_of_int(n1, n2: integer): integer;
begin
    if n1 > n2 then min_of_int := n2
    else min_of_int := n1;
end;

function in_str(ch: char; str: string): boolean;
var i: integer;
begin
    in_str := false;
    for i := 1 to length(str) do 
    begin
        if ch = str[i] then in_str := true;
    end;
end;

function pos_d_arr(el: array of char; ar: arr): integer;
var i, j, res: integer;
begin
    pos_d_arr := -1;
    for i := 0 to length(ar) - 1 do 
    begin
        res := -1;
        if min_of_int(length(el), length(ar[i])) <> 0 then 
            res := i;
            for j := 0 to min_of_int(length(el), length(ar[i])) - 1 do begin
                if el[j] <> ar[i, j] then res := -1
            end;
        if res <> -1 then pos_d_arr := res;
    end;
end;

procedure read_lbr(var file_: text; var c: char; var num_str: integer; var flag: boolean; var error_: string);
begin
    read(file_, c);
    if eoln(file_) or (c = '#') then 
    begin
        error_ := 'UNEXPECTED LINE BREAK IN ' + IntToStr(num_str);
        flag := false;
    end;
end;

procedure read_graph();
var 
    routes: text; num_str, i, stage, name_len, n_cities, n_tr, n_str: integer; 
    flag, p_been: boolean; nums: array[1..2] of real; c: char; state: STATES;
    city_from, city_to, transport: array of char; st_mark, error_: string; city: vertex;
begin
    stage := 1; st_mark := '"'; num_str := 1; name_len := 0; p_been := false; 
    state := ST_EXP; city_from := ''; city_to := ''; flag := true; n_str := 0;
    transport := ''; i := 1; setLength(city_from, 512); n_cities := 0; n_tr := 0;
    setLength(city_to, 512); setLength(transport, 512); error_ := '';

    if (paramCount() <> 0) then 
    begin
        assign(routes, paramStr(1));
        {$I-} reset(routes); {$I+}
        if (IOresult = 0) then begin
            while not eof(routes) do begin
                if eoln(routes) then begin
                    readln(routes);
                    n_str := n_str + 1;
                end;
                read(routes, c);
            end;

            setLength(cities, n_str); setLength(types_transport, n_str);
            setLength(n_links, n_str);
            for i := 0 to n_str - 1  do begin
                setLength(cities[i], 0);
                n_links[i] := 0;
            end;
            reset(routes); c := ' ';

            while flag and not eof(routes) do 
            begin          
                case state of
                    ST_EXP:
                    begin
                        read(routes, c);
                        if (not eoln(routes)) and (c <> '#') then 
                        begin
                            if (c <> ' ') and (not in_str(c, st_mark)) then begin
                                error_ := 'INVALID OFF-RECORD CHARACTER IN ' + IntToStr(num_str);
                                flag := false;
                            end
                            else if in_str(c, st_mark) and (st_mark = '"') then
                                state := CL_QUOTES_EXP
                            else if in_str(c, st_mark) and (st_mark <> '"') then begin
                                state := NUM_EXP;
                                nums[stage - 3] := StrToInt(c);
                            end;
                        end
                        else begin
                            if stage = 1 then begin
                                readln(routes); 
                                num_str := num_str + 1;
                            end
                            else begin
                                error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                                flag := false; city_from := ''; city_to := ''; 
                                transport := ''; p_been := false; stage := 1; 
                            end;
                        end;
                    end;
                    CL_QUOTES_EXP:
                    begin
                        read_lbr(routes, c, num_str, flag, error_);
                        if c <> '"' then 
                        begin
                            if stage = 1 then city_from[name_len] := c
                            else if stage = 2 then city_to[name_len] := c
                            else if stage = 3 then transport[name_len] := c;
                            name_len := name_len + 1;
                        end
                        else begin
                            if name_len = 0 then begin
                                if stage < 3 then error_ := 'NAME OF CITY NOT FOUND IN ' + IntToStr(num_str)
                                else error_ := 'NAME OF TRANSPORT NOT FOUND IN ' + IntToStr(num_str);
                                flag := false;
                            end
                            else begin
                                if stage = 1 then setLength(city_from, name_len)
                                else if stage = 2 then setLength(city_to, name_len)
                                else if stage = 3 then setLength(transport, name_len);
                                {заполняем структуру}
                                state := ST_EXP; stage := stage + 1; name_len := 0;
                            end;
                        end;
                    end;
                    NUM_EXP:
                    begin
                        read(routes, c);
                        if (stage = 5) and (nums[2] <> 0) and (eoln(routes) or (c = '#') or (c = ' ')) then begin
                            if pos_d_arr(transport, types_transport) = -1 then begin
                                n_tr := n_tr + 1;  types_transport[n_tr] := transport;
                                setLength(types_transport[n_tr], length(transport));
                            end;

                            if pos_d_arr(city_to, cities) = -1 then begin
                                n_cities := n_cities + 1; cities[n_cities] := city_to;
                                setLength(cities[n_cities], length(city_to));
                                city.namec := pos_d_arr(city_from, cities);
                                {new(graph[n_cities]); graph[n_cities]^.namec := pos_d_arr(city_to, cities);}
                            end;

                            if pos_d_arr(city_from, cities) = -1 then begin
                                n_cities := n_cities + 1; cities[n_cities] := city_from;
                                setLength(cities[n_cities], length(city_from));
                                {new(graph[n_cities]); graph[n_cities].namec := pos_d_arr(city_from, cities);}
                                city.namec := pos_d_arr(city_from, cities);
                            end;
                            
                            city.edges[n_links[n_links[pos_d_arr(city_from, cities)]]]._to := @graph[pos_d_arr(city_to, cities)];
                            city.edges[n_links[n_links[pos_d_arr(city_from, cities)]]].tr_name := pos_d_arr(transport, types_transport);
                            city.edges[n_links[n_links[pos_d_arr(city_from, cities)]]].tc := nums[1];
                            city.edges[n_links[n_links[pos_d_arr(city_from, cities)]]].mc := nums[2];
                            graph[n_cities] := city;
                            {(graph[pos_d_arr(city_from, cities)]).edges[n_links[pos_d_arr(city_from, cities)]]._to := graph[pos_d_arr(city_to, cities)];
                            graph[pos_d_arr(city_from, cities)].edges[n_links[pos_d_arr(city_from, cities)]].tr_name := transport;
                            graph[pos_d_arr(city_from, cities)].edges[n_links[pos_d_arr(city_from, cities)]].tc := num[1];
                            graph[pos_d_arr(city_from, cities)].edges[n_links[pos_d_arr(city_from, cities)]].mc := num[2];}


                            n_links[pos_d_arr(city_from, cities)] := n_links[pos_d_arr(city_from, cities)] + 1;

                            readln(routes); city_from := ''; city_to := ''; name_len := 0; 
                            transport := ''; p_been := false; nums[1] := 0; nums[2] := 0;
                            num_str := num_str + 1; state := ST_EXP; st_mark := '"'; stage := 1;
                            setLength(city_from, 512); setLength(city_to, 512); setLength(transport, 512);
                        end
                        else if eoln(routes) or (c = '#') then begin
                            error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                            flag := false;
                        end
                        else begin
                            if (c >= '0') and (c <= '9') then 
                            begin
                                if nums[stage - 3] * 10 + StrToInt(c) < maxInt then begin
                                    if not p_been then nums[stage - 3] := nums[stage - 3] * 10 + StrToInt(c)
                                    else begin 
                                        i := i + 1;
                                        nums[stage - 3] := nums[stage - 3] + StrToInt(c) / exp(ln(10) * i);
                                    end;
                                end
                                else begin 
                                    error_ := 'COST IS TOO LARGE IN ' + IntToStr(num_str);
                                    flag := false;
                                end;
                            end
                            else if (c = ' ') and (stage = 4) then
                            begin 
                                state := ST_EXP; stage := stage + 1; p_been := false; i := 1;
                            end
                            else if (c = '.') and (not p_been) then p_been := true
                            else begin 
                                error_ := 'INVALID CHAR IN COST IN ' + IntToStr(num_str);
                                flag := false;
                            end;
                        end;
                    end;
                end;    
                write(error_);
                if stage > 3 then st_mark := '0123456789';
            end;
            setLength(cities, n_cities); setLength(types_transport, n_tr);
        end
        else writeln('file not found');
    end
    else writeln('submit a file with routes');
end;

begin 
    read_graph();
end.