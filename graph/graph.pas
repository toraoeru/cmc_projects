program map;

Uses 
    sysutils;

type edge = record 
    city_to: integer;
    tr_name: integer;
    tc:real; mc: real; 
end;

type city = record
    namec: integer; 
    edges: array of edge;
end;

type
    STATES = (ST_EXP, CL_QUOTES_EXP, NUM_EXP);

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
    routes: TextFile; num_str, i, stage, name_len: integer; st_mark, error_: string;
    flag, p_been: boolean; names: array[1..3] of array of char; 
    nums: array[1..2] of real; c: char; state: STATES;
begin
    stage := 1; st_mark := '"'; names[1] := '';
    num_str := 1; names[2] := ''; name_len := 0; 
    names[3] := ''; p_been := false; flag := true;
    state := ST_EXP;
    
    if (paramCount() <> 0) then 
    begin
        assign(routes, paramStr(1));
        {$I-} reset(routes); {$I+}
        if (IOresult = 0) then begin
            while flag and not eof() do 
            begin
                writeln('in while');
                case state of
                    ST_EXP:
                    begin
                        if not eoln(routes) then 
                        begin
                            read(routes, c);
                            if (c <> ' ') and (c <> st_mark) then begin
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
                                readln(routes); num_str := num_str + 1;
                            end
                            else 
                                error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                                flag := false;
                            end;
                        end;
                        CL_QUOTES_EXP:
                        begin
                            if not eoln(routes) then 
                            begin
                                read(routes, c);
                                if c <> '"' then 
                                begin
                                    name_len := name_len + 1;
                                    names[stage, name_len] := c
                                end
                                else begin
                                    if name_len = 0 then begin
                                        if stage < 3 then error_ := 'NAME OF CITY NOT FOUND IN ' + IntToStr(num_str)
                                        else error_ := 'NAME OF TRANSPORT NOT FOUND IN ' + IntToStr(num_str);
                                        flag := false;
                                    end
                                    else begin
                                        setLength(names[stage], name_len);
                                        {заполняем структуру}
                                        state := ST_EXP; stage := stage + 1; name_len := 0;
                                    end;
                                end;
                            end
                            else begin
                                error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                                flag := false;
                            end;
                        end;
                        NUM_EXP:
                        begin
                            if (eoln(routes)) and (stage = 5) and (nums[2] <> 0) then begin
                                readln(routes);
                                num_str := num_str + 1;
                            end
                            else if eoln(routes) then begin
                                error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                                flag := false;
                            end
                            else 
                                read(routes, c);
                                i := 1;
                                if (c >= '0') and (c <= '9') then 
                                begin
                                    if not p_been then
                                        nums[stage - 3] := nums[stage - 3] * 10 + StrToInt(c)
                                    else begin 
                                        i := i + 1;
                                        nums[stage - 3] := nums[stage - 3] + StrToInt(c) / exp(ln(10) * i);
                                    end;
                                end
                                else if c = ' ' then begin state := ST_EXP; stage := stage + 1; end
                                else if (c = '.') and (not p_been) then p_been := true
                                else begin 
                                    error_ := 'INVALID CHAR IN COST IN ' + IntToStr(num_str);
                                    flag := false;
                                end;
                        end;
                end;    
                write(error_);
            end;
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
    
    while (state = '0') do 
    begin
        writeln('what do you want to do?(enter a number)', #10#13, '0. start', #10#13, '1. close');
        write('>'); read(state); readln();
        if (state <> '0') and (state <> '1') then
            writeln('wrong input')
        else if (state = '0') then begin
            writeln('enter the operating mode(enter a number)');
            writeln('1. Among the shortest paths in time between two cities, find the path of the minimum cost.');
            writeln('2. Among the paths between two cities, find the path of minimum cost.');
            writeln('3. Find the path between 2 cities minimum by the number of cities visited.');
            writeln('4. Find a set of cities reachable from the city of departure for no more than limit_cost money.');
            writeln('5. Find a set of cities reachable from the senders city in no more than limit_time of time.');
            write('>'); read(oper_mode); readln();
            if (oper_mode < '1') or (oper_mode > '5') then//23и 
                writeln('wrong input')
            else begin
                read_graph();
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