import 'package:flutter/material.dart';
import 'package:tic_tac_toe/game_logic.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String activePlayer = "X";
  bool gameOver = false;
  int turn = 0;
  String result = "";
  bool isSwitched = false;
  Game game = Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(
                children: [
                  ...firstBlock(), // ... to extract widgets from a list of widgets
                  _expanded(context),
                  ...lastBlock(), // ... to extract widgets from a list of widgets
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...firstBlock(),
                        const SizedBox(
                          height: 15,
                        ),
                        ...lastBlock(),
                      ],
                    ),
                  ),
                  _expanded(context),
                ],
              ),
      ),
    );
  }

  List<Widget> firstBlock() {
    return [
      SwitchListTile.adaptive(
        title: const Text(
          "Turn ON/OFF two players",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
        activeTrackColor: Theme.of(context).shadowColor,
        value: isSwitched,
        onChanged: (newVal) {
          setState(() {
            isSwitched = newVal;
          });
        },
      ),
      Text(
        "It's $activePlayer turn".toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 50,
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> lastBlock() {
    return [
      Text(
        result.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 50,
        ),
        textAlign: TextAlign.center,
      ),
      ElevatedButton.icon(
        onPressed: () {
          setState(() {
            // we need to return all values to initial state
            activePlayer = "X";
            gameOver = false;
            turn = 0;
            result = "";
            Player.playerX = [];
            Player.playerO = [];
          });
        },
        icon: const Icon(Icons.replay),
        label: const Text("Repeat the game"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).splashColor,
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  Expanded _expanded(BuildContext context) {
    return Expanded(
      child: GridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
        // ration between length and width .. 2 means 2:1
        //children: [],
        children: List.generate(
          9,
          (index) => InkWell(
            onTap: gameOver ? null : () => _onTap(index),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).shadowColor,
              ),
              child: Center(
                child: Text(
                  Player.playerX.contains(index)
                      ? "X"
                      : Player.playerO.contains(index)
                          ? "O"
                          : "",
                  style: TextStyle(
                    color: Player.playerX.contains(index)
                        ? Colors.blue
                        : Colors.pink,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onTap(int index) async {
    if ((Player.playerX.isEmpty || !Player.playerX.contains(index)) &&
        (Player.playerO.isEmpty || !Player.playerO.contains(index))) {
      game.playGame(index, activePlayer);
      updateState();

      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlayer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(() {
      activePlayer = (activePlayer == "X") ? "O" : "X";
      turn++;

      String winnerPlayer = game.checkWinner();
      if (winnerPlayer != "") {
        gameOver = true;
        result = "Winner Is $winnerPlayer";
      } else if (!gameOver && turn == 9) {
        result = "It 's Draw";
      }
    });
  }
}
