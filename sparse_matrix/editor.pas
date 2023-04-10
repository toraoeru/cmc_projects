program bulletinmyhead;
{$mode objfpc}
Uses Index, RegExpr, Utils_, sysutils;

const PATTERN_EL = '\s*\d+[.]?\d*'; //?????????

function replace_occur(str, pattern, rep_str: string; num: integer): string;
var i, j: integer; substr, res: string; re: TRegExpr;
begin
    substr := ''; j := 0; res := ''; i := 1;
    re := TRegExpr.Create(pattern);
    while (j <> num) and (i <= length(str)) do begin
        substr := substr + str[i];
        inc(i);
        if ((not re.Exec(substr)) and (re.Exec(slice(substr, 1, length(substr) - 1))))
        or ((i = length(str)) and re.Exec(substr)) then begin
            inc(j);
            substr := '';
            res := res + substr;
        end;
    end;
    res := res + rep_str;
    re := TRegExpr.Create('\s[+-]?([0-9]*[.])?[0-9]+\s');
    while (not re.Exec(substr)) and (i <= length(str)) do begin
        substr := substr + str[i];
        inc(i);
    end;
    res := res + slice(str, i, length(str));
    replace_occur := res;//////////
end;

var 
    ttemp, mtr_tr: tr_ptr; r_n, c_n, des_num, i, j, node_num: integer; val_n: doubLe;
    matrix,f, ind_f: text; str, pattern_str, lab_pat: string; 
    re: TRegExpr; flag: boolean;

begin
    if paramCount() <> 4 then 
        writeln('wrong number of arguments')
    else begin
        assign(matrix, paramStr(1));
        assign(f, 'temp.tr');
        {$I-} reset(matrix); {$I+}

        if IOresult = 0 then begin
            r_n := strtoint(paramStr(2));
            c_n := strtoint(paramStr(3));
            val_n := strtofloat(paramStr(4));
            
            i := 0;
            if slice(paramStr(1), length(paramStr(1)) - 3, length(paramStr(1))) = 'smtr' then begin
                writeln('in smtr');
                mtr_tr := nil;
                create_index(matrix, f, mtr_tr, false); //нужно добавить флаг вывода
                writeln('am i alive&');
                if find(mtr_tr, r_n, c_n) then begin
                    writeln('in in found edge');
                    rewrite(f);
                    re := TRegExpr.Create('\s*' + inttostr(r_n) + '\s+' + inttostr(c_n) + '\s+');
                    while not eof(matrix) do begin
                        //i := i + 1;
                        readln(matrix, str);
                        if re.Exec(str) then  
                            writeln(f, r_n, SPACE_ST, c_n, SPACE_ST, val_n:10:5)
                        else writeln(f, str);
                    end;
                    close(matrix);
                    //writeln('am i alive&');
                    close(f); 
                    //writeln('am i alive&');
                    erase(matrix);
                    //writeln('am i alive&');
                    rename(f, paramStr(1));
                    //writeln('am i alive&');
                    matrix := f;
                    
                end
                else begin
                    writeln('in not found');
                    append(matrix);
                    writeln(matrix, r_n, SPACE_ST, c_n, SPACE_ST, val_n:10:5);
                    close(matrix);/////
                end
            end
            else begin
                writeln('in dmtr');
                pattern_str := PATTERN_EL;
                //for i := 2 to c_n do
                //    pattern_str := pattern_str + PATTERN_EL;
                i := 1;
                re := TRegExpr.Create(PATTERN_EL);
                rewrite(f); flag := true;
                while not eof(matrix) do begin
                    readln(matrix, str);
                    if re.Exec(str) then inc(i);
                    if (i = r_n) then //////////
                        writeln(f, replace_occur(str, pattern_str, floattostr(val_n), c_n))
                    else 
                        writeln(f, str);
                end;
                close(matrix);
                close(f); 
                erase(matrix);
                rename(f, paramStr(1));
                matrix := f;
            end;
            {assign(ind_f, slice(paramStr(1), 1, length(paramStr(1)) - 4) + 'dot');
            writeln('am i alive&');
            {$I-} reset(ind_f); {$I+}
            writeln('am i alive&');
            if IOresult = 0 then begin
                writeln('in dot find');
                //fuckkkkkkkkkkkkkkkkkkkkkkkkkkkkfhojdkedassncsvcbhjtxdgr']AQGT5SHFV.":
                if find(mtr_tr, r_n, c_n) then begin
                    writeln('in edge find');
                    lab_pat := '\s*\d\s*[label="' + inttostr(r_n) + '\s*' + inttostr(c_n) + '\\n\s';
                    rewrite(f); 
                    re := TRegExpr.Create(lab_pat);
                    while (not eof(ind_f)) and (pos('//edges', str) <> 0) do begin
                        readln(ind_f, str);
                        if re.Exec(str) then writeln(f, slice(str, 1, pos('[', str)), ' [label="', r_n, '  ', c_n, '\n    ', val_n, '"];')
                        else writeln(f, str);
                    end;
                end
                else begin
                    writeln('in edge not found');
                    i := 0;
                    while (not eof(ind_f)) and (pos('//edges', str) <> 0) do begin
                        readln(ind_f, str);
                        inc(i);
                    end;
                    writeln('fgjlsldf');
                    reset(ind_f);
                    writeln('fgjlsldf');
                    rewrite(f); 
                    for j := 0 to i - 1 do begin
                        readln(ind_f, str);
                        writeln(f, str);
                    end;
                    node_num := strtoint(slice(str, 1, pos('[', str))) + 1;
                    writeln(f, node_num, ' [label="', r_n, '  ', c_n, '\n    ', val_n, '"];');
                    add(mtr_tr,  pos('[', str) + 1, r_n, c_n, val_n);
                    ttemp := return_parent(mtr_tr, r_n, c_n);
                    if (ttemp^.left = nil) or (ttemp^.right = nil) then begin
                        writeln('in 1 child');
                        while not eof(ind_f) do begin
                            readln(ind_f, str);
                            writeln(f, str);
                        end;
                        if (ttemp^.left = nil) then writeln(f,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="R"];')
                        else writeln(f,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="L"];');
                    end
                    else begin
                        writeln('in 2 child');
                        while not eof(ind_f) do begin
                            readln(ind_f, str);
                            if pos(inttostr(ttemp^.node_number), slice(str, 1, pos('[', str))) <> 0 then begin
                                write(f, str);
                                if pos('R', str) <> 0 then writeln(f,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="L"];')
                                else writeln(f,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="R"];'); 
                            end
                            else writeln(f, str);
                        end;
                    end;
                end;
                close(f); 
                close(ind_f);
                erase(ind_f);//////////////
                rename(f, slice(paramStr(1), 1, length(paramStr(1)) - 4) + 'dot');
                ind_f := f;
            end
            else begin
                writeln('dot not exist');
                rewrite(ind_f);
                writeln(ind_f, 'digraph', #13#10, '{');
                create_index(matrix, ind_f, mtr_tr, true);
                writeln(ind_f, #13#10, #9, '//edges', #10#13);
                pr_edges(mtr_tr, ind_f);
                write(ind_f, #13#10, '}');
                close(ind_f);
                close(matrix);
            end;
        end    
        else 
            writeln('there is no such file');
    end;
end.
//добавить вывод в 1 и 3
//а что с большими строками столбцами
//знаки в шаблоне и смтр