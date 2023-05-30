#
# Makefile for compiling Pascal program 
# which use some written in assembler code.
#
# Alexey Salnikov <salnikov@cs.msu.ru>
#

#
# Please write into the wariable PASCAL_MAIN_SOURCE the name of pascal file where
# located primary for program 
# begin
# ....
# ....
# end.
#
# 
# 
PASCAL_MAIN_SOURCE= print_rand_array.pas
PROGRAM=$(patsubst %.pas, %.exe, $(PASCAL_MAIN_SOURCE))

ASSEMBLER= wine ml
ASSEMBLER_FLAGS= /c /coff /Fl /I"Z:\\opt\\masm\\include"

LINKER= wine link
LINKER_FLAGS= /subsystem:console /LIBPATH:"Z:\\opt\\masm\\lib"

PASCAL= wine fpc
PASCAL_FLAGS= -g

ASM_SOURCES= $(wildcard *.asm)


ASM_SOURCES_UTF= $(patsubst %.asm, %.utf8.asm,  $(ASM_SOURCES))
OBJS=$(patsubst %.asm, %.obj, $(ASM_SOURCES))
LISTINGS=$(patsubst %.asm, %.lst, $(ASM_SOURCES))

all: $(PROGRAM)

$(PASCAL_MAIN_SOURCE): $(OBJS)

$(PROGRAM): $(PASCAL_MAIN_SOURCE)
	$(PASCAL)  $(PASCAL_FLAGS) -o$@ $(PASCAL_MAIN_SOURCE)

%.obj: %.asm
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) $^

%.utf8.asm: %.asm
	iconv -f cp1251 -t utf8 < $^ > $@

convert_to_utf: $(SOURCES_UTF)

clean:
	rm -f $(OBJS) $(LISTINGS) $(PROGRAM) $(ASM_SOURCES_UTF) *.ppu *.o

run:
	wine $(PROGRAM)

