program shitcode;

{$mode objfpc}
Uses 
    sysutils;
    
const INF = maxint - 1;

type
    STATES = (ST_EXP, CL_QUOTES_EXP, NUM_EXP);

type arr = array of array of char;

type vertex = record 
    edges: array of array[1..4] of integer;
end;
//to, trans, tc, mc

type burn_in_hell = array of integer;

type shit = array of array[1..2] of integer;

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
        error_ := '(read)UNEXPECTED LINE BREAK IN ' + IntToStr(num_str);
        flag := false;
    end;
end;

function read_graph(): boolean;//////////////////
var 
    routes: text; num_str, i, j, stage, name_len, n_cities, n_tr, n_str, pos: integer; 
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
                                error_ := '(st_exp)UNEXPECTED LINE BREAK ' + IntToStr(num_str);
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
                            end;

                            if pos_d_arr(transport, types_transport) = -1 then begin
                                types_transport[n_tr] := transport; n_tr := n_tr + 1; 
                                setLength(types_transport[n_tr], length(transport));
                            end;

                            if pos_d_arr(city_to, cities) = -1 then begin
                                cities[n_cities] := city_to; n_cities := n_cities + 1;
                                setLength(cities[n_cities], length(city_to));
                            end;

                            if pos_d_arr(city_from, cities) = -1 then begin
                                cities[n_cities] := city_from; n_cities := n_cities + 1; 
                                setLength(cities[n_cities], length(city_from));
                            end;
                            pos := pos_d_arr(city_from, cities);

                            graph[pos].edges[n_links[pos], 1] := pos_d_arr(city_to, cities);
                            graph[pos].edges[n_links[pos], 2] := pos_d_arr(transport, types_transport);
                            graph[pos].edges[n_links[pos], 3] := nums[1];
                            graph[pos].edges[n_links[pos], 4] := nums[2];
                            n_links[pos] := n_links[pos] + 1;

                            readln(routes); city_from := ''; city_to := ''; name_len := 0; 
                            transport := ''; p_been := false; nums[1] := 0; nums[2] := 0;
                            num_str := num_str + 1; state := ST_EXP; st_mark := '"'; stage := 1;
                            setLength(city_from, 512); setLength(city_to, 512); setLength(transport, 512);
                        end
                        else if eoln(routes) or (c = '#') then begin
                            error_ := '(num_exp)UNEXPECTED LINE BREAK ' + IntToStr(num_str);
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
            setLength(cities, n_cities ); setLength(types_transport, n_tr); setLength(graph, n_cities);
            //write(n_cities);
            for i := 0 to n_cities do 
                setLength(graph[i].edges, n_links[i]);
            setLength(n_links, n_cities);
        end
        else writeln('file not found');
    end
    else writeln('submit a file with routes');
    read_graph := flag;
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

function get_chr_in_ab(a, b: char): char;
var c: char;
begin
    write('>'); read(c); readln();
    while (a > c) or (b < c) do begin
        writeln('wrong input: ', c, '!');
        write('>'); read(c); readln();
    end;
    {writeln('finnaly!!! you entered correctly ', c);}
    get_chr_in_ab := c;
end;

function get_num_in_ab(a, b: integer): integer;
var i, res: integer;
begin
    i := 1;
    while i = 1 do begin
        try
            write('>'); read(res); readln();
            if (res > b) or (res < a) then  
                writeln('there is no such city')
            else i := 0;                                    
        except
            on EInOutError do 
                writeln('wrong input');   
        end;
    end;
    get_num_in_ab := res;
end;

procedure del_el_val(enemy: integer; var arr: burn_in_hell);
var 
    i, j: integer;
begin
    while in_darr(-2, arr) <> -1 do begin
        if arr[length(arr) - 1] = enemy then setLength(arr, length(arr) - 1);
        for i := 0 to length(arr) - 2 do begin
            if arr[i] = enemy then begin
                for j := i to length(arr) - 2 do
                    arr[j] := arr[j + 1];
                setLength(arr, length(arr) - 1);
                break;
            end;
        end;
    end;
end;

procedure print_arr(ar: array of char);
var i: integer;
begin
    for i := 0 to length(ar) - 1 do write(ar[i]);
end;

 
procedure dijkstra(GM: array of vertex; st: integer; dt: burn_in_hell; mode, end_lim, is_mode_4: integer);
var
    count, index, i, u, min, n: integer;
    flag: boolean;
    distance: array of integer; from: array of array[1..2] of integer; costs: array of integer;
    visited: array of boolean; 

    procedure print_way(k: integer);
    begin
        if (from[k, 1] <> st) and (k <> st) then 
        begin  
            print_way(from[k, 1]);
            write(' > ');
        end;
        print_arr(cities[k]);
        write(' ('); print_arr(types_transport[from[k, 2]]); 
        write(') ');
    end;

begin
    n := length(graph);
    setLength(distance, N);
    setLength(from, N);
    setLength(visited, N);
    setLength(costs, N);

    for i := 0 to n - 1 do
    begin
        distance[i] := INF; 
        costs[i] := 0;
        visited[i] := false;
    end;
    distance[st] := 0;
    for count := 0 to n - 1 do
    begin
        min := INF;
        for i := 0 to n - 1  do
        if (not visited[i]) and (distance[i] <= min) then
        begin
            min := distance[i]; 
            index := i;
        end;
        u := index;
        visited[u] := true;
        for i := 0 to n - 1 do
        begin
            //writeln(i,(not visited[i]), (GM[u].edges[i, 3 + is_mode_4] <> 0) ,(distance[u] <> INF),  (in_darr(graph[u].edges[i, 2], dt) <> -1));
            if (not visited[i]) and (GM[u].edges[i, 3 + is_mode_4] <> 0) and (distance[u] <> INF)
            and (in_darr(graph[u].edges[i, 2], dt) <> -1) then
            begin
                //write('1111');
                if (distance[u] + GM[u].edges[i, 3 + is_mode_4] < distance[i]) then
                begin
                    //write('!');
                    distance[i] := distance[u] + GM[u].edges[i, 3 + is_mode_4];
                    //write('!');
                    from[i, 1] := u;
                    //write('!');
                    from[i, 2] := GM[u].edges[i, 2]; 
                    //write('!');
                    costs[i] := costs[i] + GM[u].edges[i, 4 - is_mode_4];
                    //write('!');
                end
                else if (distance[u] + GM[u].edges[i, 3 + is_mode_4] = distance[i]) and 
                (GM[u].edges[i, 4 - is_mode_4] > GM[from[i, 1]].edges[i, 4 - is_mode_4]) then
                begin
                    from[i, 1] := u;
                    from[i, 2] := GM[u].edges[i, 2]; 
                    costs[i] := costs[i] + GM[u].edges[i, 4 - is_mode_4];
                end;
            end;
        end;
    end;
    flag := false;
    //write('22222');
    case mode of
        1, 2:
            begin
                if end_lim <> st then begin
                    print_arr(cities[st]);
                    write(' to ');
                    print_arr(cities[end_lim]);
                    if distance[end_lim] = inf then writeln(' - No way')
                    else
                    begin
                        write(' Way: ');
                        print_arr(cities[st]); 
                        write(' > ');
                        print_way(end_lim); 
                        if is_mode_4 = 1 then 
                        begin
                            write(' Time cost: ', distance[end_lim]);
                            write(' Money cost: ', costs[end_lim]); 
                        end
                        else if is_mode_4 = 0 then
                        begin
                            write(' Money cost: ', distance[end_lim]);
                            write(' Time cost: ', costs[end_lim]); 
                        end;
                        writeln();
                    end;
                end
                else 
                    writeln('you already here');
            end;
        4, 5: 
            begin
                for i := 0 to n - 1 do
                begin
                    if (i <> st) and (distance[i] <> inf) and (costs[i] <= end_lim) then begin
                        flag := true;
                        write('Way: ');
                        print_arr(cities[st]); 
                        write(' > ');
                        print_way(i); 
                        if is_mode_4 = 1 then 
                        begin
                            write(' Time cost: ', distance[i]);
                            write(' Money cost: ', costs[i]); 
                        end
                        else if is_mode_4 = 0 then
                        begin
                            write(' Money cost: ', distance[i]);
                            write(' Time cost: ', costs[i]); 
                        end;
                        writeln();
                    end;
                end;
                if not flag then writeln('there is no such cities')
            end;
    end;
end;


procedure bfs(graph: array of vertex; start, finish: integer);
var
    queue, dist: array of integer; 
    i, j, n, q_st, q_end, u, v, tmp1, tmp2: integer;
    is_path_exist: boolean;
    prev, ans: array of array[1..2] of integer;
 begin
    n := length(graph);
    setLength(dist, n);
    setLength(prev, n);
    setLength(queue, n);
    setLength(ans, n);
    for j := 0 to n - 1 do begin
        dist[j] := -1;
        prev[j, 1] := -1;
    end;

    dist[start] := 0;
    queue[0] := start;
    q_st := 1;
    q_end := 2;

    while q_st < q_end do 
    begin
        u := queue[q_st];
        q_st := q_st + 1; 
        for v := 0 to length(graph[u].edges) - 1 do begin
            is_path_exist := false;
            //graph[u].edges[v, 1] среди эджес граф ю найдется в в
            for j := 0 to length(graph[u].edges) - 1 do begin
                if graph[u].edges[j, 1] = v then is_path_exist := true;
            end;
            if (is_path_exist) and (dist[v] = -1) then begin
                dist[v] := dist[u] + 1;
                queue[q_end] := v;
                prev[v, 1] := u;
                prev[v, 2] := graph[u].edges[v, 2]; 
                q_end := q_end + 1;
            end;
        end;
    end;
    tmp1 := finish;
    i := 1;
    while tmp1 <> -1 do 
    begin
        ans[i, 1] := tmp1;
        ans[i, 2] := tmp2;
        i := i + 1;
        tmp1 := prev[tmp1, 1];
        tmp2 := prev[tmp2, 2];
    end;
    for j := i - 1 downto 0 do begin
        if j <> i - 1 then write(' > ');
        print_arr(cities[ans[j, 1]]); 
        write(' (');
        print_arr(types_transport[ans[j, 2]]); 
        write(') ');
    end;
    writeln();
end;


var 
    used: array of boolean; desired_transport, dist: array of integer;
    state, oper_mode, f: char; i, j, numt, cf, ct, lt, lc, min_dist, min_vertex: integer; 
begin
    state := '0';

    if read_graph() then begin
        while (state = '0') do 
        begin
            writeln('what do you want to do?(enter a number)', #10#13, '0. start', #10#13, '1. close');
            state := get_chr_in_ab('0', '1');
            if (state = '0') then begin
                for i := 0 to length(types_transport) - 1 do begin
                    write(i + 1, '. ');
                    for j := 0 to length(types_transport[i]) - 1 do
                        write(types_transport[i, j]);
                    writeln();
                end;
                setLength(desired_transport, length(types_transport));
                writeln('do you want to exclude any specific modes of transport(0) or exclude all except those indicated(1)?');
                f :=  get_chr_in_ab('0', '1');
                if f = '0' then begin
                    writeln('enter the type of transport you want to exclude(-1 to end)');
                    for i := 0 to length(desired_transport) - 1  do
                        desired_transport[i] := i;
                    i := 0;
                    while (i < length(desired_transport) - 1) and (numt <> -2) do begin
                        try
                            write('>');
                            read(numt); 
                            numt := numt - 1;
                            readln();
                            if (numt < length(types_transport)) and (numt >= 0) and (desired_transport[numt] <> -2) then begin
                                desired_transport[numt ] := -2;
                                i := i + 1;
                            end
                            else if (numt <> -2) and (in_darr(numt, desired_transport) = -1) then
                                writeln('there is no such city');
                        except
                            on EInOutError do
                                writeln('wrong input');
                        end;
                    end;

                    del_el_val(-2, desired_transport);
                    //writeln();//ошибки при повторной работе, ошибки при 
                end
                else begin
                    writeln('enter the types of transport that you want to use(-1 to end)');
                    for i := 0 to length(desired_transport) - 1  do
                        desired_transport[i] := -1;
                    i := 0;
                    while (i < length(desired_transport)) and (numt <> -2) do begin
                        try
                            write('>'); 
                            read(numt); 
                            numt := numt - 1;
                            readln();
                            if (numt < length(types_transport)) and (numt >= 0) and (in_darr(numt, desired_transport) = -1) then begin
                                desired_transport[i] := numt;
                                i := i + 1;
                            end
                            else if (numt <> -2) and (in_darr(numt, desired_transport) = -1) then
                                writeln('there is no such city');                      
                        except
                            on EInOutError do 
                                writeln('wrong input');   
                        end;
                    end;
                    setLength(desired_transport, i);
                end;
                
                writeln('enter the operating mode(enter a number)');
                writeln('1. Among the shortest paths in time between two cities, find the path of the minimum cost.');
                writeln('2. Among the paths between two cities, find the path of minimum cost.');
                writeln('3. Find the path between 2 cities minimum by the number of cities visited.');
                writeln('4. Find a set of cities reachable from the city of departure for no more than limit_cost money.');
                writeln('5. Find a set of cities reachable from the senders city in no more than limit_time of time.');
                oper_mode := get_chr_in_ab('1', '5');
                
                for i := 0 to length(cities) - 1  do begin
                    write(i + 1, '. ');
                    print_arr(cities[i]);
                    writeln();
                end;
                case oper_mode of
                    '1', '2', '3':
                        begin
                            writeln('enter city of departure');
                            cf := get_num_in_ab(0, length(cities)) - 1;
                            writeln('enter destination city');
                            ct := get_num_in_ab(0, length(cities)) - 1;
                        end;
                    '4', '5':
                        begin
                            writeln('enter city of departure');
                            cf := get_num_in_ab(0, length(cities)) - 1;
                            if oper_mode = '4' then begin 
                                writeln('enter limit cost');
                                lc := get_num_in_ab(-maxint, maxint);
                            end
                            else begin 
                                writeln('enter limit time');
                                lt := get_num_in_ab(-maxint, maxint);
                            end;
                        end;
                end;
                //dijkstra(GM: array of vertex; st: integer; dt: burn_in_hell; mode, end_lim, is_mode_4: integer);
                case oper_mode of
                    '1':
                        dijkstra(graph, cf, desired_transport, 1, ct, 1);
                    '2':
                        dijkstra(graph, cf, desired_transport, 2, ct, 0);
                    '3':
                        bfs(graph, cf, ct);
                    '4':
                        dijkstra(graph, cf, desired_transport, 4, lc, 1);
                    '5':
                        dijkstra(graph, cf, desired_transport, 5, lt, 0);
                end;
            end;
        end;
    end;
end.          //выход за пределы, не число, пустые строки, 23
                //BREAKLINE