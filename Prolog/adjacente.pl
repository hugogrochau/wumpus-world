/********************************
 * MUNDO WUMPOS
 * GUSTAVO MARTINS E HUGO GROCHAU
 * DATA : 02/11/2015
 * INTELIGENCIA ARTIFICIAL
 * ******************************/


/* Posicao inicial dos elementos (Sorteada aleatoriamente) */
obstaculo(1,1,abismo).
obstaculo(1,2,wumpos).
obstaculo(1,3,abismo).
obstaculo(1,4,morcego).
recompensa(1,5,ouro).

/* Predicado constantes(pre-definidos) */
adjacente(A,B,A+1,B).
adjacente(A,B,A-1,B).
adjacente(A,B,A,B+1).
adjacente(A,B,A,B-1).

/* Sensores */
parede(X,Y) :- X > 6;X < 1;Y < 1;Y > 6.
brisa(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,abismo).
fedor(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,wumpos).
grito(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,morcego).
brilho(X,Y) :- not(parede(X,Y)),recompensa(X,Y,ouro).
