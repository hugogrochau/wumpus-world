/********************************
 * MUNDO WUMPOS
 * GUSTAVO MARTINS E HUGO GROCHAU
 * DATA : 02/11/2015
 * INTELIGENCIA ARTIFICIAL
 * ******************************/

/* Sintaxe :   :- (nomePredicado)/(numero de elementos) */
:- dynamic ([obstaculo/3,recompensa/3]).

/* Predicado constantes(pre-definidos) */
adjacente(X,Y,A,B) :- A is X+1,B is Y;
                      A is X-1,B is Y;
		      A is X,B is Y+1;
		      A is X,B is Y-1.


/* Functions */

/* Funcao de inicializacao */
init() :- assert(obstaculo(1,1,abismo)),
	  assert(obstaculo(1,2,wumposvivo)),
	  assert(obstaculo(1,3,abismo)),
	  assert(obstaculo(1,4,morcego)),
	  assert(recompensa(1,5,ouro)).

/* Sensores */
parede(X,Y) :- X > 6;X < 1;Y < 1;Y > 6.
brisa(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,abismo).
fedor(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,wumpos).
grito(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,morcego).
brilho(X,Y) :- not(parede(X,Y)),recompensa(X,Y,ouro).
killw(X,Y) :- obstaculo(X,Y,wumposvivo),retract(obstaculo(X,Y,wumposvivo)),assert(obstaculo(X,Y,wumposmorto)).

