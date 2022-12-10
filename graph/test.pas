program shit;

type mas = array of char;
type arr = array of mas;

function min_of_int(n1, n2: integer): integer;
begin
    if n1 > n2 then min_of_int := n2
    else min_of_int := n1;
end;


function in_arr(el: mas; ar: arr): boolean;
var i, j, flag: integer;
begin
    in_arr := false;
    for i := 0 to length(ar) - 1 do 
    begin
        flag := 0;
        if el = ar[i] then flag := 1;
        if flag = 1 then in_arr := true;
    end;
end;

function in_ar(el: array of char; ar: arr): boolean;
var i, j, flag: integer;
begin
    in_ar := false;
    for i := 0 to length(ar) - 1 do 
    begin
        flag := 0;
        if min_of_int(length(el), length(ar[i])) <> 0 then 
            flag := 1;
            for j := 0 to min_of_int(length(el), length(ar[i])) - 1 do begin
                writeln(el[j], ' ', ar[i, j]);
                if el[j] <> ar[i, j] then flag := 0
            end;
        if flag = 1 then in_ar := true;
    end;
end;


var ar: array of array of char; i: integer; q, a: mas;
begin
    q := 'Mos';
    a := 'Fas';
    SetLength(ar, 10);
    ar[1] := 'Tver';
    ar[2] := 'bologoe';
    //write(length(ar));
    write(in_arr('Tver', ar));
end.