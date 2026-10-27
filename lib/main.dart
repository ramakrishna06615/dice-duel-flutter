import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const DiceDuelApp());
}

class DiceDuelApp extends StatelessWidget {
  const DiceDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Duel',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const ModeSelectionPage(),
    );
  }
}

// ============================================================
// GAME MODE
// ============================================================

enum GameMode {
  friend,
  bot,
}

// ============================================================
// MODE SELECTION PAGE
// ============================================================

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF09051A),
              Color(0xFF170C35),
              Color(0xFF09051A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // LOGO
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C4DFF),
                          Color(0xFFE040FB),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.45),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🎲',
                        style: TextStyle(fontSize: 55),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'DICE DUEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Choose your game mode',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 45),

                  // BOT MODE
                  modeButton(
                    context: context,
                    icon: '🤖',
                    title: 'PLAY VS BOT',
                    subtitle: 'Challenge the computer',
                    color: const Color(0xFF00E5FF),
                    mode: GameMode.bot,
                  ),

                  const SizedBox(height: 20),

                  // FRIEND MODE
                  modeButton(
                    context: context,
                    icon: '👥',
                    title: 'PLAY WITH FRIEND',
                    subtitle: 'Two players on one device',
                    color: const Color(0xFFFF4081),
                    mode: GameMode.friend,
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    '3 TURNS • HIGHEST SCORE WINS',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget modeButton({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required GameMode mode,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiceGamePage(mode: mode),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GAME PAGE
// ============================================================

class DiceGamePage extends StatefulWidget {
  final GameMode mode;

  const DiceGamePage({
    super.key,
    required this.mode,
  });

  @override
  State<DiceGamePage> createState() => _DiceGamePageState();
}

class _DiceGamePageState extends State<DiceGamePage>
    with SingleTickerProviderStateMixin {
  final Random random = Random();

  int diceValue = 1;

  int player1Score = 0;
  int player2Score = 0;

  int player1Turns = 0;
  int player2Turns = 0;

  int currentPlayer = 1;

  bool gameOver = false;
  bool isRolling = false;
  bool botThinking = false;

  late AnimationController diceController;
  late Animation<double> diceAnimation;

  @override
  void initState() {
    super.initState();

    diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    diceAnimation = CurvedAnimation(
      parent: diceController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    diceController.dispose();
    super.dispose();
  }

  // ============================================================
  // MODE NAME
  // ============================================================

  String get modeName {
    if (widget.mode == GameMode.bot) {
      return 'BOT MODE';
    }

    return 'FRIEND MODE';
  }

  String get player2Name {
    if (widget.mode == GameMode.bot) {
      return 'BOT';
    }

    return 'PLAYER 2';
  }

  // ============================================================
  // ROLL DICE
  // ============================================================

  Future<void> rollDice() async {
    if (gameOver || isRolling || botThinking) {
      return;
    }

    // In bot mode, player can only control Player 1.
    if (widget.mode == GameMode.bot && currentPlayer != 1) {
      return;
    }

    setState(() {
      isRolling = true;
    });

    diceController.forward(from: 0);

    // Dice animation
    for (int i = 0; i < 8; i++) {
      await Future.delayed(
        const Duration(milliseconds: 70),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        diceValue = random.nextInt(6) + 1;
      });
    }

    final int result = random.nextInt(6) + 1;

    setState(() {
      diceValue = result;

      if (currentPlayer == 1) {
        player1Score += result;
        player1Turns++;
      } else {
        player2Score += result;
        player2Turns++;
      }

      isRolling = false;
    });

    // Check game completion
    if (player1Turns == 3 && player2Turns == 3) {
      setState(() {
        gameOver = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      if (mounted) {
        showWinnerDialog();
      }

      return;
    }

    // Change turn
    if (currentPlayer == 1) {
      setState(() {
        currentPlayer = 2;
      });
    } else {
      setState(() {
        currentPlayer = 1;
      });
    }

    // If BOT MODE and it is bot's turn
    if (widget.mode == GameMode.bot &&
        currentPlayer == 2 &&
        !gameOver) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (mounted) {
        await botTurn();
      }
    }
  }

  // ============================================================
  // BOT TURN
  // ============================================================

  Future<void> botTurn() async {
    if (gameOver || !mounted) {
      return;
    }

    setState(() {
      botThinking = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    // Bot rolling animation
    diceController.forward(from: 0);

    for (int i = 0; i < 8; i++) {
      await Future.delayed(
        const Duration(milliseconds: 80),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        diceValue = random.nextInt(6) + 1;
      });
    }

    final int result = random.nextInt(6) + 1;

    if (!mounted) {
      return;
    }

    setState(() {
      diceValue = result;
      player2Score += result;
      player2Turns++;
      botThinking = false;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    // Check game completion
    if (player1Turns == 3 && player2Turns == 3) {
      setState(() {
        gameOver = true;
      });

      if (mounted) {
        showWinnerDialog();
      }

      return;
    }

    // Back to Player 1
    setState(() {
      currentPlayer = 1;
    });
  }

  // ============================================================
  // RESTART
  // ============================================================

  void restartGame() {
    setState(() {
      diceValue = 1;

      player1Score = 0;
      player2Score = 0;

      player1Turns = 0;
      player2Turns = 0;

      currentPlayer = 1;

      gameOver = false;
      isRolling = false;
      botThinking = false;
    });
  }

  // ============================================================
  // GO TO MAIN MENU
  // ============================================================

  void goToMenu() {
    Navigator.pop(context);
  }

  // ============================================================
  // WINNER DIALOG
  // ============================================================

  void showWinnerDialog() {
    String winner;
    String subtitle;
    Color winnerColor;

    if (player1Score > player2Score) {
      winner = 'PLAYER 1 WINS!';
      subtitle = '$player1Score points';
      winnerColor = const Color(0xFF00E5FF);
    } else if (player2Score > player1Score) {
      if (widget.mode == GameMode.bot) {
        winner = 'BOT WINS!';
      } else {
        winner = 'PLAYER 2 WINS!';
      }

      subtitle = '$player2Score points';
      winnerColor = const Color(0xFFFF4081);
    } else {
      winner = "IT'S A DRAW!";
      subtitle = '$player1Score points each';
      winnerColor = Colors.amber;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A1B55),
                  Color(0xFF120D29),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: winnerColor.withValues(alpha: 0.7),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: winnerColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 70),
                ),

                const SizedBox(height: 10),

                Text(
                  winner,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: winnerColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 19,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: winnerScoreBox(
                        'PLAYER 1',
                        player1Score,
                        const Color(0xFF00E5FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: winnerScoreBox(
                        player2Name,
                        player2Score,
                        const Color(0xFFFF4081),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // PLAY AGAIN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      restartGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: winnerColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // MAIN MENU
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      goToMenu();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(
                        color: Colors.white24,
                      ),
                    ),
                    child: const Text('MAIN MENU'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // WINNER SCORE BOX
  // ============================================================

  Widget winnerScoreBox(
    String name,
    int score,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAYER CARD
  // ============================================================

  Widget playerCard({
    required int player,
    required String name,
    required int score,
    required int turns,
    required Color color,
  }) {
    final bool active =
        currentPlayer == player &&
        !gameOver &&
        !botThinking;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 350,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [
                    color.withValues(alpha: 0.35),
                    color.withValues(alpha: 0.08),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.07),
                    Colors.white.withValues(alpha: 0.03),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active
                ? color
                : Colors.white.withValues(alpha: 0.08),
            width: active ? 2.5 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  player == 1
                      ? Icons.person_rounded
                      : widget.mode == GameMode.bot
                          ? Icons.smart_toy_rounded
                          : Icons.person_rounded,
                  color: active
                      ? color
                      : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active
                          ? color
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'TURN $turns / 3',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    width: 18,
                    height: 5,
                    decoration: BoxDecoration(
                      color: index < turns
                          ? color
                          : Colors.white
                              .withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DICE WIDGET
  // ============================================================

  Widget diceWidget() {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(diceAnimation),
      child: RotationTransition(
        turns: Tween<double>(
          begin: 0,
          end: isRolling ? 1 : 0,
        ).animate(diceAnimation),
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFE7E7F0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(
                  alpha: 0.45,
                ),
                blurRadius: 35,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: Text(
              diceFace(diceValue),
              style: const TextStyle(
                fontSize: 115,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DICE FACE
  // ============================================================

  String diceFace(int value) {
    const faces = [
      '⚀',
      '⚁',
      '⚂',
      '⚃',
      '⚄',
      '⚅',
    ];

    return faces[value - 1];
  }

  // ============================================================
  // RULES
  // ============================================================

  void showRules() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1235),
          title: const Text(
            '🎲 How to Play',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            widget.mode == GameMode.bot
                ? '• You play against the Bot.\n\n'
                    '• Each player gets 3 turns.\n\n'
                    '• Roll the dice once per turn.\n\n'
                    '• The Bot plays automatically.\n\n'
                    '• The dice number is added to the score.\n\n'
                    '• Highest score after 3 turns wins.'
                : '• Two friends play on the same device.\n\n'
                    '• Each player gets 3 turns.\n\n'
                    '• Roll the dice once per turn.\n\n'
                    '• Turns alternate between players.\n\n'
                    '• The dice number is added to the score.\n\n'
                    '• Highest score after 3 turns wins.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('GOT IT'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CONFIRM RESTART
  // ============================================================

  void confirmRestart() {
    if (isRolling || botThinking) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1235),
          title: const Text(
            'Restart Game?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Your current scores will be reset.',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                restartGame();
              },
              child: const Text('RESTART'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String turnText;

    if (gameOver) {
      turnText = 'GAME COMPLETE';
    } else if (botThinking) {
      turnText = 'BOT IS PLAYING';
    } else {
      turnText =
          currentPlayer == 1
              ? 'PLAYER 1\'S TURN'
              : '$player2Name\'S TURN';
    }

    final Color activeColor =
        currentPlayer == 1
            ? const Color(0xFF00E5FF)
            : const Color(0xFFFF4081);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF09051A),
              Color(0xFF170C35),
              Color(0xFF09051A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  15,
                  12,
                  10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF7C4DFF),
                            Color(0xFFE040FB),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple
                                .withValues(alpha: 0.35),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🎲',
                          style: TextStyle(
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DICE DUEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            modeName,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed:
                          isRolling || botThinking
                              ? null
                              : showRules,
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white70,
                      ),
                    ),

                    IconButton(
                      onPressed:
                          isRolling || botThinking
                              ? null
                              : confirmRestart,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // PLAYER CARDS
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    playerCard(
                      player: 1,
                      name: 'PLAYER 1',
                      score: player1Score,
                      turns: player1Turns,
                      color: const Color(0xFF00E5FF),
                    ),

                    playerCard(
                      player: 2,
                      name: player2Name,
                      score: player2Score,
                      turns: player2Turns,
                      color: const Color(0xFFFF4081),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TURN INDICATOR
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: activeColor.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      gameOver
                          ? Icons
                              .emoji_events_rounded
                          : botThinking
                              ? Icons
                                  .smart_toy_rounded
                              : Icons.flash_on_rounded,
                      color: activeColor,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      turnText,
                      style: TextStyle(
                        color: activeColor,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ==================================================
              // DICE
              // ==================================================

              const Text(
                'DICE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              diceWidget(),

              const SizedBox(height: 20),

              AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 250),
                child: isRolling
                    ? const Text(
                        'ROLLING...',
                        key: ValueKey('rolling'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      )
                    : botThinking
                        ? const Text(
                            '🤖 BOT IS THINKING...',
                            key: ValueKey(
                              'bot',
                            ),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          )
                        : Text(
                            'Rolled a $diceValue',
                            key: ValueKey(
                              diceValue,
                            ),
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 16,
                            ),
                          ),
              ),

              const Spacer(),

              // ==================================================
              // ROLL BUTTON
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: gameOver ||
                                botThinking ||
                                (widget.mode ==
                                        GameMode.bot &&
                                    currentPlayer ==
                                        2)
                            ? [
                                Colors.grey,
                                Colors.grey.shade700,
                              ]
                            : [
                                const Color(
                                  0xFF7C4DFF,
                                ),
                                const Color(
                                  0xFFE040FB,
                                ),
                              ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      boxShadow:
                          gameOver ||
                                  botThinking
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors
                                        .purple
                                        .withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 20,
                                    offset:
                                        const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                    ),
                    child: ElevatedButton(
                      onPressed:
                          gameOver ||
                                  isRolling ||
                                  botThinking ||
                                  (widget.mode ==
                                          GameMode.bot &&
                                      currentPlayer ==
                                          2)
                              ? null
                              : rollDice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent,
                        shadowColor:
                            Colors.transparent,
                        disabledBackgroundColor:
                            Colors.transparent,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                      child: Text(
                        gameOver
                            ? 'GAME COMPLETE'
                            : botThinking
                                ? 'BOT PLAYING...'
                                : currentPlayer ==
                                            2 &&
                                        widget.mode ==
                                            GameMode.friend
                                    ? '🎲  PLAYER 2 ROLL'
                                    : '🎲  ROLL DICE',
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                gameOver
                    ? 'Game completed'
                    : '3 turns each • Highest score wins',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // MAIN MENU BUTTON
              // ==================================================

              TextButton.icon(
                onPressed:
                    isRolling || botThinking
                        ? null
                        : goToMenu,
                icon: const Icon(
                  Icons.home_rounded,
                  size: 18,
                ),
                label: const Text(
                  'MAIN MENU',
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}