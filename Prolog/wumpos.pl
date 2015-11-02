/********************************
 * MUNDO WUMPOS
 * GUSTAVO MARTINS E HUGO GROCHAU
 * DATA : 02/11/2015
 * INTELIGENCIA ARTIFICIAL
 * ******************************/

/* Sintaxe :   :- (nomePredicado)/(numero de elementos) */
:- dynamic ([obstaculo/3,recompensa/3,pontuacao/1,posicao/2,direcao/1,estado/1]).

/* Predicado constantes(pre-definidos) */
adjacente(X,Y,A,B) :- A is X+1,B is Y;
                      A is X-1,B is Y;
		      A is X,B is Y+1;
		      A is X,B is Y-1.


/* Functions */

/* Funcao de inicializacao */
init :-   assert(obstaculo(1,1,abismo)),
	  assert(obstaculo(1,2,wumpos)),
	  assert(obstaculo(1,3,abismo)),
	  assert(obstaculo(1,4,morcego)),
	  assert(recompensa(1,5,ouro)),
	  assert(pontuacao(0)),
	  assert(posicao(1,1)),
	  assert(direcao(norte)),
	  assert(estado(vivo)).

/*FUNCOES DE REMOVER SEMPRE RETORNAM FALSE!!!*/
removeObstaculo   :- obstaculo(X,Y,OBS),retract(obstaculo(X,Y,OBS)),removeObstaculo.
removeRecompensa  :- recompensa(X,Y,RE),retract(obstaculo(X,Y,RE)),removeRecompensa.
removePontuacao   :- pontuacao(P),retract(pontuacao(P)),removePontuacao.
removeDirecao     :- direcao(D),retract(direcao(D)),removeDirecao.
removePosicao     :- posicao(X,Y),retract(posicao(X,Y)),removePosicao.
removeEstado      :- estado(E),retract(estado(E)),removeEstado.
removeTudo        :- removeObstaculo;removeRecompensa;removePontuacao;removeDirecao;
		     removePosicao;removeEstado.
reiniciar         :- removeTudo;init.

/* Sensores */
parede(X,Y) :- X > 6;X < 1;Y < 1;Y > 6.
brisa(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,abismo).
fedor(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,wumpos).
grito(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,morcego).
brilho(X,Y):- not(parede(X,Y)),recompensa(X,Y,ouro).

/* Acoes */
decPontuacao(X)   :- pontuacao(P),NP is P - X,retract(pontuacao(P)),assert(pontuacao(NP)).
addPontuacao(X)   :- pontuacao(P),NP is P + X,retract(pontuacao(P)),assert(pontuacao(NP)).
matar             :- removeEstado;assert(estado(morto)).
pontuacaoCondicao :- posicao(X,Y),obstaculo(X,Y,OBS),
		    ((OBS==abismo,decPontuacao(1000),matar);
		     (OBS==wumpos,decPontuacao(1000),matar)).

killw(X,Y) :- obstaculo(X,Y,wumpos),retract(obstaculo(X,Y,wumpos)),decPontuacao(1).

getg       :- posicao(X,Y),recompensa(X,Y,ouro),retract(recompensa(X,Y,ouro)),addPontuacao(1000),decPontuacao(1).

andar	   :- direcao(D),posicao(X,Y),((D==norte,NY is Y-1,NX is X);
	                               (D==sul  ,NY is Y+1,NX is X);
				       (D==leste,NY is Y,NX is X+1);
				       (D==oeste,NY is Y,NX is X-1)),
				       retract(posicao(X,Y)),assert(posicao(NX,NY)),decPontuacao(1),pontuacaoCondicao.

virar      :- direcao(D), ((D==norte, ND = leste);
			   (D==leste, ND = sul);
			   (D==sul  , ND = oeste);
			   (D==oeste, ND = norte)),
			   retract(direcao(D)), assert(direcao(ND)),decPontuacao(1).
