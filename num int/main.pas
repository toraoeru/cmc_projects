program shit;

uses crt, ptcGraph;

type 
    tfunc = function (arg1: double) : double;

function f1(x: double) double;
begin
    f1 := 3*(0.5/(x+1) + 1);
end;

function f2(x: double) double;
begin
    f2 := 2*x - 9.5;
end;

function f3(x: double) double;
begin
    f3 := 5/x;
end;

procedure root(f, g: tfunc; a, b, epsl, var x: double): double;
begin
end;

function integral(f: tfunc; a, b, eps2: double): double;
begin 
end;
var
    x, y, x0, y0, k, vga,vgahi:integer;
begin
    initgraph(vga,vgahi,'c:\prg\bp\bgi');
    line(20,240,620,240);
    line(320,20,320,400);
    X0:=320;
    Y0:=240;
    k:=50;
    for X:=-320 to 320 do
    begin
        y:=trunc(k*sin(x/k));
        PutPixel(x0+x,y0-y,4);
    end;
    OutTextXY (50,440,'Grafic y=sin x');
    readln;
    closegraph;
end.