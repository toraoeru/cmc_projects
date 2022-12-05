program oem;
 
 
procedure oem2win(var s:string);
var i :Integer;
    c :char;
begin
    for i := 1 to Length(s) do begin
        c := s[i];
        case c of
            #$80..#$9F, #$A0..#$AF: inc(Byte(s[i]), $40);
            
            #$E0..#$EF: inc(Byte(s[i]), $10);
            
            #$F0: s[i] := #$A8;
            #$F1: s[i] := #$B8;
        end;
    end;
end;
 
var s1, s2:string; i: integer;
begin
    read(s1);
    s2 := s1;
    for i := 1 to length(s1) do
        writeln(ord(s1[i]));
    writeln('original: ', s1);
    oem2win(s2);
    writeln('oem2win: ', s2);
    readln;
end.