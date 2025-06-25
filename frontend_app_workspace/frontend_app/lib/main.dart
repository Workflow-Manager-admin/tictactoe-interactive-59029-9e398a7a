import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

// PUBLIC_INTERFACE
class TicTacToeApp extends StatelessWidget {
  /// Root widget of the Tic Tac Toe app, setting up theme and HomeScreen.
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1976D2);
    const secondaryColor = Color(0xFFFFC107);
    const accentColor = Color(0xFFFF5252);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),
          bodyLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          error: accentColor,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// Enums and game state
enum Player { x, o }
enum GameMode { singlePlayer, twoPlayer }

class HomeScreen extends StatefulWidget {
  /// Home screen containing all interactive features and game control logic.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int boardSize = 3;
  static const primaryColor = Color(0xFF1976D2);
  static const secondaryColor = Color(0xFFFFC107);
  static const accentColor = Color(0xFFFF5252);

  List<List<Player?>> _board = List.generate(boardSize, (_) => List<Player?>.filled(boardSize, null));
  Player _currentPlayer = Player.x;
  Player? _winner;
  bool _draw = false;
  GameMode _gameMode = GameMode.singlePlayer;
  int _scoreX = 0;
  int _scoreO = 0;
  int _scoreDraw = 0;

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  // PUBLIC_INTERFACE
  void _resetBoard() {
    /// Starts a new game, clearing the board and statuses but keeps scores.
    setState(() {
      _board = List.generate(boardSize, (_) => List<Player?>.filled(boardSize, null));
      _currentPlayer = Player.x;
      _winner = null;
      _draw = false;
    });

    // If single player and O is computer and starts
    if (_gameMode == GameMode.singlePlayer && _currentPlayer == Player.o) {
      Future.delayed(const Duration(milliseconds: 360), _performAIMove);
    }
  }

  // PUBLIC_INTERFACE
  void _resetAll() {
    /// Fully resets everything including scoreboard.
    setState(() {
      _scoreX = 0;
      _scoreO = 0;
      _scoreDraw = 0;
    });
    _resetBoard();
  }

  // PUBLIC_INTERFACE
  void _setGameMode(GameMode mode) {
    /// Switches the game mode and restarts the game.
    if (_gameMode != mode) {
      setState(() {
        _gameMode = mode;
      });
      _resetAll();
    }
  }

  // PUBLIC_INTERFACE
  void _handleTap(int row, int col) {
    /// Processes a tap on the board, placing the current player's move if valid, and updates game state.
    if (_board[row][col] != null || _winner != null) {
      return;
    }
    setState(() {
      _board[row][col] = _currentPlayer;
    });
    _checkGameEnd();
    if (_gameMode == GameMode.singlePlayer && _winner == null && !_draw) {
      // Computer's turn (always Player.o)
      if (_currentPlayer == Player.o) {
        Future.delayed(const Duration(milliseconds: 350), _performAIMove);
      }
    }
  }

  // PUBLIC_INTERFACE
  void _performAIMove() {
    /// Uses the Minimax algorithm for a challenging single-player AI opponent.
    // Check if there are moves left and game is not over
    if (_winner != null || _draw) return;
    // Find the best move using Minimax for Player.o (the AI)
    int bestScore = -1000;
    int bestRow = -1;
    int bestCol = -1;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col] == null) {
          _board[row][col] = Player.o;
          int score = _minimax(_board, 0, false);
          _board[row][col] = null;
          if (score > bestScore) {
            bestScore = score;
            bestRow = row;
            bestCol = col;
          }
        }
      }
    }

    if (bestRow != -1 && bestCol != -1) {
      setState(() {
        _board[bestRow][bestCol] = Player.o;
      });
    }
    _checkGameEnd();
  }

  int _minimax(List<List<Player?>> board, int depth, bool isMaximizing) {
    // Check for terminal states
    Player? winner = _evaluateWinner(board);
    if (winner != null) {
      if (winner == Player.o) return 10 - depth;
      if (winner == Player.x) return depth - 10;
    }
    if (_checkIsDraw(board)) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          if (board[row][col] == null) {
            board[row][col] = Player.o;
            int score = _minimax(board, depth + 1, false);
            board[row][col] = null;
            if (score > bestScore) bestScore = score;
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          if (board[row][col] == null) {
            board[row][col] = Player.x;
            int score = _minimax(board, depth + 1, true);
            board[row][col] = null;
            if (score < bestScore) bestScore = score;
          }
        }
      }
      return bestScore;
    }
  }

  Player? _evaluateWinner(List<List<Player?>> board) {
    // Rows and columns
    for (int i = 0; i < boardSize; i++) {
      // Rows
      if (board[i][0] != null &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return board[i][0];
      }
      // Columns
      if (board[0][i] != null &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return board[0][i];
      }
    }
    // Diagonals
    if (board[0][0] != null &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }
    if (board[0][2] != null &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }
    return null;
  }

  bool _checkIsDraw(List<List<Player?>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell == null) {
          return false;
        }
      }
    }
    return _evaluateWinner(board) == null;
  }

  // PUBLIC_INTERFACE
  void _checkGameEnd() {
    /// Checks for a win or draw, updates winner variables and scoreboard accordingly.
    final winner = _getWinner();
    if (winner != null) {
      setState(() {
        _winner = winner;
        if (_winner == Player.x) {
          _scoreX += 1;
        } else if (_winner == Player.o) {
          _scoreO += 1;
        }
      });
    } else if (_isDraw()) {
      setState(() {
        _draw = true;
        _scoreDraw += 1;
      });
    } else {
      setState(() {
        _currentPlayer = _currentPlayer == Player.x ? Player.o : Player.x;
      });
    }
  }

  // PUBLIC_INTERFACE
  Player? _getWinner() {
    /// Checks rows, columns, and diagonals for a winner.
    // Rows and columns
    for (int i = 0; i < boardSize; i++) {
      // Rows
      if (_board[i][0] != null &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        return _board[i][0];
      }
      // Columns
      if (_board[0][i] != null &&
          _board[0][i] == _board[1][i] &&
          _board[1][i] == _board[2][i]) {
        return _board[0][i];
      }
    }
    // Diagonals
    if (_board[0][0] != null &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      return _board[0][0];
    }
    if (_board[0][2] != null &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      return _board[0][2];
    }
    return null;
  }

  // PUBLIC_INTERFACE
  bool _isDraw() {
    /// Checks if the board is full and there's no winner.
    for (var row in _board) {
      for (var cell in row) {
        if (cell == null) {
          return false;
        }
      }
    }
    return _winner == null;
  }

  // PUBLIC_INTERFACE
  String _playerSymbol(Player? p) {
    /// Returns X or O string for a player or "" if null.
    if (p == Player.x) return "X";
    if (p == Player.o) return "O";
    return "";
  }

  // PUBLIC_INTERFACE
  Color? _cellColor(Player? p) {
    /// Returns a color for grid cells depending on player.
    if (p == Player.x) return primaryColor.withAlpha((0.09 * 255).toInt());
    if (p == Player.o) return secondaryColor.withAlpha((0.10 * 255).toInt());
    return Colors.white;
  }

  // PUBLIC_INTERFACE
  Color _playerColor(Player? p) {
    /// Returns a color for text depending on player.
    if (p == Player.x) return primaryColor;
    if (p == Player.o) return secondaryColor;
    return Colors.grey.shade500;
  }

  /// Builds the 3x3 board with interactive cells, updating so every cell has a thick black border.
  Widget _buildBoard() {
    double boardWidth = MediaQuery.of(context).size.width * 0.90;
    if (boardWidth > 340) boardWidth = 340;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          width: boardWidth,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Color(0xFFFF5252), // Accent color for outer board border
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.07 * 255).toInt()),
                offset: const Offset(1, 2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: List.generate(boardSize, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(boardSize, (col) {
                    // Provide black border for each cell
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: _cellColor(_board[row][col]),
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: row == 0 ? 2.5 : 1.0,
                            ),
                            left: BorderSide(
                              color: Colors.black,
                              width: col == 0 ? 2.5 : 1.0,
                            ),
                            right: BorderSide(
                              color: Colors.black,
                              width: col == boardSize - 1 ? 2.5 : 1.0,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: row == boardSize - 1 ? 2.5 : 1.0,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: InkWell(
                          onTap: (_winner == null && !_draw && (_board[row][col] == null) &&
                                  (_gameMode == GameMode.twoPlayer ||
                                      (_gameMode == GameMode.singlePlayer && _currentPlayer == Player.x)
                                  )
                          )
                              ? () => _handleTap(row, col)
                              : null,
                          borderRadius: BorderRadius.circular(5),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  color: _playerColor(_board[row][col])
                              ),
                              child: Text(_playerSymbol(_board[row][col])),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    /// Displays player scores and game summary.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18),
      child: Row(
        children: [
          _scoreBox("X", _scoreX, primaryColor),
          const Spacer(),
          _scoreBox("Draw", _scoreDraw, accentColor),
          const Spacer(),
          _scoreBox("O", _scoreO, secondaryColor),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(
            color: label == "Draw" ? color : color,
            fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 1.5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: color.withAlpha((0.09 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("$score", style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 18.5)),
        ),
      ],
    );
  }

  Widget _buildControls() {
    /// Renders controls: mode toggle, reset, new game.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2),
      child: Column(
        children: [
          _buildModeSwitch(),
          const SizedBox(height: 14),
          SizedBox(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.loop, size: 19),
                  label: const Text("New Game"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor, width: 1.0),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: _resetBoard,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh, size: 19),
                  label: const Text("Reset All"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: const BorderSide(color: accentColor, width: 1.0),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: _resetAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    /// Radio buttons for selecting game mode.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _modeBtn(GameMode.singlePlayer, icon: Icons.person, label: "Single Player"),
        const SizedBox(width: 12),
        _modeBtn(GameMode.twoPlayer, icon: Icons.people, label: "Two Player"),
      ],
    );
  }

  Widget _modeBtn(GameMode mode, {required IconData icon, required String label}) {
    final selected = _gameMode == mode;
    final color = selected ? primaryColor : Colors.grey.shade400;
    return TextButton.icon(
      onPressed: () => _setGameMode(mode),
      icon: Icon(icon, color: color, size: 22),
      label: Text(label, style: TextStyle(
          color: color,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal)
      ),
      style: TextButton.styleFrom(
        backgroundColor: selected ? primaryColor.withAlpha((0.09 * 255).toInt()) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      ),
    );
  }

  Widget _buildStatusBanner() {
    /// Text status at the top (turn, winner, draw).
    String msg;
    Color color;
    if (_winner != null) {
      msg = "${_playerSymbol(_winner)} wins!";
      color = _winner == Player.x ? primaryColor : secondaryColor;
    } else if (_draw) {
      msg = "It's a draw!";
      color = accentColor;
    } else {
      msg = _gameMode == GameMode.singlePlayer
          ? (_currentPlayer == Player.x ? "Your turn (X)" : "Computer's turn (O)")
          : "${_playerSymbol(_currentPlayer)}'s turn";
      color = _currentPlayer == Player.x ? primaryColor : secondaryColor;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 6),
      child: Text(
        msg,
        style: TextStyle(
          fontSize: 22,
          color: color,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: color.withAlpha((0.07 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 1)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Main layout: centered column, board and controls, responsive and minimal.
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 18),
              _buildStatusBanner(),
              _buildBoard(),
              const SizedBox(height: 18),
              _buildScoreboard(),
              const SizedBox(height: 10),
              _buildControls(),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
