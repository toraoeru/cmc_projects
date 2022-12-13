program shit;

{$mode objfpc}

uses sysutils;

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



function get_num_in_ab(a, b: integer): integer;
var c: char;
begin
    write('>'); read(c); readln();
    while (a > StrToInt(c)) or (b < strtoint(c)) do begin
        writeln('wrong input');
        write('>'); read(c); readln();
    end;
    get_num_in_ab := StrToInt(c);
end;

var i, k: integer; q, a: mas; 
begin

    i := 0; 
    while (i < 5) and (k <> -1) do begin
    
        try
            read(k);
        except
            on EInOutError do 
                writeln('wrong input');
            else 
                k := 100;
        end;
        write(k);
    end;
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