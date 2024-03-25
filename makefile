buffalo: 	buf_lexical_analyzer.l buf_parser.y buf_header.h
			bison -d buf_parser.y
			flex -o buf.lex.c buf_lexical_analyzer.l
			cc -o $@ buf_parser.tab.c buf.lex.c buf_routines.c -lm
