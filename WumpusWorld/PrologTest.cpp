#define _CRT_SECURE_NO_WARNINGS

#include <SWI-cpp.h>
#include <iostream>
#include <windows.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <vector>

#define WORLD_LEN 6

#define PROGRAM_PATH "[PATH_TO_PROJECT]\\WumposWorld\\Prolog\\wumpus.pl"

using namespace std;

typedef struct point {
	int x;
	int y;
} Point;

typedef enum entity {
	OURO,
	WUMPUS,
	ABISMO,
	MORCEGO,
	VAZIO
} Entity;

typedef struct wumpusState {
	Entity grid[WORLD_LEN][WORLD_LEN][2];
	int score;
	Point agentPosition;

} WumpusState;

enum ActionType {
	ANDAR,
	ATIRAR,
	MATAR_WUMPUS,
	MATAR_MORCEGO,
	EFEITO_MORCEGO,
	PEGAR_OURO
};

typedef struct action {
	Point location;
	ActionType actionType;
} Action;


static void fillInitialState(WumpusState *state);
static void executeSearch();
static void initializeWorld();
static void restartWorld();
static void removeAll();
static void printWorld(WumpusState *state);
static void printColor(char *, int);
static void fillObstacles(WumpusState *state);
static void fillRewards (WumpusState *state);
static void updateAgentPosition(WumpusState *state);
static void getActions(vector<Action> &);
static ActionType getActionTypeFromString(char * actionString);
static void updateStateWithAction(WumpusState *state, Action action);
static int getScore();


int main(void) {
	char* argv[] = {"swipl.dll", "-s", PROGRAM_PATH};

	PlEngine e(3, argv);

	WumpusState *state = new WumpusState();
	fillInitialState(state);
	printf("Initial state:\n");
	printWorld(state);
	putchar('\n');

	executeSearch();

	vector<Action> actions;
	getActions(actions);

	for (vector<Action>::iterator list_iter = actions.begin(); list_iter != actions.end(); list_iter++) {
		printf("Press any key to execute next action\n");
		_getch();
		updateStateWithAction(state, *list_iter);
		printWorld(state);
		putchar('\n');
	}

	return 0;
}

static void fillInitialState(WumpusState *state) {
	initializeWorld();
	state->agentPosition;
	state->grid[WORLD_LEN][WORLD_LEN][2];
	for (int i = 0; i < WORLD_LEN; i++) {
		for (int j = 0; j < WORLD_LEN; j++) {
			state->grid[i][j][0] = VAZIO;
			state->grid[i][j][1] = VAZIO;
		}
	}

	state->score = getScore();
	fillObstacles(state);
	fillRewards(state);
	updateAgentPosition(state);
}

static void executeSearch() {
	PlCall("buscaOuro", NULL);
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

static void fillObstacles(WumpusState *state) {
	PlTermv av(3);
	PlQuery q("obstaculo", av);
	int x, y;
	char *obs;
	Entity obstacle;
	while (q.next_solution()) {
		obs = av[2];
		if (strcmp("abismo", obs) == 0) {
			obstacle = ABISMO;
		}
		else if (strcmp("wumpus", obs) == 0) {
			obstacle = WUMPUS;
		}
		else if (strcmp("morcego", obs) == 0) {
			obstacle = MORCEGO;
		}
		x = (int)av[0] - 1;
		y = (int)av[1] - 1;
		state->grid[x][y][0] = obstacle;
	}
}

static void fillRewards(WumpusState *state) {
	PlTermv av(3);
	PlQuery q("recompensa", av);
	int x, y;
	Entity reward = OURO;
	while (q.next_solution()) {
		x = (int) av[0] - 1;
		y = (int) av[1] - 1;
		state->grid[x][y][1] = reward;
	}
}

static void updateAgentPosition(WumpusState *state) {
	PlTermv av(2);
	PlQuery q("posicao", av);
	int x, y;
	while (q.next_solution()) {
		x = (int) av[0];
		y = (int) av[1];
	}
	Point p;
	p.x = x;
	p.y = y;
	state->agentPosition = p;
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

static void getActions(vector<Action> &actions) {
	PlTermv av(1);
	PlQuery q("acao", av);

	PlTerm actionsTerm(av[0]);
	q.next_solution();
	PlTail actionsArray(actionsTerm);

	PlTerm actionTerm;
	
	while (actionsArray.next(actionTerm)) { /* for each action */
		PlTail actionArray(actionTerm);
		PlTerm actionPart;
		Action action;
		Point p;
		for (int i = 0; actionArray.next(actionPart); i++) {
			switch (i) {
			case 0:
				p.x = (int) actionPart;
				break;
			case 1:
				p.y = (int) actionPart;
				break;
			case 2:
				action.actionType = getActionTypeFromString((char *) actionPart);
				break;
			}
		}
		action.location = p;
		actions.push_back(action);
	}
}

/* TODO */
static ActionType getActionTypeFromString(char * actionString) {
	if (strcmp(actionString, "andar") == 0) {
		return ANDAR;
	}
	if (strcmp(actionString, "atirar") == 0) {
		return ATIRAR;
	}
	if (strcmp(actionString, "matarwumpus") == 0) {
		return MATAR_WUMPUS;
	}
	if (strcmp(actionString, "matarmorcego") == 0) {
		return MATAR_MORCEGO;
	}
	if (strcmp(actionString, "efeitoMorcego") == 0) {
		return EFEITO_MORCEGO;
	}
	if (strcmp(actionString, "pegarOuro") == 0) {
		return PEGAR_OURO;
	}
}

static void updateStateWithAction(WumpusState *state, Action action) {
	switch (action.actionType) {
	case ANDAR:
		state->score -= 1;
	case EFEITO_MORCEGO:
		state->agentPosition.x = action.location.x;
		state->agentPosition.y = action.location.y;
		break;
	case ATIRAR:
		state->score -= 10;
		break;
	case MATAR_WUMPUS:
		state->grid[action.location.x - 1][action.location.y - 1][0] = VAZIO;
		break;
	case MATAR_MORCEGO:
		state->grid[action.location.x - 1][action.location.y - 1][0] = VAZIO;
		break;
	case PEGAR_OURO:
		state->grid[action.location.x - 1][action.location.y - 1][1] = VAZIO;
		state->score += 1000;
		break;
	}
};

static void printWorld(WumpusState *state) {
	for (int y = 0; y < WORLD_LEN; y++) {
		for (int x = 0; x < WORLD_LEN; x++) {
			int posx = state->agentPosition.x;
			int posy = state->agentPosition.y;
			if (x == posx - 1 && y == posy - 1) {
				printColor("AG ", FOREGROUND_BLUE | FOREGROUND_RED);
				continue;
			}
			char entityString[] = "XX ";
			int color = 0;
			switch (state->grid[x][y][0]) {
			case ABISMO:
				entityString[0] = 'A';
				color = FOREGROUND_GREEN;
				break;
			case WUMPUS:
				entityString[0] = 'W';
				color = FOREGROUND_RED;
				break;
			case MORCEGO:
				entityString[0] = 'M';
				color = FOREGROUND_BLUE;
				break;
			default:
				entityString[0] = 'X';
				color = FOREGROUND_BLUE | FOREGROUND_RED | FOREGROUND_GREEN;
			}
			if (state->grid[x][y][1] == OURO) {
				entityString[1] = 'O';
				color = FOREGROUND_RED | FOREGROUND_GREEN;
			}
			printColor(entityString, color);
		}
		printf("\n");
	}
	printf("Score: %d", state->score);
	printf("\n");
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

