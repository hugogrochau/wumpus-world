/********************************
 * MUNDO WUMPUS
 * GUSTAVO MARTINS, HUGO GROCHAU
 * DANIEL CARDOSO
 *
 * DATA : 03/11/2015
 * INTELIGENCIA ARTIFICIAL
 * VERSION 1.4a
 * ******************************/

/********************
 * ARQUIVOS EXTERNOS
 ********************/

:- include('minilstlib.pl').


/**************************************
 * DEFINICAO DOS PREDICADOS DINAMICOS
 **************************************/

:- dynamic
	   obstaculo/3,    %indica se possui um obstaculo em uma posicao X,Y : obstaculo(X,Y,OBS)
	                   %OBS(abismo,wumpus,morcego,falso)
	   recompensa/3,   %indica se possui uma recompensa em uma posicao X,Y : recompensa(X,Y,REC)  Rec(ouro ou false)
	   pontuacao/1,	   %indica a atual posicao do jogo : pontuacao(P)	P(valor inteiro)
	   posicao/2,      %indica a atual posicao do agente : posicao(X,Y)
	   direcao/1,      %indica a direcao para a qual o agente esta olhando : direcao(DIR)  Dir(norte,leste,oeste,sul)
	   estado/1,       %indica se o agente esta vivo ou morto : estado(EST)  Est(vivo ou morto)
           eJogo/1,        %indica se o jogo esta em execucao ou se chegou ao fim : eJogo(EST)  Est(execucao ou fim)
	   conhecimento/3, %indica o conhecimento que o agente tem
           qtdFlecha/1,    %indica a quantidade de flecha que o agente possui
	   acao/1.	   %indica as acoes que o agente executou

/****************
 * CONSTANTES
 ***************/

tamanhoMundo(6).     %Tamanho do mundo deve ser > 1
qtdWumpus(2).        %Quantidade de wumpus no jogo
qtdAbismo(4).        %Quantidade de abismos no jogo
qtdOuro(3).	     %Quantidade de ouro no jogo
qtdMorcego(2).       %Quantidade de morcegos no jogo
posicaoInicial(1,1). %Posicao inicial do jogador (Posicao Inicial = Saida do labirinto)


/********************
 * REGRAS ESTATICAS
 ********************/
adjacente(X,Y,A,B) :- (A is X+1,B is Y);
                      (A is X-1,B is Y);
		      (A is X,B is Y+1);
		      (A is X,B is Y-1).

/* Sensores */
parede(X,Y) :- tamanhoMundo(TAM),(X > TAM;X < 1;Y < 1;Y > TAM).
brisa(X,Y)  :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,abismo).
fedor(X,Y)  :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,wumpus).
grito(X,Y)  :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,morcego).
brilho(X,Y) :- not(parede(X,Y)),recompensa(X,Y,ouro).

/*******************************
 * FUNCOES INTERNAS DO PROGRAMA
 *******************************/

/* FUNCOES DE INICIALIZACAO */
iniciarValoresDefault :- posicaoInicial(X,Y),assert(pontuacao(0)),assert(posicao(X,Y)),
assert(direcao(norte)),assert(estado(vivo)),assert(eJogo(execucao)),assert(qtdFlecha(3)),
assert(acao([])),adicionaCVisitado(X,Y).

% Inicia o mundo com valores constantes
init :-   assert(obstaculo(1,1,abismo)),
	  assert(obstaculo(1,2,wumpus)),
	  assert(obstaculo(1,3,abismo)),
	  assert(obstaculo(1,4,morcego)),
	  assert(recompensa(1,5,ouro)),
	  iniciarValoresDefault.

% Gera obstaculos randomicamente // Ex : gerarObstaculos(3,abismo) ->
% Gera 3 abismos
gerarObstaculos(N,OBS) :-
	N > 0,
	tamanhoMundo(TAM),random_between(1,TAM,RX),random_between(1,TAM,RY),
	posicaoInicial(IX, IY),
	(
	    (
		    not(obstaculo(RX,RY,_)),not(temObstaculoEmVolta(RX,RY)), % Não tem um obstaculo na mesma posição ou com 2 ou menos de distancia dela
			not((OBS == abismo,recompensa(RX,RY,_))), % Se for um abismo, não tem recompensa nessa posicao
			RX \= IX,RY \= IY,not(adjacente(IX,IY,RX,RY)), % Não esta na, ou em volta da posição inicial
			assert(obstaculo(RX,RY,OBS)),
			NN is N - 1,
			gerarObstaculos(NN,OBS)
		);
		gerarObstaculos(N,OBS) % Se algumas das condições não forem realizadas, tente de novo.
	);
	true.

temObstaculoEmVolta(X,Y) :-
	XO is X-1,
	XL is X+1,
	YN is Y-1,
	YS is Y+1,
	(
	    obstaculo(XO,Y,_);
	    obstaculo(XL,Y,_);
	    obstaculo(X,YN,_);
	    obstaculo(X,YS,_)
	 ).

% Gera recompensas randomicamente
% Ex : gerarRecompensas(3,ouro) -> Gera 3 ouros
gerarRecompensas(N,REC) :-
	N > 0,tamanhoMundo(TAM),random_between(1,TAM,RX),random_between(1,TAM,RY),
	(
        (
	        not(obstaculo(RX,RY,abismo)), % Não pode ter um abismo na mesma posição
			not(recompensa(RX,RY,_)), % Não pode ter outra recompensa na mesma posição
	        not(posicaoInicial(RX,RY)), % Não pode estar na posição inicial
			assert(recompensa(RX,RY,REC)),
			NN is N - 1,
	        gerarRecompensas(NN,REC)
	   );
	gerarRecompensas(N,REC)
	);true.

% Gera um mundo randomico usando valores pre definidos
% (QTDOURO,QTDMORCEGO,QTDABISMO,QTDWUMPUS)
gerarMundoRandomico  :- qtdOuro(QOURO),qtdMorcego(QMORCEGO),qtdAbismo(QABISMO),qtdWumpus(QWUMPUS),
			gerarObstaculos(QABISMO,abismo),gerarObstaculos(QMORCEGO,morcego),gerarObstaculos(QWUMPUS,wumpus),
			gerarRecompensas(QOURO,ouro),iniciarValoresDefault,atualizarConhecimentos.

/* FUNCOES DE REINICIALIZACAO */
removeAcoes                 :- acao(L),retract(acao(L)),removeAcoes.
removeFlecha                :- qtdFlecha(Q),retract(qtdFlecha(Q)),removeFlecha.
removeObstaculo             :- obstaculo(X,Y,OBS),retract(obstaculo(X,Y,OBS)),removeObstaculo.
removeRecompensa            :- recompensa(X,Y,RE),retract(recompensa(X,Y,RE)),removeRecompensa.
removePontuacao             :- pontuacao(P),retract(pontuacao(P)),removePontuacao.
removeDirecao               :- direcao(D),retract(direcao(D)),removeDirecao.
removePosicao               :- posicao(X,Y),retract(posicao(X,Y)),removePosicao.
removeEstado                :- estado(E),retract(estado(E)),removeEstado.
removeEstadoJogo            :- eJogo(EST),retract(eJogo(EST)),removeEstadoJogo.
removeConhecimento          :- conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)),removeConhecimento.
removeConhecimento(CON)     :- conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)),removeConhecimento(CON).
removeConhecimentoAtt       :- conhecimento(X,Y,atualizado),retract(conhecimento(X,Y,atualizado)),removeConhecimentoAtt.
removeConhecimento(X,Y,CON) :- (conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)));true.
removeConhecimento(X,Y)     :- (conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)),removeConhecimento(X,Y));true.
removeTudo                  :- removeObstaculo;removeRecompensa;removePontuacao;removeDirecao;
		               removePosicao;removeEstado;removeEstadoJogo;removeConhecimento;removeFlecha;removeAcoes;
			       removeConhecimentoAtt.

% Reinicia o mundo usando valores constantes
reiniciarC	  :- removeTudo;init.
% Reinicia o mundo usando valores randomicos
reiniciarR        :- removeTudo;gerarMundoRandomico.

/* FUNCOES AUXILIARES */
%RETORNA AS COMPONENTES X E Y DE UMA LISTA [X,Y]
getXY([X|[Y|_]],X,Y).
%DECREMENTA A QUANTIDADE DE FLECHAS
decFlecha :- qtdFlecha(Q),NQ is Q-1,not(removeFlecha),assert(qtdFlecha(NQ)).
%DECREMENTA A PONTUACAO POR UM VALOR X
decPontuacao(X)   :- pontuacao(P),NP is P - X,retract(pontuacao(P)),assert(pontuacao(NP)).
%AUMENTA A PONTUACAO POR UM VALOR X
addPontuacao(X)   :- pontuacao(P),NP is P + X,retract(pontuacao(P)),assert(pontuacao(NP)).
%MATA O AGENTE
matarAgente	  :- removeEstado;assert(estado(morto)).
% CALCULA A NOVA PONTUACAO DE ACORDO COM A ATUAL POSICAO DO AGENTE(EX :
% SE ELE TA NUM ABISMO, ELE MORRE E PERDE 1000 PONTOS)
pontuacaoCondicao :- posicao(X,Y),(obstaculo(X,Y,OBS),
		    ((OBS==abismo,decPontuacao(1000),matarAgente);
		     (OBS==wumpus,qtdFlecha(FLECHA),FLECHA < 1,decPontuacao(1000),matarAgente)));true.

validaPosicao(X,Y) :- tamanhoMundo(T), X >= 1, X =< T, Y >= 1, Y =< T.
validaPosicao([X|[Y|_]]) :- validaPosicao(X,Y).
% COLOCA O AGENTE EM UMA POSICAO X,Y
setarPosicao(X,Y) :- removePosicao;assert(posicao(X,Y)).
% SETA O ESTADO DO JOGO PARA O VALOR DE EST. LEMBRE QUE EST(execucao ou
% fim)
setarEJogo(EST)	  :- removeEstadoJogo;assert(eJogo(EST)).
% COLOCA O AGENTE EM UMA POSICAO VALIDA RANDOMICA
randomizarPosicao :- tamanhoMundo(TAM),random_between(1,TAM,NX),random_between(1,TAM,NY),setarPosicao(NX,NY).
% RETORNA UM PONTO X,Y SIMULANDO O "ANDAR" DO AGENTE
simulaAndar(X,Y)  :- posicao(AX,AY),direcao(DIR),((DIR==norte,X is AX,Y is AY - 1);
						  (DIR==sul  ,X is AX,Y is AY + 1);
						  (DIR==leste,X is AX + 1, Y is AY);
						  (DIR==oeste,X is AX - 1, Y is AY)).

% Adiciona conhecimento a base de dados
adicionarConhecimento(X,Y,CON) :- (not(conhecimento(X,Y,CON)),assert(conhecimento(X,Y,CON)));true.

% Adicionar conhecimentos de uma certa posicao X,Y

adicionaCMorcego(X,Y)      :- (obstaculo(X,Y,morcego),adicionarConhecimento(X,Y,morcego));true.
adicionaCWumpus(X,Y)       :- (obstaculo(X,Y,wumpus),adicionarConhecimento(X,Y,wumpus));true.
adicionaCAbismo(X,Y)       :- (obstaculo(X,Y,abismo),adicionarConhecimento(X,Y,abismo));true.
adicionaCBrisa(X,Y)        :- (brisa(X,Y),adicionarConhecimento(X,Y,brisa));true.
adicionaCFedor(X,Y)        :- (fedor(X,Y),adicionarConhecimento(X,Y,fedor));true.
adicionaCBrilho(X,Y)       :- (brilho(X,Y),adicionarConhecimento(X,Y,brilho));true.
adicionaCGrito(X,Y)        :- (grito(X,Y),adicionarConhecimento(X,Y,grito));true.
adicionaCSemObstaculo(X,Y) :- not(obstaculo(X,Y,morcego);obstaculo(X,Y,wumpus);obstaculo(X,Y,abismo));true.
adicionaCVisitado(X,Y)     :- (adicionarConhecimento(X,Y,visitado));true.

temConhecimento(X,Y,CON)                 :- ((CON == fedor),fedor(X,Y));
					    ((CON == brisa),brisa(X,Y));
					    ((CON == grito),grito(X,Y)).
todosBlocosTemConhecimento([],_)         :- false.
todosBlocosTemConhecimento([ELEM],CON)   :- getXY(ELEM,X,Y),temConhecimento(X,Y,CON).
todosBlocosTemConhecimento([ELEM|T],CON) :- getXY(ELEM,X,Y),temConhecimento(X,Y,CON),todosBlocosTemConhecimento(T,CON).

adicionaNV(X,Y,QUERO,PRECISA)	     :- (blocosAdjacentesVisitados(X,Y,VISITADOS),
					 todosBlocosTemConhecimento(VISITADOS,PRECISA),
				         adicionarConhecimento(X,Y,QUERO));true.

adicionaConhecimentoVisitado(X,Y)    :- adicionaCMorcego(X,Y),adicionaCWumpus(X,Y),
			                adicionaCAbismo(X,Y),adicionaCBrisa(X,Y),
			                adicionaCFedor(X,Y),adicionaCBrilho(X,Y),
				        adicionaCGrito(X,Y).

adicionaConhecimentoNaoVisitado(X,Y) :-	adicionaNV(X,Y,wumpus,fedor),adicionaNV(X,Y,morcego,grito),
					adicionaNV(X,Y,abismo,brisa).

adicionaConhecimentos(X,Y) :- conhecimento(X,Y,visitado),adicionaConhecimentoVisitado(X,Y);
			      adicionaConhecimentoNaoVisitado(X,Y);true.

%Ou o bloco foi visitado, ou o bloco tem visinhos visitados

%FUNCOES INTERNAS PARA ATUALIZAR CONHECIMENTO
atualizaConhecimentoBloco([]).
atualizaConhecimentoBloco(ELEM)	:- (getXY(ELEM,X,Y), not(conhecimento(X,Y,atualizado)), adicionaConhecimentos(X,Y),
	                           adicionarConhecimento(X,Y,atualizado),
	                           blocosAdjacentesNaoAtualizados(X,Y,NATUALIZADOS),
	                           atualizaConhecimentoBlocos(NATUALIZADOS));(
                                   (getXY(ELEM,X,Y),blocosAdjacentesNaoAtualizados(X,Y,NATUALIZADOS),
				    atualizaConhecimentoBlocos(NATUALIZADOS));true).
atualizaConhecimentoBlocos([]).
atualizaConhecimentoBlocos([H|T])  :- atualizaConhecimentoBloco(H),atualizaConhecimentoBlocos(T).

removeConhecimentoMenosVisitado	   :- removeConhecimento(fedor);removeConhecimento(brisa);
				      removeConhecimento(brilho);removeConhecimento(grito);
				      removeConhecimento(wumpus);removeConhecimento(abismo);
				      removeConhecimento(morcego);removeConhecimento(ouro);
				      removeConhecimento(atualizado).

atualizarConhecimentos	           :- removeConhecimentoMenosVisitado;
				      (posicaoInicial(X,Y),adicionaConhecimentos(X,Y),
				      adicionarConhecimento(X,Y,atualizado),
				      blocosAdjacentesNaoAtualizados(X,Y,NATUALIZADOS),
				      atualizaConhecimentoBlocos(NATUALIZADOS),(removeConhecimentoAtt;true));
				      (removeConhecimentoAtt;true).

% TENTA MATAR UM OBSTACULO EM UMA POSICAO X,Y
matarObstaculo(X,Y) :- obstaculo(X,Y,E),(E \= abismo),retract(obstaculo(X,Y,E)),atom_concat(matar,E,ME),adicionaAcao(ME).

% Executa o efeito morcego. Caso tenha um morcego onde o jogador esta,
% ele vai para uma posicao randomica valida

efeitoMorcego(OPENLIST,NLIST) :-  posicao(X,Y), ((not(obstaculo(X,Y,morcego)),copyList(OPENLIST,NLIST)) ; (
				  randomizarPosicao,atualizarConhecimentos,pontuacaoCondicao, adicionaAcao(efeitoMorcego),				  adicionaBlocosAbertos(OPENLIST,MLIST),efeitoMorcego(MLIST,NLIST))).

blocoVisitado(ELEM) :- getXY(ELEM,X,Y),conhecimento(X,Y,visitado).

blocosAdjacentes(X,Y,NL) :- LX is X+1,OX is X-1,NY is Y-1,SY is Y+1,L = [[LX,Y],[OX,Y],[X,SY],[X,NY]],
	                    include(validaPosicao,L,NL).

blocosAdjacentesVisitados(X,Y,VISITADOS) :- blocosAdjacentes(X,Y,BLADJ),include(validaPosicao,BLADJ,LVALIDOS),
				            include(blocoVisitado,LVALIDOS,VISITADOS).

blocoNaoVisitado(ELEM) :- getXY(ELEM,X,Y),not(conhecimento(X,Y,visitado)).

blocosAdjacentesNaoVisitados(X,Y,NAOVISITADOS) :- blocosAdjacentes(X,Y,BLADJ),include(validaPosicao,BLADJ,LVALIDOS),
						  include(blocoNaoVisitado,LVALIDOS,NAOVISITADOS).

naoAtualizado(ELEM) :- getXY(ELEM,X,Y),not(conhecimento(X,Y,atualizado)).

blocosAdjacentesNaoAtualizados(X,Y,NAOATUALIZADOS) :- blocosAdjacentes(X,Y,ADJ),include(naoAtualizado,ADJ,NAOATUALIZADOS).

movimentosPossiveis(L) :- posicao(X,Y),blocosAdjacentes(X,Y,LA),include(quadradoPossivel,LA,L).

quadradoPossivel([X|[Y|_]]) :- qtdFlecha(Q),validaPosicao(X,Y),not(obstaculo(X,Y,abismo)),(Q > 0;not(obstaculo(X,Y,wumpus))).

/********************************
 * LOG DE ACOES
 ********************************/
adicionaAcao(NOME) :- posicao(X,Y), A = [X,Y,NOME], acao(AS),lstPushE(A,AS,NAS),(removeAcoes;assert(acao(NAS))).

/********************************
 * ACOES QUE O AGENTE PODE TOMAR
 ********************************/

% ATIRA UMA FLECHA NA POSICAO ATUAL
atirar :- posicao(X,Y),qtdFlecha(Q),Q > 0,matarObstaculo(X,Y),decPontuacao(10),decFlecha,atualizarConhecimentos,
	  adicionaAcao(atirar).

% TENTA PEGAR O OURO DA POSICAO ATUAL DO AGENTE
pegarOuro :- decPontuacao(1),posicao(X,Y),recompensa(X,Y,ouro),retract(recompensa(X,Y,ouro)),addPontuacao(1000),
	     atualizarConhecimentos,adicionaAcao(pegarOuro).

% ANDA NA DIRECAO EM QUE O AGENTE ESTA OLHANDO, SE FOR PAREDE O AGENTE
% NAO ANDA.
andar(X,Y) :- posicao(PX,PY),validaPosicao(X,Y),adjacente(X,Y,PX,PY),decPontuacao(1),setarPosicao(X,Y),
	      adicionaCVisitado(X,Y),pontuacaoCondicao,atualizarConhecimentos,adicionaAcao(andar).


% Gera uma lista de blocos(caminho) ate um certo ponto X,Y. Todos os
% blocos da lista são blocos que foram visitados. O ultimo bloco é o
% destino
% CAM     : caminho
%

copyList(L,R) :- accCp(L,R).
accCp([],[]).
accCp([H|T1],[H|T2]) :- accCp(T1,T2).

manhattan(BLOCO,DX,DY,MAN) :- getXY(BLOCO,BX,BY),CX is abs(BX - DX), CY is abs(BY - DY), MAN is CX + CY.
custo(BLOCO,DX,DY,CUSTO)   :- manhattan(BLOCO,DX,DY,MAN),
			     (((conhecimento(DX,DY,wumpus);conhecimento(DX,DY,morcego)),CUSTO is 10 + MAN) ; (
		              (conhecimento(DX,DY,abismo),CUSTO is 1000 + MAN)) ; (CUSTO is 1 + MAN)).

maisBarato([BLOCO],_,_,BLOCO).
maisBarato([A|T],DX,DY,BARATO)  :- maisBarato(T,DX,DY,B),custo(A,DX,DY,AC),
	                           custo(B,DX,DY,BC),(((AC =< BC),BARATO = A) ; (BARATO = B)).

caminhoValido([]).
caminhoValido([_]).
caminhoValido([H|T]) :- getXY(H,X,Y),getHead(T,H2),getXY(H2,BX,BY),adjacente(X,Y,BX,BY),caminhoValido(T).


tentaCaminho(ADJ,DX,DY,CAM,CAMINHO)	:-  maisBarato(ADJ,DX,DY,BL),
					    getXY(BL,X,Y),
					    (
						gerarCaminho(X,Y,DX,DY,CAM,NCAMINHO),caminhoValido(NCAMINHO) ;
					       (delete(ADJ,BL,NADJ),tentaCaminho(NADJ,DX,DY,CAM,NCAMINHO))
					     ),
					     copyList(NCAMINHO,CAMINHO).
gerarCaminho(OX,OY,OX,OY,_,[[OX,OY]]).
gerarCaminho(OX,OY,DX,DY,CAM,CAMINHO)   :- ((adjacente(OX,OY,DX,DY),CAMINHO = [[OX,OY],[DX,DY]]) ;
                                           (
	                                     blocosAdjacentesVisitados(OX,OY,ADJ),filtrar(CAM,ADJ,ADJVALIDO),
					     length(ADJVALIDO,LEN), LEN > 0, nth0(0,NCAM,[OX,OY],CAM),
					     tentaCaminho(ADJVALIDO,DX,DY,NCAM,NCAMINHO),
					     nth0(0,CAMINHO,[OX,OY],NCAMINHO)
					   )).




geraCaminho(OX,OY,DX,DY,CAMINHO) :- gerarCaminho(OX,OY,DX,DY,[],CAM),((nth0(_,CAM,[OX,OY]),delete(CAM,[OX,OY],CAMINHO));
				    copyList(CAM,CAMINHO)).



gerarCaminhoVisitado(X,Y,RESULT)   :- posicao(OX,OY),geraCaminho(OX,OY,X,Y,RESULT).

custoCaminho(BLOCO, CUSTO)         :- getXY(BLOCO,BX,BY),posicao(X,Y),custo([X,Y],BX,BY,CUSTO).
custoCaminho([BLOCO|BLOCOS],CUSTO) :- custoCaminho(BLOCOS,CBLS), getXY(BLOCO,BX,BY),
	                              posicao(X,Y),custo([X,Y],BX,BY,CBL),CUSTO is CBLS + CBL.

caminhoMaisBarato([BLOCO],BLOCO).
caminhoMaisBarato([A|T],BARATO) :- caminhoMaisBarato(T,B),custoCaminho(A,AC),custoCaminho(B,BC),
	                          (((AC =< BC),BARATO = A) ; (BARATO = B)).


juntarListas([],L2,L2).
juntarListas([H|T],L2,[H|L3])	      :- juntarListas(T,L2,L3).

filtrar([],ELEM,ELEM).
filtrar(OPENLIST,[ELEM],ATUALIZADO)   :- ((not(nth0(_,OPENLIST,ELEM)),copyList([ELEM],ATUALIZADO)) ;
					  copyList([],ATUALIZADO)).

filtrar(OPENLIST,[H|T],ATUALIZADO)    :- filtrar(OPENLIST,T,L), ((not(nth0(_,OPENLIST,H)),
								juntarListas(L,[H],ATUALIZADO));
								(copyList(L,ATUALIZADO))).

adicionaBlocosAbertos(OPENLIST,NLIST) :- ((posicao(X,Y),blocosAdjacentesNaoVisitados(X,Y,NAOVISITADOS),
	                                   filtrar(OPENLIST,NAOVISITADOS,CANDIDATOS),
					   juntarListas(OPENLIST,CANDIDATOS,NLIST));copyList(OPENLIST,NLIST)).

andarPorCaminho([BLOCO])   :- getXY(BLOCO,X,Y),andar(X,Y).
andarPorCaminho([BLOCO|T]) :- getXY(BLOCO,X,Y),andar(X,Y),andarPorCaminho(T).

execAcaoAtual(OPENLIST,NLIST) :- posicao(X,Y), (
				(obstaculo(X,Y,wumpus),format('wumpus\n'),atirar,copyList(OPENLIST,NLIST))  ;
				(obstaculo(X,Y,morcego),format('morcego\n'),((atirar,copyList(OPENLIST,NLIST));
				efeitoMorcego(OPENLIST,NLIST))) ;
				(obstaculo(X,Y,abismo),format('abismo\n'),copyList(OPENLIST,NLIST));
				(true,copyList(OPENLIST,NLIST))                                 ),
			        ((recompensa(X,Y,ouro),pegarOuro) ; true).

execBusca(OPENLIST) :- ((not(recompensa(_,_,ouro))) ; ( adicionaBlocosAbertos(OPENLIST,NLIST),
		       length(NLIST,LEN),LEN > 0, caminhoMaisBarato(NLIST,BLOCO), getXY(BLOCO,BX,BY),
		       delete(NLIST, BLOCO, MNLIST),
		       gerarCaminhoVisitado(BX,BY,CAMINHO),andarPorCaminho(CAMINHO), execAcaoAtual(MNLIST,MNLIST2),
		       execBusca(MNLIST2)) ).
buscaOuro	    :- execBusca([]),gerarCaminhoVisitado(1,1,CAMINHO),andarPorCaminho(CAMINHO).

