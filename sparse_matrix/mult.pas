program letmedie;

{$mode objfpc}
Uses Utils_, sysutils;
//структура данных для csr
type
    mtr_crs = record
        pointr: array of integer;
        cols: array of integer;
        value: array of integer;
    end;

    crs_help = array of array[1..3] of integer;

    readin_nums_st = (new_line_exp, num_exp, int_part, frac_part, eoln_exp);

procedure get_size(var f: text; var x: integer; var y: integer);
var str: string; i: integer;
begin
    str := '';
    while (not eof(f)) and (pos('_matrix', str) = 0) do
        readln(f, str);
    i := 1;
    while (i <= length(str)) and (str[i] > '9') and (str[i] < '0') do 
        inc(i);
    x := strtoint(str[i]);
    while (i <= length(str)) and (str[i] <= '9') and (str[i] >= '0') do 
        x := x*10 + strtoint(str[i]);
    while (i <= length(str)) and (str[i] > '9') and (str[i] < '0') do 
        inc(i);
    y := strtoint(str[i]);
    while (i <= length(str)) and (str[i] <= '9') and (str[i] >= '0') do 
        y := y*10 + strtoint(str[i]);
end;
//непр на мнов
//касат плоско
//диф второго порядка в точке

procedure sort(var crs: crs_help);
var i, j, k: integer;
begin
    for i := 0 to length(crs) - 1 do begin
        for j := 1 to length(crs) - i do begin
            if crs[1][j] > crs[1][j + 1] then begin
                k := crs[1][j];
                crs[1][j] := crs[1][j + 1];
                crs[1][j + 1]:=k;

                k := crs[2][j];
                crs[2][j] := crs[2][j + 1];
                crs[2][j + 1]:= k;

                k := crs[3][j];
                crs[3][j] := crs[3][j + 1];
                crs[3][j + 1]:=k;
            end
            else if (crs[1][j] = crs[1][j + 1]) and (crs[2][j] > crs[2][j + 1]) then begin
                k := crs[2][j];
                crs[2][j] := crs[2][j + 1];
                crs[2][j + 1]:= k;

                k := crs[3][j];
                crs[3][j] := crs[3][j + 1];
                crs[3][j + 1]:=k;
            end
        end;
    end;
end;

function num_sotr_ar(ar: , f: integer): integer;
var i, res: integer;
begin
    while ar[i] <> f do inc(i);
    inc(res);
    while ar[i] = f do begin
        inc(i);
        inc(res);
    end;
    num_sotr_ar := res;
end;

function build_crs(var matrix: text; is_tr, is_smtr: boolean; row_n, coln_n: integer): mtr_crs;
var num_readin_st: readin_nums_st;
    i, row, col, step, str_num, cur_col, sign, count: integer;
    c: char; is_error, is_root: boolean; form_name: string;
    sval, fr_p: double; killme: crs_help;

    procedure break_line();
    begin
        str_num := str_num + 1; sign := 1;
        killme[1][count] := row;
        killme[2][count] := col;
        killme[3][count] := val;
        /////////////////////////////////////////
        //add(tr_matrix, str_num, row, col, val);
        //if print_file then writeln(indx, #9, str_num, ' [label="', row, '  ', col,'\n', sign*val:10:5, '"];');
        step := 0; row := 0; col := 0; val := 0;
        num_readin_st := new_line_exp; fr_p := 0;
        readln(matrix); res: mtr_crs; //inc(count);
    end;

    procedure next_num();
    begin
        cur_col := cur_col + 1; 
        res.value[(str_num - 1)*row_n + cur_col - 1] := val*sign;
        val := 0;  fr_p := 0; sign := 1; fr_p := 0; 
        if coln_n <> cur_col then num_readin_st := num_exp;
    end;

    procedure bl_den();
    begin
        str_num := str_num + 1; cur_col := 0;
        num_readin_st := new_line_exp; 
        readln(matrix);
    end;
begin
    setlength(res.pointr, row_n);
    setlength(res.value, row_n*coln_n);
    setlength(res.cols, row_n*coln_n);
    if not is_smtr then begin
        num_readin_st := new_line_exp;
        for i := 1 to coln_n do begin
            setlength(killme[i - 1][1], coln_n);
            setlength(killme[i - 1][2], coln_n);
        end;
        while (not eof(matrix)) and (not is_error) and (str_num <= row_n) do begin
            case num_readin_st of 
                new_line_exp:
                    begin
                        if eoln(matrix) then readln(matrix)
                        else num_readin_st := num_exp;
                    end;
                num_exp:
                    begin
                        read(matrix, c);
                        if in_str(c, '1234567890') then begin
                            num_readin_st := int_part;
                            val := strtoint(c);
                        end
                        else if c = '-' then begin
                            sign := -1;
                            num_readin_st := int_part;
                        end
                        else if c <> ' ' then
                            is_error := true;  
                    end;
                int_part:
                    begin
                        if not eoln(matrix) then begin
                            if cur_col = (coln_n) then bl_den()
                            else begin
                                read(matrix, c);
                                if in_str(c, '1234567890') then 
                                    val := val*10 + strtoint(c)
                                else if c = '.' then num_readin_st := frac_part
                                else if (c = ' ') then next_num()
                                else is_error := true;
                            end;
                        end
                        else if cur_col = coln_n  then bl_den()
                        else is_error := true;
                    end;
                frac_part: 
                    begin
                        if not eoln(matrix) then begin
                            if cur_col = (coln_n ) then bl_den()
                            else begin
                                read(matrix, c);
                                if in_str(c, '1234567890') then 
                                    fr_p := fr_p*10 + strtoint(c)
                                else if c = ' ' then begin
                                    if fr_p > SELF_RESPECT then
                                        val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                    next_num();
                                end                                                
                                else is_error := true;
                            end;
                        end
                        else if cur_col = (coln_n  - 1) then begin 
                            if fr_p > SELF_RESPECT then begin
                                //writeln('2fjksdfsd');
                                val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                            end;
                            next_num();
                            bl_den();
                        end
                        else if cur_col = (coln_n ) then bl_den()
                        else is_error := true;
                    end;
            end;
        end;
        res.pointr[0] := 0;
        for i:= 1 to length(res.pointr) - 1 do 
            res.pointr[i] := coln_n;
        for i:= 0 to length(res.cols) - 1 do 
            res.pointr[i] := i mod row_n + 1;
    end
    else begin
        count := 0;
        setlength(killme, row_n*coln_n);
        while (not eof(matrix)) and (not is_error)do begin
            case num_readin_st of 
                new_line_exp:
                    begin
                        if eoln(matrix) then readln(matrix)
                        else num_readin_st := num_exp;
                    end;
                num_exp:
                    begin
                        read(matrix, c);
                        if in_str(c, '1234567890') then begin
                            num_readin_st := int_part;
                            step := step + 1;
                            if row = 0 then row := strtoint(c)
                            else if col = 0 then col := strtoint(c)
                            else val := strtoint(c);
                        end
                        else if c = '-' then begin
                            sign := -1;
                            num_readin_st := int_part;
                        end
                        else if c <> ' ' then begin is_error := true;  end;
                    end;
                int_part:
                    begin
                        if not eoln(matrix) then begin
                            read(matrix, c);
                            if in_str(c, '1234567890') then begin
                                if step = 1 then row := row*10 + strtoint(c)
                                else if step = 2 then col := col*10 + strtoint(c)
                                else val := val*10 + strtoint(c);
                            end
                            else if (c = '.') and (step = 3) then num_readin_st := frac_part
                            else if (c = ' ') and (step = 3) then break_line()
                            else if c = ' ' then num_readin_st := num_exp
                            else is_error := true;
                        end
                        else if step = 3 then break_line()
                        else is_error := true;
                    end;
                frac_part: 
                    begin
                        //writeln(row, col, val, str_num);
                        if not eoln(matrix) then begin
                            read(matrix, c);
                            if in_str(c, '1234567890') then 
                                fr_p := fr_p + strtoint(c)
                            else if (c = '#') or (c = ' ') then begin
                                if fr_p > SELF_RESPECT then
                                begin
                                    //writeln('3fjksdfsd');
                                    val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                end;
                                break_line();
                            end                                                
                            else is_error := true;
                        end
                        else begin
                            if fr_p > SELF_RESPECT then
                                val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                            break_line();
                        end;
                    end;
            end;
        end;
        setlength(killme, str_num);
        sort(killme);

    end;
    build_crs := res;
end;

var 
    m1, m2: text; str, files: string; 
    i, r1, r2, c1, c2: integer; mr1, mr2: mtr_crs;
begin
    {если найдется рахреженная - результат разреженная
    првоерить размеры
    от трех аргкментов}
    if paramCount() < 4 then
        writeln('wrong num of args')
    {else if paramCount() = 3 then begin
    //why
        {$I-} //assign(m1, paramStr(2));
       // reset(m1); {$I+} 
       { if IOresult = 0 then begin
            assign(m2, paramStr(3));
            rewrite(m2);
            while not eof(m1) do begin
                readln(m1, str);
                writeln(m2, str);
            end;
        end
        else 
            writeln('cannt read matrix 1');
    end;}
    //генерим сирэс для первых двух перемножаем, получаем сирэс, строим срс для след перемножаем и тд...
    else begin
        assign(m1, paramStr(3));
        reset(m1); {$I+} 
       if IOresult = 0 then begin
            mr1 := build_crs(m2, false)
            get_size(m1, x1, y1);
        end
        else 
            writeln('file not found');
        for i := 4 to paramCount() do begin
            //проверяем размеры трансопнируем перемножаем в кур
            {$I-} assign(m1, paramStr(i));
            reset(m1); {$I+}
            if IOresult <> 0 then begin
                writeln('file not found');
                break;
            end
            else begin
                get_size(m1, x1, y1);
                if y2 <> x1 then 
                    writeln('wrong size in ', i);
                else
                    mr1 := build_crs(m1, true);
                    mr2 := mult(mr1, mr2);
            end;
            x2 := x1; y2 := y1;
        end;
        //srite
        files := '';
        for i := 2 to paramCount() - 1 do 
            files := files + paramStr(i);
        if pos('smtr', files) = 0 then begin

        end
        else begin

        end;
    end;
end;