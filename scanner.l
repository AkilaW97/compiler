%{
	#include <stdio.h>
	#include <string.h>
	
	//Structure for symbol table
	struct symboltable
	{
		char name[100];
		char type[100];
		int length;
		int lineno;
	}ST[1007];


	// This function calculates a hash value for a given string.
	// It's used to determine the index where a string should be stored in the symbol table.
	int hash(char *str)
	{
	    int value = 0; // Initialize hash value to 0.
	    
	    // Iterate over each character of the string.
	    for(int i = 0 ; i < strlen(str) ; i++)
	    {
		// For each character, update the hash value based on its ASCII value.
		// The hash value is a combination of previous value multiplied by 10 and 
		// the current character's ASCII value offset by 'A'.
		value = 10*value + (str[i] - 'A');
		
		// Apply modulo to ensure the hash value stays within the range of the symbol table size.
		value = value % 1007;
		
		// Adjust if the value is negative to ensure a positive index.
		while(value < 0)
		    value = value + 1007;
	    }
	    // Return the final hash value.
	    return value;
	}
	

	// Checks if a string exists in the symbol table.
	int lookupST(char *str)
	{
	    // Calculate the hash value for the given string.
	    int value = hash(str);

	    // Check if the position indicated by the hash value is empty.
	    if(ST[value].length == 0)
	    {
		// If empty, the string is not in the symbol table.
		return 0;
	    }
	    else if(strcmp(ST[value].name,str)==0)
	    {
		// If the string at the position matches the input, it is found in the symbol table.
		return 1;
	    }
	    else
	    {
		// If there's a collision (different string at the hash value), search for the string.
		for(int i = value + 1 ; i!=value ; i = (i+1)%1007)
		{
		    // Check if the current position in the symbol table matches the input string.
		    if(strcmp(ST[i].name,str)==0)
		    {
		        // If a match is found, return 1 indicating the string exists in the symbol table.
		        return 1;
		    }
		}
		// If the string is not found after searching the entire table, return 0.
		return 0;
	    }
	}

	
	// Inserts a new symbol into the symbol table.
	void insertST(char *str1, char *str2, int lineno)
	{
	    // First, check if the symbol is already in the table.
	    if(lookupST(str1))
	    {
		// If it exists, no need to insert, simply return.
		return;
	    }
	    else
	    {
		// Calculate the hash value for the symbol.
		int value = hash(str1);

		// Check if the calculated position in the symbol table is empty.
		if(ST[value].length == 0)
		{
		    // If empty, insert the symbol at this position.
		    strcpy(ST[value].name,str1); // Copy the symbol's name.
		    strcpy(ST[value].type,str2); // Copy the symbol's type.
		    ST[value].length = strlen(str1); // Set the length of the symbol.
		    ST[value].lineno = lineno; // Set the line number where the symbol was found.
		    return; // Successfully inserted, so return.
		}

		// If the position is not empty (collision occurred), find the next empty slot.
		int pos = 0;

		// Loop to find the next available empty position.
		for (int i = value + 1 ; i!=value ; i = (i+1)%1007)
		{
		    // Check if the current position is empty.
		    if(ST[i].length == 0)
		    {
		        // If empty, set pos to the current index and break out of the loop.
		        pos = i;
		        break;
		    }
		}

		// Insert the symbol at the found empty position.
		strcpy(ST[pos].name,str1); // Copy the symbol's name.
		strcpy(ST[pos].type,str2); // Copy the symbol's type.
		ST[pos].length = strlen(str1); // Set the length of the symbol.
		ST[pos].lineno = lineno; // Set the line number where the symbol was found.
	    }
	}
	

	// Prints the contents of the symbol table.
	void printST()
	{
	    // Iterate through each slot in the symbol table.
	    for(int i = 0 ; i < 1007 ; i++)
	    {
		// Check if the current slot is empty (indicated by length being 0).
		if(ST[i].length == 0)
		{
		    // If empty, skip to the next slot.
		    continue;
		}

		// If the slot is not empty, print the stored information.
		// This includes the symbol's name, type, and the line number where it was found.
		printf("%s\t%s\t- Line: %d\n",ST[i].name, ST[i].type, ST[i].lineno);
	    }
	}

%}

DEF "define"
INC "include"
operator [[<][=]|[>][=]|[=][=]|[!][=]|[>]|[<]|[\|][\|]|[&][&]|[\!]|[=]|[\+][\+]|[\-][\-]|[\+]|[\-]|[\*]|[\/]|[\%]|[&]|[\|]|[<][<]|[>]]


%%
\n   {yylineno++;} // helps in tracking the current line number

\/\/(.*) {}	//match single-line comments
	
			
([#][" "]*({INC})[ ]*([<]?)([A-Za-z]+)[.]?([A-Za-z]*)([>]?))/["\n"|\/|" "|"\t"] {printf("%s \t-Preprocessor statement\n",yytext);} //Matches preprocessor directives
	
[ \n\t] ;

([#][" "]*({DEF})[" "]*([A-Za-z]+)(" ")*[0-9]+)/["\n"|\/|" "|"\t"] {printf("%s \t-Definition\n",yytext);} //Matches definition

\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/  {} //match multi-line comments

, {printf("%s \t- comma separator\n", yytext); insertST(yytext,"- COMMA ", yylineno);}

; {printf("%s \t- semicolon\n", yytext); insertST(yytext,"- SEMICOLON", yylineno);}

\} {printf("%s \t- closing curly brackets\n", yytext); insertST(yytext,"- RBRACE", yylineno);}

\] {printf("%s \t- closing square brackets\n", yytext); insertST(yytext,"- RBRACKET", yylineno);}

\( {printf("%s \t- opening brackets\n", yytext); insertST(yytext,"- LPAREN", yylineno);}

\) {printf("%s \t- closing brackets\n", yytext); insertST(yytext,"- RPAREN", yylineno);}

\. {printf("%s \t- dot\n", yytext); insertST(yytext,"- DOT", yylineno);}

\[ {printf("%s \t- opening square brackets\n", yytext); insertST(yytext,"- LBRACKET", yylineno);}

\: {printf("%s \t- colon\n", yytext); insertST(yytext,"- COLON ", yylineno);}

\\ {printf("%s \t- forward slash\n", yytext); insertST(yytext,"- FORWARD_SLASH", yylineno); }

\{ {printf("%s \t- opening curly brackets\n", yytext); insertST(yytext,"- LBRACE", yylineno);}

attribute|read|default|printf|class|void|scanf|integer|return|double|long|constructor|float|isa|for|self|char|if|int|localvar|then|return|private|else|function|public|while|write|while|main\b {printf("%s \t- Keyword\n", yytext); insertST(yytext, "- Keyword", yylineno);}

\"[^\n]*\"/[;|,|\)] {printf("%s \t- String\n", yytext); insertST(yytext,"- String", yylineno);}

\'[A-Z|a-z]\'/[;|,|\)|:] {printf("%s \t- Character Constant\n", yytext); insertST(yytext,"- Character", yylineno);}

[a-z|A-Z]([a-z|A-Z]|[0-9])*/\[ {printf("%s \t- Array Identifier\n", yytext); insertST(yytext, "- Identifier", yylineno);}

{operator}/[a-z]|[0-9]|;|" "|[A-Z]|\(|\"|\'|\)|\n|\t {printf("%s \t- Operator\n", yytext); insertST(yytext, "- Operator", yylineno);} 

[1-9][0-9]*|0   { printf("%s \t- Integer Constant\n", yytext); insertST(yytext, "- intLit", yylineno); }

[0-9]+\.[0-9]+   { printf("%s \t- Floating Constant\n", yytext); insertST(yytext, "- FloatLit", yylineno); }

[A-Za-z_][A-Za-z_0-9]*   { printf("%s \t- Identifier\n", yytext); insertST(yytext, "- Identifier", yylineno); }

%%

int main(int argc , char **argv){

       printf("---------------------------------------\n");

	int i;
	for (i=0;i<1007;i++){
		ST[i].length=0;
	}

	yyin = fopen(argv[1],"r");
	yylex();
	
	printf("---------------------------------------\n");
	
	printf("\n\n\n\t***Symbol Table***\n");
	printf("\n\n---------------------------------------\n");
	printf("Symbol\t    Token\t    Line\n");
	printf("---------------------------------------\n");
	printST();
	printf("---------------------------------------\n");
}

int yywrap(){
    return 1;
}
