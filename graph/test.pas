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

function pos_d_arr(el: array of char; ar: arr): integer;
var i, j, res: integer;
begin
    pos_d_arr := -1;
    for i := 0 to length(ar) - 1 do 
    begin
        res := -1;
        if min_of_int(length(el), length(ar[i])) <> 0 then 
            res := i;
            for j := 0 to min_of_int(length(el), length(ar[i])) - 1 do begin
                if el[j] <> ar[i, j] then res := -1
            end;
        if res <> -1 then pos_d_arr := res;
    end;
end;


var i: integer; q, a: mas; ar: array[1..4] of integer := (1, 2, 3, 4);
begin
    //write(length(ar));
    //ar := (1; 2; 3; 4);
    write(ar[2]);
end.
{

type link = ^edge;

edge = record 
    namec: integer;
    city_to: link;
    tr_name: integer;
    tc: real; mc: real; 
end;

var 
    graph: array of edge; cities, types_transport: array of array of char;}