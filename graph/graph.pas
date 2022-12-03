program map;

Uses 
    Crt;

type city = record
    namec: integer; 
    type edge = record city_to: ^city; tr_name: integer; tc:real; mc: real; end;
    edges: array of edge;
end;

var cities: array of city;

function in_str(ch: char; str: string): boolean;
var i: integer; res: boolean;
begin
    res := false;
    for i := 1 to length(str) do 
    begin
        if ch = str[i] then 
            res := true;
    end;
    in_str := res;
end;

procedure read_graph();
var 
    routes: text; str: string; num_str, i: integer;
    st_mark: string; city_from: array of char; flag: boolean;
    city_to: array of char; transport: array of char;
    name_len: integer; time_cost: real; money_cost: real;
    names: array[1..3] of array of char; nums: array[1..2] of integer;
begin
    stage := 1; st_mark := '"'; city_to := '';
    num_str := 1; city_from := ''; name_len := 0; 
    transport := '';

    if (paramCount() <> 0) then 
    begin
        assign(routes, paramStr(1));
        {$I-} reset(routes); {$I+}
        if (IOresult = 0) then begin
            while flag and not eof() do 
            begin
                case state of
                    ST_EXP:
                    begin
                        if not eoln() then 
                        begin
                            read(c);
                            if (c <> ' ') and (c <> st_mark) then begin
                                error_ := 'INVALID OFF-RECORD CHARACTER IN ' + IntToStr(num_str);
                                flag := false;
                            end
                            else if in_str(c, st_mark) and (st_mark = '"') then
                                state := CL_QUOTES_EXP;
                            else if in_str(c, st_mark) and (st_mark <> '"') then begin
                                state := NUM_EXP;
                                nums[stage - 3] := ord(c) - 48;
                            end;
                        end
                        else begin
                            if stage = 1 then begin
                                readln(); num_str := num_str + 1;
                            end
                            else 
                                error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                                flag := false;
                            end;
                        end;
                        CL_QUOTES_EXP:
                        begin
                            if not eoln() then 
                            begin
                                read(c);
                                if c <> '"' then 
                                begin
                                    name_len := name_len + 1;
                                    names[stage, name_len] := c; {
                                    if stage = 1 then city_from[name_len] := c
                                    else if stage = 2 then city_to[name_len] := c
                                    else if stage = 3 then transport[name_len] := c;}
                                else begin
                                    if name_len = 0 then begin
                                        if stage < 3 then error_ := 'NAME OF CITY NOT FOUND IN ' + IntToStr(num_str)
                                        else error_ := 'NAME OF TRANSPORT NOT FOUND IN ' + IntToStr(num_str);
                                        flag := false;
                                    end
                                    else begin
                                        setLength(names[stage], name_len);
                                        {if stage = 1 then setLength(city_from, name_len)
                                        else if stage = 2 then setLength(city_to, name_len)
                                        else if stage = 3 then setLength(transport, name_len);}
                                        {заполняем структуру}
                                        state := ST_EXP; stage := stage + 1; name_len := 0;
                                    end;
                                end;
                            end;
                        end;
                        NUM_EXP:
                        begin
                            if 
                        end;
                    
                
                write(error_);
                end;


                readln(routes, str);
            end;
            reset(routes);
            setLength(graph, num_str);
            for i := 1 to num_str do begin
                with graph[i] do
                begin
                    {считываем данные из файла в структуру / в отдельный массив виды транспорта}
                end;
            end;            
            read(routes, str);
            writeln(str, num_str);
        end
        else
            writeln('file not found');
    end
    else 
        writeln('submit a file with routes');
end;


var 
    state, oper_mode: char; 
begin
    state := '0';
    read_graph();
    while (state = '0') do 
    begin
        writeln('what do you want to do?(enter a number)', #10#13, '0. start', #10#13, '1. close');
        write('>'); read(state); readln;
        if (state <> '0') and (state <> '1') then
            writeln('wrong input')
        else if (state = '0') then begin
            writeln('enter the operating mode(enter a number)');
            writeln('1. Among the shortest paths in time between two cities, find the path of the minimum cost.');
            writeln('2. Among the paths between two cities, find the path of minimum cost.');
            writeln('3. Find the path between 2 cities minimum by the number of cities visited.');
            writeln('4. Find a set of cities reachable from the city of departure for no more than limit_cost money.');
            writeln('5. Find a set of cities reachable from the senders city in no more than limit_time of time.');
            write('>'); read(oper_mode); readln;
            if (oper_mode < '1') or (oper_mode > '5') then//23и 
                writeln('wrong input')
            else begin
                writeln('enter the type of transport you want to exclude');
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
    end;
end.