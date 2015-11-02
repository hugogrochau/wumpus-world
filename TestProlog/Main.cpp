#include <SWI-cpp.h>  //Include do swi-prolog
#include <iostream>

using namespace std;
 
int main(){
   
   char* argv[] = {"swipl.dll", "-s", "D:\\teste.pl",NULL };  //Argumentos para a inicialização do prolog, incluindo o caminho para o 
															  //arquivo do programa prolog que sera carregado (Ex: "D:\\teste.pl")
   
   PlEngine e(3,argv);                                        //Inicializa a engine prolog

   PlTermv av(2);                                             //Cria um termo PlTermv com tamanho 2 (dois paramentros)
   av[1] =  PlCompound("jose");                               //Define "jose" como o segundo parametro (av[1]) do termo

   PlQuery q("ancestral", av);                                //Realiza a consulta prolog do termo ancestral com os parametros av.
															  //Neste caso a sentenca sera: ancestral(X, jose), pois o parametro av[0] não 
															  //foi definido, dessa forma ele sera considerando uma variavel.

   while (q.next_solution())								  //Enquanto existirem solucoes, pergunta ao prolog quais são as proximas solucoes.
   {
		cout << (char*)av[0] << endl;						  //A resposta do prolog é retornada na variavel av[0], ou seja a variavel X da sentenca.
   }

   cin.get();
   
   return 1;
}