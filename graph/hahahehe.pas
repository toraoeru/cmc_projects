
program Hello;

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
        if ch = str[i] then res := true;
    end;
    in_str := res;
end;

procedure read_graph();
var 
    routes: text; num_str, i, stage, name_len: integer; st_mark, error_, str: string;
    flag, p_been: boolean; names: array[1..3] of array of char; 
    nums: array[1..2] of real; c: char; state: STATES;
    city_from, city_to, transport: array of char;
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
                case state of
                    ST_EXP:
                    begin
                        //write(1, '_', c, ' ');
                        if not (eoln(routes)) then 
                        begin
                            read(routes, c);
                            if (c <> ' ') and not (in_str(c, st_mark)) then begin
                                error_ := 'INVALID OFF-RECORD CHARACTER IN ' + IntToStr(num_str);
                                writeln(in_str(c, st_mark), c, st_mark);
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
                            //write(2, '_', c, ' ');
                            if not (eoln(routes)) then 
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
                            //write(3, '_', nums[1]:1:1, ' ', nums[2]:1:1, #10#13);
                            
                            if (eoln(routes)) and (stage = 5) and (nums[2] <> 0) then begin
                                for i := 1 to length(names[1]) do
                                    write(names[1, i]);
                                writeln();
                                for i := 1 to length(names[2]) do
                                    write(names[2, i]);    
                                writeln();
                                readln(routes); names[1] := ''; names[2] := ''; name_len := 0; 
                                names[3] := ''; p_been := false; nums[1] := 0; nums[2] := 0;
                                num_str := num_str + 1; state := ST_EXP;
                                st_mark := '"'; stage := 1;

                            end
                            else if (eoln(routes)) then begin
                                error_ := 'UNEXPECTED LINE BREAK ' + IntToStr(num_str);
                                flag := false;
                            end
                            else 
                                read(routes, c);
                                i := 1;
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
                                else if c = ' ' then
                                begin 
                                    state := ST_EXP; stage := stage + 1; p_been := false; 
                                end
                                else if (c = '.') and (not p_been) then p_been := true
                                else begin 
                                    error_ := inttostr(ord(c)) + 'INVALID CHAR IN COST IN ' + IntToStr(num_str);
                                    flag := false;
                                end;
                        end;
                    end;        
                write(error_);
                if stage > 3 then st_mark := '0123456789';
            end;
        end
        else
            writeln('file not found');
    end
    else 
        writeln('submit a file with routes');
end;

begin 
  read_graph();
end.