program map;

Uses 
    Crt;

type route = record 
    fr_city, to_city, transport: string;
    time, fare: integer;
end;

var graph: array of route;

procedure read_graph();
var routes: text; str: string; num_str, i: integer;
begin
    if (paramCount() <> 0) then 
    begin
        assign(routes, paramStr(1));
        {$I-} reset(routes); {$I+}
        if (IOresult = 0) then begin
            num_str := 0;
            while not eof(routes) do begin
                num_str := num_str + 1;
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
            if (oper_mode < '1') or (oper_mode > '5') then
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