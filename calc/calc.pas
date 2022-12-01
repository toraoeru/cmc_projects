program fsm;

{$mode objfpc}{$H+}

Uses sysutils,
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads,
    {$ENDIF}{$ENDIF}
    Classes;

const 
    OPERATIONS = ['+', '-', '*', '/'];
    FNAME = 'tests/input.txt'; 
    ALPH = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*';
    ENDWORD = 'finish';
    PRECIS = 0.000001;

type
    STATES = (OPERATION_EXP, BASE_EXP, SEP_EXP, NUMERATOR_EXP, DENUMERATOR_EXP, EOLN_EXP, FIN_EXP);

var 
    result: real; i, num_str: integer; error_: string; flag: boolean;

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

procedure read_lbr(var c: char);
begin
    read(c);
    if eoln() then 
    begin
        error_ := 'UNEXPECTED LINE BREAK IN ' + IntToStr(num_str);
        flag := false;
    end;
end;

function slice_str(str: string; sti, endi: integer): string;
var res: string; i: integer;
begin
    res := '';
    for i := sti to endi do
        res := res + str[i];
    exit(res);
end;


function parser(): real;
var 
    c, operation: char; nch_is_read, bch_is_read, s_is_read: boolean; 
    base, i: integer; sign: -1..1; res: real; denumerator: longword;
    state: STATES; numerator: longint;
begin
    sign := 1; denumerator := 0; num_str := 1; res := 0;
    state := operation_EXP; flag := true; error_ := '';
    base := 0; numerator := 0; bch_is_read := false;
    nch_is_read := false; s_is_read := false;

    while flag and not eof() do 
    begin
        case state of
            OPERATION_EXP:
                begin
                    if not eoln() then 
                    begin
                        read(c);
                        if c in OPERATIONS then 
                        begin
                            operation := c;
                            state := BASE_EXP;
                        end
                        else if (c <> ' ') and (ord(c) <> 9) then 
                        begin
                            if c = ENDWORD[1] then state := FIN_EXP
                            else if c = ';' then 
                            begin
                                readln();
                                num_str := num_str + 1;
                            end
                            else 
                            begin
                                error_ := 'OPERATION ERROR IN ' + IntToStr(num_str);
                                flag := false;
                            end;
                        end;
                    end
                    else 
                    begin
                        readln();
                        num_str := num_str + 1;
                    end;
                end;
             FIN_EXP:
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
            BASE_EXP:
                begin
                    read_lbr(c);
                    if (c >= '0') and (c <= '9') then 
                    begin
                        base := base * 10 + StrToInt(c);
                        bch_is_read := true;
                    end
                    else if c = ':' then 
                    begin 
                        if (base = 0) or (base = 1) then 
                        begin
                            error_ := 'INCORRECT NUMBER BASE IN ' + IntToStr(num_str); 
                            flag := false;
                        end 
                        else state := NUMERATOR_EXP;
                    end 
                    else if (c = ' ') or (ord(c) = 9) then 
                    begin
                        if bch_is_read then 
                        begin 
                            if (base = 0) or (base = 1) then 
                            begin
                                error_ := 'INCORRECT NUMBER BASE IN ' + IntToStr(num_str); 
                                flag := false;
                            end 
                            else state := SEP_EXP;
                        end
                    end
                    else 
                    begin
                        error_ := 'WRONG CHARACTER, BASE EXPECTED IN ' + IntToStr(num_str);
                        flag := false;
                    end;
                end;
            SEP_EXP: 
                begin
                    read_lbr(c);
                    if c = ':' then state := NUMERATOR_EXP
                    else if (c <> ' ') and (ord(c) <> 9) then 
                    begin 
                        error_ := 'WRONG CHARACTER, : EXPECTED IN ' + IntToStr(num_str);
                        flag := false;
                    end;    
                end;
            NUMERATOR_EXP:
                begin
                    read_lbr(c);
                    if in_str(c, ALPH) then 
                    begin
                        if pos(c, ALPH) - 1 >= base then 
                        begin
                            error_ := 'INVALID DIGIT IN ' + IntToStr(num_str);
                            flag := false;
                        end
                        else if (numerator * base + (pos(c, ALPH) - 1) < -maxint - 1) 
                        or (numerator * base + (pos(c, ALPH) - 1) > maxint) then 
                        begin 
                            error_ := 'THE NUMERATOR IS TOO LARGE IN ' + IntToStr(num_str);
                            flag := false;
                        end 
                        else
                        begin
                            numerator := numerator * base + (pos(c, ALPH) - 1);
                            nch_is_read := true;
                        end
                    end
                    else if c = '-' then 
                    begin
                        if (nch_is_read) or (s_is_read) then 
                        begin
                            error_ := '- IN WRONG PLACE IN ' + IntToStr(num_str);
                            flag := false;
                        end
                        else 
                        begin
                            sign := -1;
                            s_is_read := true;
                        end
                    end
                    else if c = '/' then 
                    begin 
                        if not nch_is_read then 
                        begin 
                            error_ := 'NUMERATOR NOT FOUND IN ' + IntToStr(num_str);
                            flag := false;
                        end
                        else 
                        begin
                            numerator := numerator * sign;
                            state := DENUMERATOR_EXP;
                            nch_is_read := false;
                        end
                    end
                    else 
                    begin
                        error_ := 'WRONG CHARACTER, NUMERATOR EXPECTED IN ' + IntToStr(num_str);
                        flag := false;
                    end;
                end;
            DENUMERATOR_EXP:
                begin
                    read_lbr(c);
                    if in_str(c, ALPH) then 
                    begin
                        if (denumerator * base + (pos(c, ALPH) - 1) > maxint) then 
                        begin 
                            error_ := 'THE DENUMERATOR IS TOO LARGE IN ' + IntToStr(num_str);
                            flag := false;
                        end 
                        else
                        begin
                            denumerator := denumerator * base + (pos(c, ALPH) - 1);
                            nch_is_read := true;
                        end
                    end 
                    else if c = ';' then 
                    begin 
                        if not nch_is_read then 
                        begin 
                            error_ := 'DENUMERATOR NOT FOUND IN ' + IntToStr(num_str);
                            flag := false;
                        end
                        else if denumerator = 0 then 
                        begin 
                            error_ := 'DENUMERATOR IS ZERO IN ' + IntToStr(num_str);
                            flag := false;
                        end
                        else state := EOLN_EXP;
                    end
                    else if (c <> ' ') and (ord(c) <> 9) then 
                    begin
                        error_ := 'WRONG CHARACTER, DENUMERATOR EXPECTED IN ' + IntToStr(num_str);
                        flag := false;
                    end;
                end;
            EOLN_EXP:
                begin
                    while not eoln() do read(c);
                    case OPERATION of
                        '+': res := res + numerator / denumerator;
                        '-': res := res - numerator / denumerator;
                        '*': res := res * numerator / denumerator;
                        '/': res := res / numerator / denumerator;
                    end;
                    nch_is_read := false; s_is_read := false;
                    bch_is_read := false; denumerator := 0;
                    numerator := 0; sign := 1; base := 0;
                    readln();
                    num_str := num_str + 1;
                    state := OPERATION_EXP;
                end;
        end;
        write(error_);
    end;
    parser := res;
end;

function to10_notation(numer: string; base: integer): real;
var tnumer: real; i, sign: integer;
begin
    sign := 1;
    if numer[1] = '-' then 
    begin
        sign := -1; 
        delete(numer, 1, 1);
    end;
    tnumer := 0;
    for i := 1 to length(numer) do 
        tnumer := tnumer + exp(ln(base) * (length(numer) - i))*(pos(numer[i], ALPH) - 1);

    to10_notation := sign * tnumer;
end;

function changef10_notation(num: real; base: integer): string;
var resI, resF, sign: string; n, dnumer, precision: real; i, numer: integer;
begin
    if base = 10 then 
        exit(FloatToStr(num));

    precision := 0.1; sign := '';
    if paramCount() <> 0 then 
        precision := StrToFloat(paramStr(1));

    if num < 0 then 
    begin
        sign := '-'; 
        num := -1 * num;
    end; 
   
    resI := ''; resF := '.'; i := 0;
    numer := trunc(num); dnumer := frac(num);
    repeat
        n := dnumer * base;
        dnumer := frac(n);
        resF := resF + ALPH[trunc(n) + 1];
        i := i + 1;
    until abs((to10_notation(slice_str(resF, 2, length(resF)), base) / (exp(ln(base) * i))) - frac(num)) < precision - PRECIS;
    resF := resF + ALPH[trunc(dnumer * base) + 1];

    while numer <> 0 do 
    begin   
        resI := ALPH[numer mod base + 1] + resI;
        numer := numer div base;
    end;
    if resI = '' then resI := '0';
    changef10_notation := sign + resI + resF;
end;


begin
    if (paramCount() <> 0) and (StrToFloat(paramStr(1)) = 0) then 
        writeln('UNATTAINABLE ACCURACY')
    else 
    begin    
        result := parser();
        if error_ = '' then
        begin
            for i := 2 to paramCount() do 
                writeln(paramStr(i), '    ', changef10_notation(result, StrToInt(paramStr(i))));
        end;
    end;
end.