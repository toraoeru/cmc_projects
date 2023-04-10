unit Utils_;
Interface
const SPACE_ST = '        ';
function slice(str: string; a, b: integer): string;
function in_str(ch: char; str: string): boolean;

Implementation


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

function in_str(ch: char; str: string): boolean;
var i: integer;
begin
    in_str := false;
    for i := 1 to length(str) do begin
        if ch = str[i] then in_str := true;
    end;
end;
end.