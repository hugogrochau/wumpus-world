:- dynamic idx/1.

getHead([H|_],H).
getHead(H,H).
getTail([_|T],T).
getTail(T,T).


initIndex :- delIndex,assert(idx(0)).
delIndex  :- (idx(I),retract(idx(I)),delIndex);true.
incIndex  :- idx(I),NI is I + 1, retract(idx(I)),assert(idx(NI)).
setIndex(V) :- delIndex,assert(idx(V)).
getIndex(I) :- idx(I);true.

tryFind(Element,LST) :- length(LST,LEN), ((LEN == 0,NI is LEN-1,setIndex(NI));getHead(LST,H),
	(Element==H;(getTail(LST,T),incIndex,tryFind(Element,T)))).

getIndexOf(Element,LST,IDX) :-   length(LST,LEN),initIndex,getIndex(I),((I>=LEN,IDX is -1,delIndex);
	getHead(LST,H),((H==Element,getIndex(I),IDX is I,delIndex);(
		getTail(LST,T),incIndex,tryFind(Element,T),idx(S),IDX is S,delIndex))).

getElement(LST,IDX,E) :- NIDX is IDX - 1, getHead(LST,H), ((NIDX == -1,E=H);
	getTail(LST,T),getElement(T,NIDX,E)).

lstAppend([],L,L).
lstAppend([HA|TA],LB,[HA|L3]) :- lstAppend(TA,LB,L3).

lstPushB(ELEM,L,[ELEM|L]).

lstPushE(ELEM,[],[ELEM]).
lstPushE(ELEM,[H|T],[H|L]) :- lstPushE(ELEM,T,L).

lstRemoveB([],[]).
lstRemoveB([_|T],T).

lstRemoveE([],[]).
lstRemoveE([_],[]).
lstRemoveE([H|T],[H|NT]) :- lstRemoveE(T,NT).

lstIsEmpty(L) :- length(L,Q),Q == 0.






