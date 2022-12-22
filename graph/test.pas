program shit;

const NUM = 5;

var res, sign, i, n, n_even, l_str, summ: integer; c: char; flag: boolean;
begin
    {read(c);
    res := 0;
    sign := 1;
    if c = '-' then sign := -1
    else res := ord(c) - ord('0');
    i := 0;
    while not eoln() do begin
        read(c); 
        res := res + round(exp(ln(10) * i)) * (ord(c) - ord('0'));
        i := i + 1;
    end;
    write(res);
    if sign = -1 then write('-');
    }
    {read(n);
    res := 0;
    sign := 1;
    if n < 0 then sign := -1;
    while n <> 0 do begin//1234 -> 1 + 20
        res := res * 10 + n mod 10;
        n := n div 10;
    end;
    write(res);
    if sign = -1 then write('-');}
    {n_even := 0; l_str := 0;
    repeat
        if not eoln() then begin
            read(c);
            if c <> '.' then l_str := l_str + 1
            else if not odd(l_str) then  n_even := n_even + 1;
        end
        else begin
            if not odd(l_str) then n_even := n_even + 1;
            l_str := 0; readln();
        end;
    until c = '.';
    writeln(n_even);}
    flag := false;
    for i := 1 to NUM do begin
        read(n);
        if n = 0 then begin
            summ := 0; flag := true;
        end
        else if flag and odd(n) then begin
            summ := summ + n;
        end;
    end;
    write(summ);
end.