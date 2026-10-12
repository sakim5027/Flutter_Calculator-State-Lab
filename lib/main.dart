/* Homework 01, Seul An Kim ID: 002886742*/

import 'package:flutter/material.dart';

// ============================================================================
// 1. MAIN ENTRY POINT
// ============================================================================
// Summary: Every Flutter app starts here. runApp() takes your root widget and
// attaches it to the screen, kicking off the framework's build-and-render pipeline.

void main() {
  runApp(const CalculatorApp());
}

// ============================================================================
// 2. ROOT APPLICATION WIDGET (Manages Global Theme State)
// ============================================================================
// Summary: A StatefulWidget that owns the single source of truth for light/dark
// mode. MaterialApp reads isDarkMode to pick a theme, and onToggleTheme lets the
// child screen flip it via a callback — no need to pass data back up manually.
// Reference: https://docs.flutter.dev/cookbook/design/themes
class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  // Global theme toggle variable
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Calculator State Lab',
      debugShowCheckedModeBanner: false,
      // Apply Material 3 Dark or Light theme based on state
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: ControlDeckScreen(
        isDark: isDarkMode,
        // Callback function to toggle theme mode from child widget
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

// ============================================================================
// 3. MAIN DASHBOARD SCREEN (Stateful Controller)
// ============================================================================
// Summary: The screen users actually see. Its State object holds totalTaps,
// powerLevel, and systemStatus, and rebuilds the metrics card, status banner,
// buttons, and slider every time setState() runs.

class ControlDeckScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const ControlDeckScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ControlDeckScreen> createState() => _ControlDeckScreenState();
}

class _ControlDeckScreenState extends State<ControlDeckScreen> {
  // --- Mutable State Variables ---
  //calculator state variables
  double? accumulator;
  String currentOperand = "";
  String? pendingOperator;
  bool startNewOperand = true;
  bool justEvaluated = false;
  String display = "0";

  double? calculate(double first, double second, String operator) {
    switch (operator) {
      case "+":
        return first + second;
      case "-":
        return first - second;
      case "×":
        return first * second;
      case "÷":
        if (second == 0) {
          return null; // Division by zero is not allowed
        }
        return first / second;
      default:
        return null;
    }
  }

  void pressOperator(String operator) {
    setState(() {
      if (accumulator == null && currentOperand.isEmpty) {
        return;
      }

      if (startNewOperand) {
        pendingOperator = operator;
        justEvaluated = false;
        return;
      }

      double number = double.parse(currentOperand);

      if (accumulator == null) {
        accumulator = number;
      } else if (pendingOperator != null) {
        double? result = calculate(accumulator!, number, pendingOperator!);

        if (result == null || !result.isFinite) {
          display = "Error";
          accumulator = null;
          currentOperand = "";
          pendingOperator = null;
          startNewOperand = true;
          justEvaluated = true;
          return;
        }

        accumulator = result;
      }

      display = accumulator.toString();

      if (accumulator!.isFinite &&
          accumulator == accumulator!.truncateToDouble()) {
        display = accumulator!.toInt().toString();
      }

      currentOperand = "";
      pendingOperator = operator;
      startNewOperand = true;
      justEvaluated = false;
    });
  }

  void pressEquals() {
    setState(() {
      if (pendingOperator == null || startNewOperand) {
        return;
      }

      double number = double.parse(currentOperand);

      double? result = calculate(accumulator!, number, pendingOperator!);

      if (result == null || !result.isFinite) {
        display = "Error";
        accumulator = null;
        currentOperand = "";
        pendingOperator = null;
        startNewOperand = true;
        justEvaluated = true;
        return;
      }

      accumulator = result;

      display = result.toString();
      if (result == result.truncateToDouble()) {
        display = result.toInt().toString();
      }

      currentOperand = "";
      pendingOperator = null;
      startNewOperand = true;
      justEvaluated = true;
    });
  }

  void pressClear() {
    setState(() {
      accumulator = null;
      currentOperand = "";
      pendingOperator = null;
      startNewOperand = true;
      justEvaluated = false;
      display = "0";
    });
  }

  // Helper method to update dashboard state upon button press
  void pressDigit(String digit) {
    setState(() {
      if (justEvaluated) {
        accumulator = null;
        pendingOperator = null;
        currentOperand = "";
        justEvaluated = false;
        startNewOperand = true;
      }

      if (startNewOperand) {
        currentOperand = digit;
        startNewOperand = false;
      } else {
        if (currentOperand == "0") {
          currentOperand = digit;
        } else {
          currentOperand += digit;
        }
      }
      display = currentOperand;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic background color adapting to current theme
    final screenBg = widget.isDark
        ? const Color(0xFF1E1F29)
        : const Color(0xFFE0E5EC);
    final cardBg = widget.isDark ? const Color(0xFF282A36) : Colors.white;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text(
          "The Calculator State Lab",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme Toggle Button in the AppBar
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "CALCULATOR",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      display,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- GRID OF TACTILE 3D BUTTONS ---
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (String value in [
                  "7",
                  "8",
                  "9",
                  "÷",
                  "4",
                  "5",
                  "6",
                  "×",
                  "1",
                  "2",
                  "3",
                  "-",
                  "AC",
                  "0",
                  "=",
                  "+",
                ])
                  TactileButton(
                    label: value,
                    accentColor: Colors.blueAccent,
                    isDark: widget.isDark,
                    onPressed: () {
                      if ("0123456789".contains(value) && value.length == 1) {
                        pressDigit(value);
                      } else if (["+", "-", "×", "÷"].contains(value)) {
                        pressOperator(value);
                      } else if (value == "=") {
                        pressEquals();
                      } else if (value == "AC") {
                        pressClear();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. REUSABLE TACTILE 3D BUTTON WIDGET
// ============================================================================
// Summary: A self-contained StatefulWidget that tracks its own isPressed flag
// and uses GestureDetector + two opposing BoxShadows to fake a physical
// push-button depress-and-release effect — no external packages required.

class TactileButton extends StatefulWidget {
  final String label; // Button title text
  final Color accentColor; // Active glow color
  final bool isDark; // Light or Dark theme mode
  final VoidCallback onPressed; // Action callback triggered on tap

  const TactileButton({
    super.key,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  // Local boolean state tracking whether button is currently being held down
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine dynamic background and shadow colors
    final baseColor = widget.isDark
        ? const Color(0xFF222430)
        : const Color(0xFFE0E5EC);
    final darkShadow = widget.isDark ? Colors.black87 : const Color(0xFFA3B1C6);
    final lightShadow = widget.isDark ? const Color(0xFF2F3244) : Colors.white;

    return GestureDetector(
      // 1. User touches button -> depress button
      onTapDown: (_) => setState(() => isPressed = true),
      // 2. User releases button -> restore position and fire callback
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      // 3. User cancels touch -> restore position safely
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 100,
        ), // Smooth 100ms spring transition
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          // Dual opposing BoxShadows create the 3D Neomorphic depth effect
          boxShadow: isPressed
              ? [
                  // Pressed (Sunken) Shadow Offsets
                  BoxShadow(
                    color: darkShadow.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: lightShadow.withValues(alpha: 0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Unpressed (Elevated) Shadow Offsets
                  BoxShadow(
                    color: darkShadow.withValues(alpha: 0.5),
                    offset: const Offset(8, 8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: lightShadow.withValues(alpha: 0.5),
                    offset: const Offset(-8, -8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
