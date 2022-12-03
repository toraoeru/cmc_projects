st_mark: string;
stage := 1; st_mark := '"';
num_str := 1; city_from: array of char;
city_from := ''; name_len: integer; name_len := 0; time_cost



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
                    else if in_str(c, st_mark) and (st_mark <> '"') then
                        state := NUM_EXP;
                end
                else begin
                    if stage = 1 then begin
                        readln();
                        num_str := num_str + 1;
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
                        if stage = 1 then city_from[name_len] := c
                        else if stage = 2 then city_to[name_len] := c
                        else if stage = 3 then transport[name_len] := c;
                    else begin
                        if name_len = 0 then begin
                            if stage <> 3 then error_ := 'NAME OF CITY NOT FOUND IN ' + IntToStr(num_str)
                            else error_ := 'NAME OF TRANSPORT NOT FOUND IN ' + IntToStr(num_str);
                            flag := false;
                        end
                        else begin
                            if stage = 1 then setLength(city_from, name_len)
                            else if stage = 2 then setLength(city_to, name_len)
                            else if stage = 3 then setLength(transport, name_len);
                            {заполняем структуру}
                            if stage <> 3 then state := OP_QUOTES_EXP
                            else state := NUM_EXP;
                            stage := stage + 1; name_len := 0;
                        end;
                    end;
                end;
            end;
            NUM_EXP:
            begin
                i := 1;
                while i <= length(ENDWORD) do 
                begin
                    if c <> ENDWORD[i] then 
                    begin
                        error_ := 'EXPRESSION NOT RECOGNIZED IN ' + IntToStr(num_str);
                        flag := false;
                        i := length(ENDWORD) + 1;
                    end;
                    read(c);
                    i := i + 1;
                end;
                flag := false;
            end;
        
    
    write(error_);
    end;