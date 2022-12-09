program shit_code;

Uses 
    sysutils;

type
    STATES = (ST_EXP, CL_QUOTES_EXP, NUM_EXP);

type link = ^edge;

edge = record 
    namec: integer;
    city_to: link;
    tr_name: integer;
    tc: real; mc: real; 
end;

var 
    graph: array of edge; cities, transport: array of array of char;

function in_str(ch: char; str: string): boolean;
var i: integer;
begin
    in_str := false;
    for i := 1 to length(str) do 
    begin
        if ch = str[i] then in_str := true;
    end;
end;

function in_ar(el: array of char; ar: array of array of char): boolean;
var i: integer;
begin
    in_ar := false;
    for i := 1 to length(ar) do 
    begin
        if el = ar[i] then in_ar := true;
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
    routes: text; num_str, i, stage, name_len, n_uniq: integer; st_mark, error_: string;
    flag, p_been: boolean; nums: array[1..2] of real; c: char; state: STATES;
    city_from, city_to, transport: array of char;
begin
    stage := 1; st_mark := '"';
    num_str := 1; name_len := 0; p_been := false; flag := true;
    state := ST_EXP; city_from := ''; city_to := '';
    transport := ''; i := 1;
    setLength(city_from, 512);
    setLength(city_to, 512);
    setLength(transport, 512);

    if (paramCount() <> 0) then 
    begin
        assign(routes, paramStr(1));
        {$I-} reset(routes); {$I+}
        if (IOresult = 0) then begin
            while flag and not eof(routes) do 
            begin          
                case state of
                    ST_EXP:
                    begin
                        //write(1, '_', c, '   ');
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
                        //write(2, '_', c, '   ');
                        read_lbr(routes, c, num_str, flag, error_);
                        if c <> '"' then 
                        begin
                            name_len := name_len + 1;
                            if stage = 1 then city_from[name_len] := c
                            else if stage = 2 then city_to[name_len] := c
                            else if stage = 3 then transport[name_len] := c;
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
                        //write(3, '_', c, '   ');
                        read(routes, c);
                        if (stage = 5) and (nums[2] <> 0) and (eoln(routes) or (c = '#')) then begin
                            for i := 1 to length(city_from) do write(city_from[i]);
                            write('        ');
                            for i := 1 to length(city_to) do write(city_to[i]);   
                            write('        ');
                            for i := 1 to length(transport) do write(transport[i]); 
                            writeln();

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
                                    if not p_been then
                                        nums[stage - 3] := nums[stage - 3] * 10 + StrToInt(c)
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
                            else if (c = ' ') and (stage = 5) then
                            begin
                                readln(routes); city_from := ''; city_to := ''; name_len := 0; 
                                transport := ''; p_been := false; nums[1] := 0; nums[2] := 0;
                                num_str := num_str + 1; state := ST_EXP; st_mark := '"'; stage := 1;
                                setLength(city_from, 512); setLength(city_to, 512); setLength(transport, 512);
                            end
                            else if (c = '.') and (not p_been) then p_been := true
                            else begin 
                                error_ := IntToStr(ord(c)) + 'INVALID CHAR IN COST IN ' + IntToStr(num_str);
                                flag := false;
                            end;
                        end;
                    end;
                end;    
                write(error_);
                if stage > 3 then st_mark := '0123456789';
            end;
        end
        else writeln('file not found');
    end
    else writeln('submit a file with routes');
end;

begin 
    read_graph();
end.