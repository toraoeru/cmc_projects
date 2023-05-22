program letmedie;

{$mode objfpc}
Uses Utils_, sysutils;
//структура данных для csr
const
    SELF_RESPECT = 0.00001;
type
    mtr_crs = record
        pointr: array of integer;
        cols: array of integer;
        value: array of integer;
    end;

    crs_help = array of array[1..3] of double;

    readin_nums_st = (new_line_exp, num_exp, int_part, frac_part, eoln_exp);

procedure get_size(var f: text; var x: integer; var y: integer);
var str: string; i: integer;
begin
    str := '';
    while (not eof(f)) and (pos('_matrix', str) = 0) do
        readln(f, str);
    i := 1;
    while (i <= length(str)) and ((str[i] > '9') or (str[i] < '0')) do 
        inc(i);
    x := strtoint(str[i]);
    inc(i);
    while (i <= length(str)) and (str[i] <= '9') and (str[i] >= '0') do begin
        x := x*10 + strtoint(str[i]);
        inc(i);
    end;
    while (i <= length(str)) and ((str[i] > '9') or (str[i] < '0')) do 
        inc(i);
    y := strtoint(str[i]);
    inc(i);
    while (i <= length(str)) and (str[i] <= '9') and (str[i] >= '0') do begin
        y := y*10 + strtoint(str[i]);
    end;
end;
//непр на мнов
//касат плоско
//диф второго порядка в точке

procedure sort(var crs: crs_help);
var i, j: integer; k: double;
begin
    for i := 0 to length(crs) - 1 do begin
        for j := 1 to length(crs) - i do begin
            if crs[j, 1] > crs[j + 1, 1] then begin
                k := crs[j, 1];
                crs[j, 1] := crs[j + 1, 1];
                crs[j + 1, 1]:=k;

                k := crs[j, 2];
                crs[j, 2] := crs[j + 1, 2];
                crs[j + 1, 2]:=k;

                k := crs[j, 3];
                crs[j, 3] := crs[j + 1, 3];
                crs[j + 1, 3]:=k;
            end
            else if (crs[j, 1] = crs[j + 1, 1]) and (crs[j,2] > crs[j + 1, 2]) then begin
                k := crs[j,2];
                crs[j, 2] := crs[j + 1, 2];
                crs[j + 1, 2]:= k;

                k := crs[j,3];
                crs[j,3] := crs[j + 1,3];
                crs[j + 1, 3]:=k;
            end
        end;
    end;
end;

{function num_sotr_ar(ar: , f: integer): integer;
var i, res: integer;
begin
    while ar[i] <> f do inc(i);
    inc(res);
    while ar[i] = f do begin
        inc(i);
        inc(res);
    end;
    num_sotr_ar := res;
end;}

function mult(m1, m2:mtr_crs): mtr_crs;
begin
end;

function build_crs(var matrix: text; is_tr, is_smtr: boolean; row_n, coln_n: integer): mtr_crs;
var num_readin_st: readin_nums_st;
    i, j, row, col, step, str_num, cur_col, sign, count: integer;
    c: char; is_error, is_root: boolean; form_name: string;
    val, fr_p: double; killme: crs_help;

    procedure break_line();//for smtr
    begin
        writeln('wtf');
        str_num := str_num + 1; 
        if is_tr then begin 
            killme[count, 2] := row;
            killme[count, 1] := col;
        end
        else begin 
            killme[count, 1] := row;
            killme[count, 2] := col;
        end;
        killme[count, 3] := val*sign;
        writeln(killme[count, 1], ' ', killme[count, 2], ' ', killme[count, 3]);
        inc(count);
        /////////////////////////////////////////
        //add(tr_matrix, str_num, row, col, val);
        //if print_file then writeln(indx, #9, str_num, ' [label="', row, '  ', col,'\n', sign*val:10:5, '"];');
        step := 0; row := 0; col := 0; val := 0; sign := 1;
        num_readin_st := new_line_exp; fr_p := 0;
        readln(matrix); //res: mtr_crs; //inc(count);
    end;

    procedure next_num();
    begin
        killme[count, 1]  := str_num;
        killme[count, 2]  := cur_col;
        killme[count, 3]  := val*sign;
        writeln(killme[count, 1], ' ', killme[count, 2], ' ', killme[count, 3]);
        cur_col := cur_col + 1; inc(count);
        //res.value[(str_num - 1)*row_n + cur_col - 1] := val*sign;
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
    //str_num := 0; cur_col := 0; 
    //row := 0; col := 0; val := 0;
    sign := 1; //count := 0;
    //setlength(killme, row_n);
    setlength(killme, row_n*coln_n);
    //setlength(killme, row_n*coln_n);
    if not is_smtr then begin
        num_readin_st := new_line_exp;
        {for i := 1 to coln_n do begin
            setlength(killme[i - 1][1], coln_n);
            setlength(killme[i - 1][2], coln_n);
        end;}
        //writeln( eof(matrix), is_error, 'wtf ure here');
        while (not eof(matrix)) and (not is_error) and (str_num <= row_n) do begin
            writeln('im here');
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
        //setlength(killme,count);
        {res.pointr[0] := 0;
        for i:= 1 to length(res.pointr) - 1 do 
            res.pointr[i] := coln_n;
        for i:= 0 to length(res.cols) - 1 do 
            res.pointr[i] := i mod row_n + 1;}
    end
    else begin
        count := 0;
        setlength(killme, row_n*coln_n);
        //writeln( (not eof(matrix)) and (not is_error) );
        while (not eof(matrix)) and (not is_error) do begin
            writeln(num_readin_st);
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
                            else if (c = ' ') and (step = 3) then begin
                                writeln('br5');
                                break_line();
                            end
                            else if c = ' ' then num_readin_st := num_exp
                            else is_error := true;
                        end
                        else if step = 3 then begin
                            writeln('br4');
                            break_line();

                        end
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
                                writeln('br2');
                                break_line();
                            end                                                
                            else is_error := true;
                        end
                        else begin
                            if fr_p > SELF_RESPECT then
                                val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                            writeln('br');
                            break_line();
                        end;
                    end;
            end;
        end;
       

    end;
    {setlength(killme, count);
    write(count,'           ');
    for i := 0 to length(killme) -1 do begin
        for j:=1 to 3 do
            write(killme[i,j],'\n');
        writeln();
    end;

    sort(killme);

    for i := 0 to length(killme) -1 do begin
        for j:=1 to 3 do
            write(killme[i,j],'\n');
        writeln();
    end;}
    //build_crs := res;
end;

var 
    m1, m2: text; str, files: string; 
    mr1, mr2: mtr_crs;
    x1, x2, y1, y2, i: integer;
begin
    {если найдется рахреженная - результат разреженная
    првоерить размеры
    от трех аргкментов}
    if paramCount() < 4 then
        writeln('wrong num of args')
    //генерим сирэс для первых двух перемножаем, получаем сирэс, строим срс для след перемножаем и тд...
    else begin
        assign(m1, paramStr(3));
        reset(m1); {$I+} 
        if IOresult = 0 then begin
       //function build_crs(var matrix: text; is_tr, is_smtr: boolean; row_n, coln_n: integer): mtr_crs;
            get_size(m1, x1, y1);
            mr1 := build_crs(m1, false, not(pos('smtr',  paramStr(3)) = 0), x1, y1);    
            //writeln('re y ok');       
        end
        else 
            writeln('file not found');
        for i := 4 to paramCount() do begin
       // writeln('well');
            //проверяем размеры трансопнируем перемножаем в кур
            {$I-} assign(m2, paramStr(i));
            reset(m2); {$I+}
            if IOresult <> 0 then begin
                writeln('file not found');
                break;
            end
            else begin
                get_size(m2, x2, y2);
                if y1 <> x2 then 
                    writeln('wrong size in ', i)
                else begin
                    mr2 := build_crs(m2, true,not(pos('smtr',  paramStr(3)) = 0), x2, y2);
                    mr1 := mult(mr1, mr2);
                end;
            end;
            y1 := y2;
        end;
        //srite
        {files := '';
        for i := 2 to paramCount() - 1 do 
            files := files + paramStr(i);
        if pos('smtr', files) = 0 then begin

        end
        else begin

        end;}
        //if paramStr(2) = 'smtr' then begin

    end;
end.