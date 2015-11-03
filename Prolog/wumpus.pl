/********************************
 * MUNDO WUMPOS
 * GUSTAVO MARTINS E HUGO GROCHAU
 * DATA : 02/11/2015
 * INTELIGENCIA ARTIFICIAL
 * VERSION 1.1a
 * ******************************/

/**************************************
 * DEFINICAO DOS PREDICADOS DINAMICOS
 **************************************/

:- dynamic
	   obstaculo/3,    %indica se possui um obstaculo em uma posicao X,Y : obstaculo(X,Y,OBS)
	                   %OBS(abismo,wumpos,morcego,falso)
	   recompensa/3,   %indica se possui uma recompensa em uma posicao X,Y : recompensa(X,Y,REC)  Rec(ouro ou false)
	   pontuacao/1,	   %indica a atual posicao do jogo : pontuacao(P)	P(valor inteiro)
	   posicao/2,      %indica a atual posicao do agente : posicao(X,Y)
	   direcao/1,      %indica a direcao para a qual o agente esta olhando : direcao(DIR)  Dir(norte,leste,oeste,sul)
	   estado/1,       %indica se o agente esta vivo ou morto : estado(EST)  Est(vivo ou morto)
           eJogo/1,        %indica se o jogo esta em execucao ou se chegou ao fim : eJogo(EST)  Est(execucao ou fim)
	   conhecimento/3. %indica o conhecimento que o agente tem

/****************
 * CONSTANTES
 ***************/

tamanhoMundo(6).     %Tamanho do mundo deve ser > 1
qtdWumpos(2).        %Quantidade de wumpos no jogo
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
brisa(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,abismo).
fedor(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,wumpos).
grito(X,Y) :- not(parede(X,Y)),adjacente(X,Y,Z,W),obstaculo(Z,W,morcego).
brilho(X,Y):- not(parede(X,Y)),recompensa(X,Y,ouro).

/*******************************
 * FUNCOES INTERNAS DO PROGRAMA
 *******************************/

/* FUNCOES DE INICIALIZACAO */
iniciarValoresDefault :- posicaoInicial(X,Y),assert(pontuacao(0)),assert(posicao(X,Y)),assert(direcao(norte)),
			 assert(estado(vivo)),assert(eJogo(execucao)).

% Inicia o mundo com valores constantes
init :-   assert(obstaculo(1,1,abismo)),
	  assert(obstaculo(1,2,wumpos)),
	  assert(obstaculo(1,3,abismo)),
	  assert(obstaculo(1,4,morcego)),
	  assert(recompensa(1,5,ouro)),
	  iniciarValoresDefault.

% Gera obstaculos randomicamente // Ex : gerarObstaculos(3,abismo) ->
% Gera 3 abismos
gerarObstaculos(N,OBS) :-  (N > 0,tamanhoMundo(TAM),random_between(1,TAM,RX),random_between(1,TAM,RY), (
			   (
		              not(obstaculo(RX,RY,_)),not(recompensa(RX,RY,_)),not(posicaoInicial(RX,RY)),
			      assert(obstaculo(RX,RY,OBS)),NN is N - 1,gerarObstaculos(NN,OBS)
		           );gerarObstaculos(N,OBS));true).

% Gera recompensas randomicamente // Ex : gerarRecompensas(3,ouro) ->
% Gera 3 ouros
gerarRecompensas(N,REC) :-  (N > 0,tamanhoMundo(TAM),random_between(1,TAM,RX),random_between(1,TAM,RY), (
			    (
		               not(obstaculo(RX,RY,_)),not(recompensa(RX,RY,_)),not(posicaoInicial(RX,RY)),
			       assert(recompensa(RX,RY,REC)),NN is N - 1,gerarRecompensas(NN,REC)
			    );gerarRecompensas(N,REC));true).

% Gera um mundo randomico usando valores pre definidos
% (QTDOURO,QTDMORCEGO,QTDABISMO,QTDWUMPOS)
gerarMundoRandomico  :- qtdOuro(QOURO),qtdMorcego(QMORCEGO),qtdAbismo(QABISMO),qtdWumpos(QWUMPOS),
			gerarObstaculos(QABISMO,abismo),gerarObstaculos(QMORCEGO,morcego),gerarObstaculos(QWUMPOS,wumpos),
			gerarRecompensas(QOURO,ouro),iniciarValoresDefault,atualizarConhecimento.

/* FUNCOES DE REINICIALIZACAO */
removeObstaculo             :- obstaculo(X,Y,OBS),retract(obstaculo(X,Y,OBS)),removeObstaculo.
removeRecompensa            :- recompensa(X,Y,RE),retract(recompensa(X,Y,RE)),removeRecompensa.
removePontuacao             :- pontuacao(P),retract(pontuacao(P)),removePontuacao.
removeDirecao               :- direcao(D),retract(direcao(D)),removeDirecao.
removePosicao               :- posicao(X,Y),retract(posicao(X,Y)),removePosicao.
removeEstado                :- estado(E),retract(estado(E)),removeEstado.
removeEstadoJogo            :- eJogo(EST),retract(eJogo(EST)),removeEstadoJogo.
removeConhecimento          :- conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)),removeConhecimento.
removeConhecimento(X,Y,CON) :- (conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)));true.
removeConhecimento(X,Y)     :- (conhecimento(X,Y,CON),retract(conhecimento(X,Y,CON)),removeConhecimento(X,Y));true.
removeTudo                  :- removeObstaculo;removeRecompensa;removePontuacao;removeDirecao;
		               removePosicao;removeEstado;removeEstadoJogo;removeConhecimento.
% Reinicia o mundo usando valores constantes
reiniciarC	  :- removeTudo;init.
% Reinicia o mundo usando valores randomicos
reiniciarR        :- removeTudo;gerarMundoRandomico.

/* FUNCOES AUXILIARES */

%DECREMENTA A PONTUACAO POR UM VALOR X
decPontuacao(X)   :- pontuacao(P),NP is P - X,retract(pontuacao(P)),assert(pontuacao(NP)).
%AUMENTA A PONTUACAO POR UM VALOR X
addPontuacao(X)   :- pontuacao(P),NP is P + X,retract(pontuacao(P)),assert(pontuacao(NP)).
%MATA O AGENTE
matar             :- removeEstado;assert(estado(morto)).
% CALCULA A NOVA PONTUACAO DE ACORDO COM A ATUAL POSICAO DO AGENTE(EX :
% SE ELE TA NUM ABISMO, ELE MORRE E PERDE 1000 PONTOS)
pontuacaoCondicao :- posicao(X,Y),(obstaculo(X,Y,OBS),
		    ((OBS==abismo,decPontuacao(1000),matar);
		     (OBS==wumpos,decPontuacao(1000),matar)));true.
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
adicionarConhecimento(X,Y,CON) :- not(conhecimento(X,Y,CON)),assert(conhecimento(X,Y,CON)).

% Adicionar conhecimentos de uma certa posicao X,Y
adicionaCMorcego(X,Y) :- (obstaculo(X,Y,morcego),assert(conhecimento(X,Y,morcego)));true.
adicionaCWumpos(X,Y)  :- (obstaculo(X,Y,wumpos),assert(conhecimento(X,Y,wumpos)));true.
adicionaCAbismo(X,Y)  :- (obstaculo(X,Y,abismo),assert(conhecimento(X,Y,abismo)));true.
adicionaCBrisa(X,Y)   :- (brisa(X,Y),assert(conhecimento(X,Y,brisa)));true.
adicionaCFedor(X,Y)   :- (fedor(X,Y),assert(conhecimento(X,Y,fedor)));true.
adicionaCBrilho(X,Y)  :- (brilho(X,Y),assert(conhecimento(X,Y,brilho)));true.
adicionaConhecimentos(X,Y) :- adicionaCMorcego(X,Y),adicionaCWumpos(X,Y),
			      adicionaCAbismo(X,Y),adicionaCBrisa(X,Y),
			      adicionaCFedor(X,Y),adicionaCBrilho(X,Y).

atualizarConhecimento      :- posicao(X,Y),removeConhecimento(X,Y),adicionaConhecimentos(X,Y).
atualizarConhecimento(X,Y) :- removeConhecimento(X,Y),adicionaConhecimentos(X,Y).

% TENTA MATAR O WUMPOS EM UMA POSICAO X,Y
killw(X,Y) :- obstaculo(X,Y,wumpos),retract(obstaculo(X,Y,wumpos)).

% Executa o efeito morcego. Caso tenha um morcego onde o jogador esta,
% ele vai para uma posicao randomica valida
efeitoMorcego :- (posicao(X,Y),obstaculo(X,Y,morcego),randomizarPosicao,atualizarConhecimento,pontuacaoCondicao,
		  efeitoMorcego);true.

/********************************
 * ACOES QUE O AGENTE PODE TOMAR
 ********************************/

% ATIRA UMA FLECHA NA DIRECAO EM QUE O AGENTE ESTA OLHANDO (APENAS 1
% QUADRADO A FRENTE)
atirar     :- decPontuacao(1),decPontuacao(10),simulaAndar(X,Y),killw(X,Y),atualizarConhecimento.

% TENTA PEGAR O OURO DA POSICAO ATUAL DO AGENTE
getg       :- decPontuacao(1),posicao(X,Y),recompensa(X,Y,ouro),retract(recompensa(X,Y,ouro)),addPontuacao(1000),
	      atualizarConhecimento.

% ANDA NA DIRECAO EM QUE O AGENTE ESTA OLHANDO, SE FOR PAREDE O AGENTE
% NAO ANDA.
andar	   :- decPontuacao(1),simulaAndar(X,Y),not(parede(X,Y)),setarPosicao(X,Y),pontuacaoCondicao,atualizarConhecimento,
	      efeitoMorcego.

% ANDA N VEZES
andar(N)   :- (N > 0,andar,NN is N-1,andar(NN));true.

% VIRA A DIRECAO EM QUE O AGENTE ESTA OLHANDO NO SENTIDO HORARIO DO
% RELOGIO
virar      :- decPontuacao(1),direcao(D),((D==norte, ND = leste);
					  (D==leste, ND = sul);
			                  (D==sul  , ND = oeste);
			                  (D==oeste, ND = norte)),
			                  retract(direcao(D)), assert(direcao(ND)).

% VIRA O AGENTE N VEZES
virar(N)  :- ((N > 0),virar,NN is N - 1,virar(NN));true.
