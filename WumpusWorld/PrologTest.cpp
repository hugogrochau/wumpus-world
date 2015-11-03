#define _CRT_SECURE_NO_WARNINGS
#include <SWI-cpp.h>
#include <iostream>
#include <windows.h>
#include <stdlib.h>
#include <conio.h>
#include "programpath.h"

#define WORLD_LEN 6

using namespace std;

enum Obstacle {abismo = FOREGROUND_GREEN, morcego = FOREGROUND_BLUE, wumpos = FOREGROUND_RED};
enum Reward {ouro = FOREGROUND_BLUE|FOREGROUND_RED };
enum Direction {NORTH = 0, EAST = 1, SOUTH = 2, WEST = 3};

static void initializeWorld();
static void restartWorld();
static void removeAll();
static void printWorld();
static void clearWorld();
static void getDirection();
static void printColor(char *, int);

/* Agent actions */
static void walk();
static void turn();
static void turn(int);
static void shoot();

static void getObstacle();
static void getReward();
static void getAgentPosition();
static int getScore();


char world[WORLD_LEN][WORLD_LEN];
int posx = 1;
int posy = 1;
Direction direction = NORTH;

int main(void) {
	char* argv[] = {"swipl.dll", "-s", PROGRAM_PATH};  //Argumentos para a inicialização do prolog, incluindo o caminho para o 
													   //arquivo do programa prolog que sera carregado (Ex: "D:\\teste.pl")

	PlEngine e(3, argv);
	restartWorld();
	turn();
	turn();
	for (int i = 0; i < 3; i++) {
		printWorld();
		walk();
		printf("\n");
	}
	_getch();
	return 1;
}

static void clearWorld() {
	for (int i = 0; i < WORLD_LEN; i++)
		for (int j = 0; j < WORLD_LEN; j++)
			world[j][i] = 0;
}

static void initializeWorld() {
	PlCall("gerarMundoRandomico", NULL);
}

static void restartWorld() {
	PlCall("reiniciarR", NULL);
}

static void removeAll() {
	PlCall("removeTudo", NULL);
}

static void getDirection() {
	PlTermv av(1);
	PlQuery q("direcao", av);
	char *dir;
	while (q.next_solution()) {
		dir = (char *)av[0];
		printf("Direcao : %s\n", dir);
		if (strcmp(dir, "norte") == 0) 
			direction = NORTH;
		else if (strcmp(dir, "leste") == 0)
			direction = EAST;
		else if (strcmp(dir, "sul") == 0)
			direction = SOUTH;
		else if (strcmp(dir, "oeste") == 0)
			direction = WEST;
	}
}

static void printWorld() {
	clearWorld();
	getReward();
	getObstacle();
	getDirection();
	for (int y = 0; y < WORLD_LEN; y++) {
		for (int x = 0; x < WORLD_LEN; x++) {

			if (x == posx - 1 && y == posy - 1) {
				char d[2];
				d[1] = '\0';
				switch (direction) {
				case NORTH: d[0] = 'N';
					break;
				case EAST: d[0] = 'E';
					break;
				case SOUTH: d[0] = 'S';
					break;
				case WEST: d[0] = 'W';
					break;
				default: d[0] = 'G';
				}
				printColor(d, FOREGROUND_RED | FOREGROUND_GREEN);
				printf(" ");
				continue;
			}

			switch (world[y][x]) {
			case abismo  : printColor("A ", world[y][x]);
				break;
			case wumpos  : printColor("W ", world[y][x]);
				break;
			case morcego : printColor("M ", world[y][x]);
				break;
			case ouro    : printColor("O ", world[y][x]);
				break;
			default      : printf("X ");
			}
		}
		printf("\n");
	}
	printf("Score: %d", getScore());
	printf("\n");

}

static void getObstacle() {
	PlTermv av(3);
	PlQuery q("obstaculo", av);
	int x, y;
	char *obs;
	Obstacle color;
	while (q.next_solution()) {
		obs = av[2];
		if (strcmp("abismo", obs) == 0) {
			color = abismo;
		}
		else if (strcmp("wumpos", obs) == 0) {
			color = wumpos;
		}
		else if (strcmp("morcego", obs) == 0) {
			color = morcego;
		}
		x = (int)av[0] - 1;
		y = (int)av[1] - 1;
		world[y][x] = color;
	}
}

static void getReward() {
	PlTermv av(3);
	PlQuery q("recompensa", av);
	int x, y;
	Reward color = ouro;
	while (q.next_solution()) {
		x = (int) av[0] - 1;
		y = (int) av[1] - 1;
		world[y][x] = color;
	}
}

static void getAgentPosition() {
	PlTermv av(2);
	PlQuery q("posicao", av);
	while (q.next_solution()) {
		posx = (int) av[0];
		posy = (int) av[1];
	}
}

static int getScore() {
	int score = 0;
	PlTermv av(1);
	PlQuery q("pontuacao", av);
	while (q.next_solution()) {
		score = (int) av[0];
	}
	return score;
}

static void printColor(char *txt, int color) {
	HANDLE console;
	CONSOLE_SCREEN_BUFFER_INFO info;
	console = GetStdHandle(STD_OUTPUT_HANDLE);
	GetConsoleScreenBufferInfo(console, &info);
	SetConsoleTextAttribute(console, color);
	printf("%s", txt);
	SetConsoleTextAttribute(console, info.wAttributes);
}

static void walk() {
	PlCall("andar", NULL);
	getAgentPosition();
}

static void turn() {
	PlCall("virar", NULL);
}

static void turn(int n) {
	PlTermv av(1);
	av[0] = n;
	PlCall("virar", av);
}

static void shoot() {
	PlCall("atirar", NULL);
}
