import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(KhazimBoxGame());

class KhazimBoxGame extends StatefulWidget {
  @override
  _KhazimBoxGameState createState() => _KhazimBoxGameState();
}

class _KhazimBoxGameState extends State<KhazimBoxGame> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhazimBox',
      home: KhazimBoxHomePage(),
    );
  }
}

class KhazimBoxHomePage extends StatefulWidget {
  @override
  _KhazimBoxHomePageState createState() => _KhazimBoxHomePageState();
}

class _KhazimBoxHomePageState extends State<KhazimBoxHomePage>
    with TickerProviderStateMixin {
  double xDivisions = 1;
  double yDivisions = 1;
  List<List<bool>> selectedBoxes = [];
  Random random = Random();
  double currentQuestion = 0;
  String currentQuestionString = '';
  bool showMessage = false;
  String message = '';
  Offset? rippleCenter;
  double rippleRadius = 0.0;
  Color boxColor = Colors.white;
  Color? lastBoxColor;

  late AnimationController rippleController;
  late Animation<double> rippleAnimation;

  late AnimationController colorController;
  late Animation<Color?> colorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeBoxes();
    _generateNewQuestion();
  }

  void _initializeBoxes() {
    selectedBoxes = List.generate(10, (i) => List.generate(10, (j) => false));
  }

  void _resetSelection() {
    setState(() {
      _initializeBoxes();
    });
  }

  void _submitSelection() {
    int selectedCount =
        selectedBoxes.expand((row) => row).where((selected) => selected).length;
    double target = currentQuestion;
    int requiredCount = (target * (xDivisions * yDivisions)).round();

    setState(() {
      if (selectedCount == 0) {
        message = "Silahkan tandai kotak!";
      } else if (selectedCount == requiredCount) {
        message = "Mantaps! Jawaban benar.";
      } else {
        message = "Coba lagi! Masih salah.";
      }
      showMessage = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showMessage = false;
      });
    });
  }

  Widget _buildPopupMessage() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 500),
      bottom: showMessage ? 80 : -200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: message.contains("benar")
                ? Color(0xff06d6a0)
                : Color(0xffef476f),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _generateNewQuestion() {
    setState(() {
      if (random.nextBool()) {
        double decimalValue =
            double.parse((random.nextDouble()).toStringAsFixed(3));
        currentQuestionString = decimalValue.toString();
        currentQuestion = decimalValue;
      } else {
        int numerator = random.nextInt(10) + 1;
        int denominator = random.nextInt(9) + 1;
        currentQuestionString = '$numerator/$denominator';
        currentQuestion = numerator / denominator;
      }
      _resetSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double canvasSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Color(0xfff7ede2),
      body: SafeArea(
        child: Stack(
          children: [
            _buildPopupMessage(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo_kbox.png', width: 150),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Soal: $currentQuestionString",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff073b4c)),
                  ),
                ),
                Spacer(),

                // Content Canvas
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Canvas
                      Container(
                        width: canvasSize,
                        height: canvasSize,
                        decoration: BoxDecoration(
                          color: Color(0xFFD9E7FF),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            _handleDrag(details.localPosition, canvasSize);
                          },
                          onTapDown: (details) {
                            _handleTap(details.localPosition, canvasSize);
                          },
                          child: CustomPaint(
                            size: Size(canvasSize, canvasSize),
                            painter: CanvasPainter(
                              xDivisions: xDivisions,
                              yDivisions: yDivisions,
                              selectedBoxes: selectedBoxes,
                              rippleCenter: rippleCenter,
                              rippleRadius: rippleRadius,
                              boxColor: boxColor,
                            ),
                          ),
                        ),
                      ),

                      // Slider Up
                      Positioned(
                        top: -25,
                        child: Container(
                          width: canvasSize - 30,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: SquareThumb(
                                    thumbPosition: ThumbPosition.up),
                                showValueIndicator: ShowValueIndicator.always,
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                              ),
                              child: Slider(
                                value: yDivisions,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: yDivisions.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    yDivisions = value;
                                    _resetSelection();
                                  });
                                },
                                onChangeStart: (value) {},
                                onChangeEnd: (value) {},
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Slider Down
                      Positioned(
                        bottom: -25,
                        child: Container(
                          width: canvasSize - 30,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: SquareThumb(
                                    thumbPosition: ThumbPosition.down),
                                showValueIndicator: ShowValueIndicator.always,
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                              ),
                              child: Slider(
                                value: yDivisions,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: yDivisions.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    yDivisions = value;
                                    _resetSelection();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Slider Right
                      Positioned(
                        left: -25,
                        child: Container(
                          height: canvasSize - 25,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: SquareThumb(
                                    thumbPosition: ThumbPosition.right),
                                showValueIndicator: ShowValueIndicator.always,
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                              ),
                              child: Slider(
                                value: xDivisions,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: xDivisions.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    xDivisions = value;
                                    _resetSelection();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Slider Left
                      Positioned(
                        right: -25,
                        child: Container(
                          height: canvasSize - 25,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: SquareThumb(
                                    thumbPosition: ThumbPosition.left),
                                showValueIndicator: ShowValueIndicator.always,
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                              ),
                              child: Slider(
                                value: xDivisions,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: xDivisions.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    xDivisions = value;
                                    _resetSelection();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Button
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetSelection,
                        icon: Icon(Icons.refresh),
                        label: Text("Reset"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffef476f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _generateNewQuestion,
                        icon: Icon(Icons.autorenew),
                        label: Text("Ganti Soal"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff06d6a0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _submitSelection,
                        icon: Icon(Icons.send),
                        label: Text("Submit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff118ab2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDrag(Offset position, double canvasSize) {
    final double boxWidth = canvasSize / yDivisions;
    final double boxHeight = canvasSize / xDivisions;

    final int row = (position.dy / boxHeight).floor();
    final int col = (position.dx / boxWidth).floor();

    if (row >= 0 && row < xDivisions && col >= 0 && col < yDivisions) {
      setState(() {
        selectedBoxes[row][col] = true;
      });
    }
  }

  void _handleTap(Offset position, double canvasSize) {
    final double boxWidth = canvasSize / yDivisions;
    final double boxHeight = canvasSize / xDivisions;

    final int row = (position.dy / boxHeight).floor();
    final int col = (position.dx / boxWidth).floor();

    if (row >= 0 && row < xDivisions && col >= 0 && col < yDivisions) {
      setState(() {
        selectedBoxes[row][col] = !selectedBoxes[row][col];

        _startRippleEffect(position);

        Color targetColor = _getRandomColor();
        if (!selectedBoxes[row][col]) {
          lastBoxColor = boxColor;
        }
        boxColor = targetColor;
      });
    }
  }

  void _startColorFade(Color targetColor) {
    if (lastBoxColor == null) {
      lastBoxColor = boxColor;
    }
    colorController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    colorAnimation = ColorTween(begin: lastBoxColor, end: targetColor)
        .animate(colorController)
      ..addListener(() {
        setState(() {
          boxColor = colorAnimation.value!;
        });
      });

    colorController.forward().whenComplete(() {
      colorController.dispose();
      setState(() {
        boxColor = Colors.white;
      });
    });
  }

  void _startRippleEffect(Offset position) {
    const double maxRadius = 30.0;

    rippleController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    rippleAnimation =
        Tween<double>(begin: 0, end: maxRadius).animate(rippleController)
          ..addListener(() {
            setState(() {
              rippleRadius = rippleAnimation.value;
              rippleCenter = position;
            });
          });

    rippleController.forward().whenComplete(() {
      rippleController.dispose();
      setState(() {
        rippleRadius = 0.0;
      });
    });
  }

  Color _getRandomColor() {
    List<Color> colors = [
      Color(0xFF70d6ff),
      Color(0xffff70a6),
      Color(0xffff9770),
      Color(0xffffd670),
      Color(0xff60d394)
    ];
    return colors[random.nextInt(colors.length)];
  }
}

class CanvasPainter extends CustomPainter {
  final double xDivisions;
  final double yDivisions;
  final List<List<bool>> selectedBoxes;
  final Offset? rippleCenter;
  final double rippleRadius;
  final Color boxColor;

  CanvasPainter({
    required this.xDivisions,
    required this.yDivisions,
    required this.selectedBoxes,
    required this.rippleCenter,
    required this.rippleRadius,
    required this.boxColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double boxWidth = size.width / yDivisions;
    final double boxHeight = size.height / xDivisions;

    Paint paintBox = Paint()..color = boxColor;
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (int i = 0; i < xDivisions; i++) {
      for (int j = 0; j < yDivisions; j++) {
        if (selectedBoxes[i][j]) {
          canvas.drawRect(
            Rect.fromLTWH(j * boxWidth, i * boxHeight, boxWidth, boxHeight),
            paintBox,
          );
        }
      }
    }

    if (rippleCenter != null) {
      Paint ripplePaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(rippleCenter!, rippleRadius, ripplePaint);
    }

    for (int i = 1; i < xDivisions; i++) {
      double dy = i * boxHeight;
      if (dy <= size.height) {
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
      }
    }

    for (int j = 1; j < yDivisions; j++) {
      double dx = j * boxWidth;
      if (dx <= size.width) {
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.xDivisions != xDivisions ||
        oldDelegate.yDivisions != yDivisions ||
        oldDelegate.selectedBoxes != selectedBoxes ||
        oldDelegate.rippleRadius != rippleRadius ||
        oldDelegate.boxColor != boxColor;
  }
}

enum ThumbPosition { up, down, left, right }

class SquareThumb extends SliderComponentShape {
  final ThumbPosition thumbPosition;

  SquareThumb({required this.thumbPosition});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(1.0, 1.0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Paint paint = Paint()..color = sliderTheme.thumbColor!;
    final Rect rect;

    switch (thumbPosition) {
      case ThumbPosition.up:
      case ThumbPosition.down:
        rect = Rect.fromCenter(center: center, width: 24, height: 12);
        break;
      case ThumbPosition.left:
      case ThumbPosition.right:
        rect = Rect.fromCenter(center: center, width: 24, height: 12);
        break;
    }

    context.canvas.drawRect(rect, paint);
  }
}
