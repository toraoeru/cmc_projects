program shitcode;

{$mode objfpc}
Uses 
    sysutils;

type
    STATES = (ST_EXP, CL_QUOTES_EXP, NUM_EXP);

type arr = array of array of char;

type vertex = record 
    namec: integer;
    edges: array of array[1..4] of integer;
end;
//to, trans, tc, mc

type burn_in_hell = array of integer;

var 
    graph: array of vertex; cities, types_transport: array of array of char; n_links: array of integer;

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
    flag, p_been: boolean; nums: array[1..2] of integer; c: char; state: STATES;
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
            setLength(n_links, n_str); setLength(graph, n_str);
            for i := 0 to n_str - 1  do begin
                setLength(cities[i], 0);
                setLength(graph[i].edges, n_str);
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
                                graph[n_cities].namec := pos_d_arr(city_from, cities);
                            end;

                            if pos_d_arr(city_from, cities) = -1 then begin
                                n_cities := n_cities + 1; cities[n_cities] := city_from;
                                setLength(cities[n_cities], length(city_from));
                                graph[n_cities].namec := pos_d_arr(city_from, cities);
                            end;
                            
                            graph[n_cities].edges[n_links[pos_d_arr(city_from, cities)], 1] := pos_d_arr(city_to, cities);
                            graph[n_cities].edges[n_links[pos_d_arr(city_from, cities)], 2] := pos_d_arr(transport, types_transport);
                            graph[n_cities].edges[n_links[pos_d_arr(city_from, cities)], 3] := nums[1];
                            graph[n_cities].edges[n_links[pos_d_arr(city_from, cities)], 4] := nums[2];
                            
                            n_links[pos_d_arr(city_from, cities)] := n_links[pos_d_arr(city_from, cities)] + 1;
{
                            write('->');
                            for i := 0 to n_str do
                                write(graph[i].namec:1, '  ');
                            writeln();
                            for i := 0 to length(n_links) - 1 do 
                                write(n_links[i], '  ');
                            writeln();

}
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
                                    {else begin 
                                        i := i + 1;
                                        nums[stage - 3] := nums[stage - 3] + StrToInt(c) / exp(ln(10) * i);
                                    end;}
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
            setLength(cities, n_cities + 1); setLength(types_transport, n_tr + 1); setLength(graph, n_cities + 1);
            //write(n_cities);
            for i := 0 to n_cities do 
                setLength(graph[i].edges, n_links[graph[i].namec]);
        end
        else writeln('file not found');
    end
    else writeln('submit a file with routes');
end;

function in_darr(el: integer; ar: array of integer): integer;
var i: integer;
begin
    in_darr := -1;
    for i := 0 to length(ar) - 1 do 
    begin
        if el = ar[i] then in_darr := i;
    end;
end;

function get_num_in_ab(a, b: char): char;
var c: char;
begin
    write('>'); read(c); readln();
    while (a > c) or (b < c) do begin
        writeln('wrong input: ', c, '!');
        write('>'); read(c); readln();
    end;
    {writeln('finnaly!!! you entered correctly ', c);}
    get_num_in_ab := c;
end;

procedure del_el_val(enemy: integer; var arr: burn_in_hell);
var i, j, num_enemy: integer;
begin
    num_enemy := 0;
    for i := 0 to length(arr) - 1 do begin
        if arr[i] = enemy then begin
            for j := i to length(arr) - 1 do
                arr[j] := arr[j + 1];
            num_enemy := num_enemy + 1;    
        end;
    end;
    setLength(arr, length(arr) - num_enemy);
end;

var 
    state, oper_mode, f: char; i, j, numt: integer; desired_trancport: array of integer;
begin
    state := '0';
    
    while (state = '0') do 
    begin
        writeln('what do you want to do?(enter a number)', #10#13, '0. start', #10#13, '1. close');
        state := get_num_in_ab('0', '1');
        if (state = '0') then begin
            writeln('enter the operating mode(enter a number)');
            writeln('1. Among the shortest paths in time between two cities, find the path of the minimum cost.');
            writeln('2. Among the paths between two cities, find the path of minimum cost.');
            writeln('3. Find the path between 2 cities minimum by the number of cities visited.');
            writeln('4. Find a set of cities reachable from the city of departure for no more than limit_cost money.');
            writeln('5. Find a set of cities reachable from the senders city in no more than limit_time of time.');
            oper_mode := get_num_in_ab('1', '5');
            read_graph();
            for i := 1 to length(types_transport) - 1 do begin
                write(i, '. ');
                for j := 0 to length(types_transport[i]) - 1 do
                    write(types_transport[i, j]);
                writeln();
            end;
            setLength(desired_trancport, length(types_transport));
            writeln('do you want to exclude any specific modes of transport(0) or exclude all except those indicated(1)?');
            f :=  get_num_in_ab('0', '1');
            if f = '0' then begin
                writeln('enter the type of transport you want to exclude(-1 to end)');
                for i := 0 to length(desired_trancport) - 1  do
                    desired_trancport[i] := i + 1;
                i := 0;
                while (i < length(desired_trancport) - 2) and (numt <> -1) do begin
                    try
                        write('>'); read(numt); readln();
                        if (numt <= length(types_transport)) and (numt > 0) and (desired_trancport[numt] <> -2) then begin
                            desired_trancport[numt - 1] := -2;//повторяющ симв
                            i := i + 1;
                        end
                        else if (numt <> -1) and (in_darr(numt, desired_trancport) = -1) then
                            writeln('there is no such city');
                    except
                        on EInOutError do
                            writeln('wrong input');
                    end;
                end;
                del_el_val(-2, desired_trancport);
            end
            else begin
                writeln('enter the types of transport that you want to use(-1 to end)');
                i := 0;
                while (i < length(desired_trancport) - 2) and (numt <> -1) do begin
                    try
                        write('>'); read(numt); readln();
                        if (numt <= length(types_transport)) and (numt > 0) and (in_darr(numt, desired_trancport) = -1) then begin
                            desired_trancport[i] := numt;//повторяющ симв
                            i := i + 1;
                        end
                        else if (numt <> -1) and (in_darr(numt, desired_trancport) = -1) then
                            writeln('there is no such city');                      
                    except
                        on EInOutError do 
                            writeln('wrong input');   
                    end;
                end;
                setLength(desired_trancport, i);
            end;

            for i := 0 to length(desired_trancport) - 1 do 
                write(desired_trancport[i], ' ');
            //принтуем доступные виды транспорта , просим ввести , обрабатываем 
            { case oper_mode of
                '1':
                    //таблица смежности по времени + счет стоимости
                '2':
                    //таблица смежности по стоимости
                '3':
                    //присвоить каждой веришине стоимость 1 + классический алгоритм
                '4':
                    //какой-нибудь поиск в ширину?? idk
                '5':
                    //анлалогично 4
            end;dfdhasdjf}
            
        end;
    end;
end.          //выход за пределы, не число, пустые строки, 23
                