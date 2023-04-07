program bulletinmyhead;

Uses Index, RegExpr;;

var 
    tr: tr_ptr; r_n, c_n, des_num, i: integer; val_n: doubLe;
    matrix,f: text; mtr_tr: tr_ptr; str: string; re: TRegExpr;
begin
    if paramCount() <> 4 then 
        writeln('wrong number of arguments')
    else begin
        assign(matrix, paramStr(1));
        assign(f, 'temp.pas');
        {$I-} reset(matrix); {$I+}

        if IOresult = 0 then begin
            mtr_tr := nil;
            create_index(matrix, f, mtr_tr, false); //нужно добавить флаг вывода
            r_n := paramStr(2);
            c_n := paramStr(3);
            val_n := paramStr(4);
            
            //проверяяем есть ли такая веhшина
            //редачим файл матрицы
            //редачим индекс
            i := 0;
            if slice(paramStr(1), length(paramStr(1)) - 3, length(paramStr(1))) = 'smtr' then begin
                if find(mtr_tr, r_n, c_n) then begin
                    rewrite(f);
                    re := TRegExpr.Create('\s*' + r_n + '\s+' + c_n + '\s+');
                    while not eof(matrix) do begin
                        i := i + 1;
                        readln(matrixm, str);
                        writeln(f, str);
                        if re.Exec(str) then des_num := i;
                    end;
                    close(matrix);
                    close(f);
                    rewrite(matrix); 
                    reset(f);
                    for i := 1 to 
                end
                else begin
                end
            end
            else
            

        end
        
        else 
            writeln('there is no such file');
    end;
end.
//добавить вывод в 1 и 3