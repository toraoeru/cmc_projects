program shit;

uses {$IFDEF UNIX} cthreads, {$ENDIF}ptcGraph, SysUtils;

CONST
    deltaX = 0.01;
    Inf = 3.4e38;
    eps = 0.001;

type 
    tfunc = function (arg1: double) : double;

var x12, x13, x23: double;

function f1(x: double): double;
begin
    f1 := 3*(0.5/(x+1) + 1);
end;

function df1(x: double): double;
begin
    df1 := -3/2/(x+1)/(x+1);
end;

function f2(x: double): double;
begin
    f2 := 2.5*x -19.5;
end;

function df2(x: double): double;
begin
    df2 := 2.5;
end;

function f3(x: double): double;
begin
    f3 := 5/x;
end;

function df3(x: double): double;
begin
    df3 := -5/x/x;
end;

function sub_f(f, g: tfunc; x: double): double;
begin
    sub_f := f(x) - g(x);
end;

function find_initial(f, g: tfunc): double;
var step: double;
begin
    step := 1;
    while sub_f(f, g, step)*sub_f(f, g, -step) >= 0 do 
        step := step + 1;
    find_initial := step;
end;

function find_m(a1, a2, a3: double; flag: boolean): double;
var m:double;
begin
    m := a1;
    if flag then begin
        if a2 > m then 
            m := a2;
        if a3 > m then 
            m := a3;
    end
    else begin
        if a2 < m then 
            m := a2;
        if a3 < m then 
            m := a3;
    end;
    find_m := m;
end;

procedure root(f, g, df, dg: tfunc; x0, eps1: double; var x: double);
var x1: double;
begin
    x1 := x0 - sub_f(f, g, x0) / sub_f(df, dg, x0);
    while (abs(x1 - x0) > eps1) do begin
        x0 := x1;
        x1 := x1 - sub_f(f, g,x1) / sub_f(df, dg,x1); 
    end;
    x := x1;
end;

function int_sim(f, g: tfunc; a, b: double; n: integer): double;
var sum, step, x: double;
begin 
    sum := 0.0;
    step := (b - a) / n;
    x := a + step / 2;
    while (x < b - step / 2) do begin
        sum := sum + step / 6 * (sub_f(f, g, x - step / 2) + 4 * sub_f(f, g, x) + sub_f(f, g, x + step / 2));
        x := x + step;
    end;
    int_sim := sum;
end;

function integral(f, g: tfunc; a, b, eps2: double): double;
var d, s: double; n: integer;
begin 
    d := 1;
    n := 1;
    while (abs(d) > eps2) do begin
        writeln('step ', round(ln(n)/ln(2)) + 1);
        d := (int_sim(f, g, a, b, n * 2) - int_sim(f, g, a, b, n)) / 15;
        n := n * 2;
        if (n > exp(15*ln(2))) then break;
    end;
    writeln();
    s := abs(int_sim(f, g, a, b, n));
    integral := s + d / 2;
end;


procedure PlotGraph (func: tfunc; x0, y0, CanvasWidth, CanvasHeight, color: Integer; a, b: Double; flag: boolean);
    var
        K: Double; 
        Cx, Cy: Integer; 

    function PixelCoordX (xx: Double): Integer;
    begin
        PixelCoordX := x0 + Cx + Round( xx * K)
    end;

    function PixelCoordY (yy: Double): Integer;
    begin
        PixelCoordY := y0 + Cy - Round( yy * K )
    end;

    procedure PlotAxes;
        const h = 0.2 / 3.0;
        var r: Double;
    begin
        Line(x0, y0 + Cy, x0 + CanvasWidth - 1, y0 + Cy);
        Line(x0 + Cx, y0, x0 + Cx, y0 + CanvasHeight - 1);
 
        r := Trunc(a);
        while r <= Trunc(b) DO
        begin
            Line(PixelCoordX (r), PixelCoordY (0), PixelCoordX (r), PixelCoordY (-h));
            OutTextXY(PixelCoordX (r - h), PixelCoordY (-h), IntToStr(Round(r)));
            Line(PixelCoordX (0), PixelCoordY (r), PixelCoordX (-h), PixelCoordY (r));
            IF r <> 0 then
                OutTextXY(PixelCoordX (h), PixelCoordY (r + h), IntToStr(Round(r)));
            r := r + 1.0;
        end;
    end;
 
    var
        x, y: Double;
        px, py: Integer;
begin
    IF b <= a then Exit;
    Cx := CanvasWidth DIV 2;
    Cy := CanvasHeight DIV 2;
    
    K := 1.0 * CanvasWidth / (b - a);
 
    SetColor(Blue);
    PlotAxes;

    SetColor(color);
    x := a; y := func(x);
    px := PixelCoordX(x);
    py := PixelCoordY(y);
 
    MoveTo(px, py);
 
    while x <= b DO
    begin
        if flag and (x > find_m(x12, x23, x13, false)) and (x < find_m(x12, x23, x13, true) )then
            Line(PixelCoordX(x), PixelCoordY(func(x)), PixelCoordX(x), PixelCoordY(find_m(f3(x), f2(x), -1000, true)));
        y := func(x); 
        px := PixelCoordX(x);
        py := PixelCoordY(y);
 
        IF y < Inf then
            LineTo (px, py);
 
        x := x + deltaX
    end;
end;
 
var
    gd, gm: smallint;
begin
    GD := VGA; GM := VGAHi; InitGraph(GD, GM, '');
    root(@f1, @f2, @df1, @df2, find_initial(@f1, @f2), eps, x12);
    root(@f1, @f3, @df1, @df3, find_initial(@f1, @f3), eps, x13);
    root(@f2, @f3, @df2, @df3, find_initial(@f2, @f3), eps, x23);
    write('s = ');
    if (x12 <= x13) and (x13 <= x23) then
        writeln(abs(integral(@f1, @f2, x12, x13, eps)) + abs(integral(@f2, @f3, x13, x23, eps)):1:10)
    else if (x12 <= x23) and (x23 <= x13) then
        writeln(abs(integral(@f1, @f2, x12, x23, eps)) + abs(integral(@f1, @f3, x23, x13, eps)):1:10)
    else if (x13 <= x23) and (x23 <= x12) then
        writeln(abs(integral(@f1, @f3, x13, x23, eps)) + abs(integral(@f1, @f2, x23, x12, eps)):1:10)
    else if (x13 <= x12) and (x12 <= x23) then
        writeln(abs(integral(@f1, @f3, x13, x12, eps)) + abs(integral(@f2, @f3, x12, x23, eps)):1:10)
    else if (x23 <= x13) and (x13 <= x12) then
        writeln(abs(integral(@f2, @f3, x23, x13, eps)) + abs(integral(@f1, @f2, x13, x12, eps)):1:10)
    else if (x23 <= x12) and (x12 <= x13) then
        writeln(abs(integral(@f2, @f3, x23, x12, eps)) + abs(integral(@f1, @f3, x12, x13, eps)):1:10);

    IF GraphResult <> grOK then Exit;
 
    PlotGraph(@f1, 0, 0, GetMaxX(), GetMaxY(), 5, -10.0, 10.0, true);
    OutTextXY (20, 20,'y=3/2/(x+1)+3');
    PlotGraph(@f2, 0, 0, GetMaxX(), GetMaxY(), 10, -10.0, 10.0, false);
    OutTextXY (20, 40,'y=2.5x-9.5');
    PlotGraph(@f3, 0, 0, GetMaxX(), GetMaxY(), 14, -10.0, 10.0, false);
    OutTextXY (20, 60,'y=5/x');
    readln;
    CloseGraph;
end.//форматирование, доробатать вывод по шагам, условие на штриховку