grammar fhirpath;

// Grammar rules

//version without precedence and left-recursion
//expression: term (righthand)*;
//righthand: op term | '.' function;
//term: '(' expression ')' | fpconst | predicate;
//op: LOGIC | COMP | '*' | '/' | '+' | '-' | '|' | '&';

prog: line (line)*;
line: ID ( '(' predicate ')') ':' expr '\r'? '\n';

expr:
        expr ('*' | '/') expr |
        expr ('+' | '-') expr |
        expr ('|' | '&') expr |
        expr COMP expr |
        expr LOGIC expr |
        '(' expr ')' |
        predicate |
        fpconst;

predicate : (root_spec | item) ('.' item)* ;

item: element recurse? | function | axis_spec | '(' expr ')';
element: ID CHOICE?;
recurse: '*';

axis_spec: '*' | '**' ;
root_spec: '$context' | '$resource' | '$parent';

function: ID '(' param_list? ')';
param_list: expr (',' expr)*;

fpconst: STRING |
       '-'? NUMBER |
       BOOL |
       CONST;


// Lexical rules

LOGIC: 'and' | 'or' | 'xor';
COMP: '=' | '~' | '!=' | '!~' | '>' | '<' | '<=' | '>=' | 'in';
BOOL: 'true' | 'false';

CONST: '%' ALPHANUM (ALPHANUM | [\-.])*;

STRING: '"' (ESC | ~["\\])* '"' |           // " delineated string
        '\'' (ESC | ~[\'\\])* '\'';         // ' delineated string

fragment ESC: '\\' (["'\\/bfnrt] | UNICODE);    // allow \", \', \\, \/, \b, etc. and \uXXX
fragment UNICODE: 'u' HEX HEX HEX HEX;
fragment HEX: [0-9a-fA-F];

NUMBER: INT '.' [0-9]+ EXP? |
        INT EXP |
        INT;

fragment INT: '0' | [1-9][0-9]*;
fragment EXP: [Ee] [+\-]? INT;


CHOICE: '[x]';
ID: ALPHA ALPHANUM* ;

fragment ALPHA: [a-zA-Z];
fragment ALPHANUM: ALPHA | [0-9];

WS: [ \r\n\t]+ -> skip;

COMMENT: '{' (~'}')* '}' -> skip;