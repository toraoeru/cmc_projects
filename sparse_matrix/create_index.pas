program ihatemylife;

const 
    SP_FLAG = 'sparse_matrix';
    DEN_FLAG = 'dence_matrix';

type
    tree_node_t = record
        node_number: longword;
        row, column: longword;
        element: double;
        left, right: ^ tree_node;
    end;

    states = (form_exp, form_ent, size_exp, row_ent, coln_ent, sp_cont, den_cont);
    readin_nums_st = (num_exp, int_part, frac_part, eoln_exp, new_line_exp);

var 
    matrix, indx: text;


function slice(str: string; a, b: integer): string;
var res: string;
begin
    res := '';
    while a <= b do begin
        res := res + str[a];
        a := a + 1;
    end;
    slice := res;
end;

procedure edit_index();

procedure add(var tree: tree_node_t; node_num, row, col: longword; el: double);
begin
   if Tree = Nil
   Then Begin 
	    New(Tree);
	    Tree^.L := Nil;
	    Tree^.R := Nil;
	    Tree^.Inf := x
	End
   Else If x < Tree^.inf
	Then InsRec(Tree^.L, x)
	Else InsRec(Tree^.R, x)
end;

procedure create_index();
var 
    format, state: states; row_n, coln_n, i, row, col, step: integer;
    c: char; is_error: boolean; format_name: string;
    num_readin_st: readin_nums_st; val: double;
begin
    state := form_exp;
    is_error := false;
    i := 2;
    while (not eof()) and (not is_error) do begin
        case state of
            form_exp:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if (c = '#') or eoln(matrix) then readln(matrix)
                        else if c = SP_FLAG[1] then begin 
                            state := form_ent;
                            form_name := SP_FLAG;
                        end
                        else if c = DEN_FLAG[1] then begin
                            state := form_ent;
                            form_name := DEN_FLAG;
                        end
                        else is_error := true;
                    end
                    else readln(matrix);
                end;
            form_ent:
                begin
                    if i <= length(form_name) then begin
                        if eoln(matrix) then is_error := true
                        else begin
                            read(marix, c);
                            if c <> form_name[i] then is_error := true;
                        end;
                        i := i + 1;
                    end
                    else state := size_ent;
                end;
            size_ent:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if not (c in ' 1234567890') then is_error := true
                        else if c in '1234567890' then begin
                            if row_n = 0 then begin
                                row_n := strtoint(c);
                                state := row_ent;
                            end
                            else begin 
                                coln_n := strtoint(c);
                                state := coln_ent;
                            end;
                        end;
                    end
                    else is_error := true;
                end;
            row_ent:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if c = ' ' then state := size_ent
                        else if c in '1234567890' then row_n := row_n*10 + strtoint(c)
                        else is_error := true;
                    end
                    else is_error := true;
                end;
            coln_ent:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if c in '1234567890' then coln_n := coln_n*10 + strtoint(c)
                        else begin
                            readln(matrix);
                            if form_name = DEN_FLAG then state := den_cont
                            else state := sp_cont;
                        end;
                    end
                    else if eoln(matrix) and (coln_n <> 0) then begin
                            readln(matrix);
                            if form_name = DEN_FLAG then state := den_cont
                            else state := sp_cont;
                    end
                    else is_error := true;
                end;
            sp_cont:
                begin
                //while...

                    case num_readin_st of 
                        new_line_exp:
                            begin
                                if eoln(matrix) then readln(matrix)
                                else num_readin_st := num_exp;
                            end;
                        num_exp:
                            begin
                                read(matrix, c);
                                if c in '1234567890' then begin
                                    state := int_part;
                                    step := step + 1;
                                    if row = 0 then row := strtoint(c)
                                    else if col = 0 col := strtoint(c)
                                    else val := strtoint(c);
                                end
                                else if c <> ' ' then is_error := true;
                            end;
                        int_part:
                            begin
                                if not eoln() then begin
                                    read(matrix, c);
                                    if c in '1234567890' then begin
                                        if step = 1 then row := row + strtoint(c)
                                        else if step = 2 then col := col + strtoint(c)
                                        else val := val + strtoint(c);
                                    end
                                    else if (c = '.') and (step = 3) then state := frac_part
                                    else if (c = ' ') and (step = 3) then begin
                                       //если это корень
                                       add(tr_matrix, num_edge, row, col, val) ;
                                       //обнулить все
                                       readln(matrix);
                                    end
                                    else if c = ' ' then state := num_exp
                                end
                                else if step = 3 then begin
                                    //если это корень
                                    add(tr_matrix, num_edge, row, col, val) ;
                                    //обнулить все
                                    readln(matrix)
                                end
                                else is_error := true;
                            end;
                        frac_part: 
                            begin
                                
                            end;
                    end;
                end;
        end;
    end;

end;


begin
    if paramCount() = 0 then 
        writeln('specify the file with the matrix')
    else begin
        assign(matrix, paramStr(1));
        {$I-} reset(matrix); {$I+}

        if IOresult = 0 then begin
            assign(indx, slice(paramStr(1), length(paramStr(1)) - 3, length(paramStr(1))) + 'dot');
            {$I-} reset(indx); {$I+}
            if IOresult = 0 then edit_index()
            else create_index();
        end
        else 
            writeln('there is no such file');
    end;

end.