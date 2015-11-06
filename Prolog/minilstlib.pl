:- dynamic index/1.

getHead([H|_],H).
getHead(H,H).
getTail([_|T],T).
getTail(T,T).


initIndex :- delIndex,assert(index(0)).
delIndex  :- (index(I),retract(index(I)),delIndex);true.
incIndex  :- index(I),NI is I + 1, retract(index(I)),assert(index(NI)).
setIndex(V) :- delIndex,assert(index(V)).
getIndex(I) :- index(I);true.

tryFind(Element,LST) :- length(LST,LEN), ((LEN == 0,NI is LEN-1,setIndex(NI));getHead(LST,H),
	(Element==H;(getTail(LST,T),incIndex,tryFind(Element,T)))).

getIndexOf(Element,LST,IDX) :-   length(LST,LEN),initIndex,getIndex(I),((I>=LEN,IDX is -1,delIndex);
	getHead(LST,H),((H==Element,getIndex(I),IDX is I,delIndex);(
		getTail(LST,T),incIndex,tryFind(Element,T),index(S),IDX is S,delIndex))).

getElement(LST,IDX,E) :- NIDX is IDX - 1, getHead(LST,H), ((NIDX == -1,E=H);
	getTail(LST,T),getElement(T,NIDX,E)).

lstAppend([],L,L).
lstAppend([HA|TA],LB,[HA|L3]) :- lstAppend(TA,LB,L3).
lstPushB(ELEM,L,[ELEM|L]).
lstPushE(ELEM,[],[ELEM]).
lstPushE(ELEM,[H|T],[H|L]) :- lstPushE(ELEM,T,L).
