import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/trivia_entity.dart';

/// Interactive trivia quiz screen
class TriviaQuizScreen extends ConsumerStatefulWidget {
  final TriviaQuizEntity quiz;

  const TriviaQuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<TriviaQuizScreen> createState() => _TriviaQuizScreenState();
}

class _TriviaQuizScreenState extends ConsumerState<TriviaQuizScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool showExplanation = false;
  int totalScore = 0;
  int correctAnswers = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TriviaQuestionEntity get currentQuestion =>
      widget.quiz.questions[currentQuestionIndex];

  bool get isLastQuestion =>
      currentQuestionIndex == widget.quiz.questions.length - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quiz.movieTitle} Trivia'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${currentQuestionIndex + 1}/${widget.quiz.totalQuestions}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / widget.quiz.totalQuestions,
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Score display
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScoreStat(
                            'Score',
                            totalScore.toString(),
                            Icons.stars,
                            theme,
                          ),
                          _buildScoreStat(
                            'Correct',
                            '$correctAnswers/${currentQuestionIndex + 1}',
                            Icons.check_circle,
                            theme,
                          ),
                          _buildScoreStat(
                            'Accuracy',
                            '${((correctAnswers / (currentQuestionIndex + 1)) * 100).toStringAsFixed(0)}%',
                            Icons.trending_up,
                            theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Difficulty badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currentQuestion.difficulty.emoji),
                            const SizedBox(width: 6),
                            Text(
                              currentQuestion.difficulty.name.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${currentQuestion.pointsReward} pts',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        currentQuestion.question,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return _buildAnswerOption(index, option, theme);
                  }),

                  // Explanation
                  if (showExplanation &&
                      currentQuestion.explanation != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      color:
                          selectedAnswerIndex ==
                              currentQuestion.correctAnswerIndex
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selectedAnswerIndex ==
                                          currentQuestion.correctAnswerIndex
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color:
                                      selectedAnswerIndex ==
                                          currentQuestion.correctAnswerIndex
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.explanation!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Next button
          if (showExplanation)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _handleNext,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Text(isLastQuestion ? 'Finish Quiz' : 'Next Question'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOption(int index, String option, ThemeData theme) {
    final isSelected = selectedAnswerIndex == index;
    final isCorrect = index == currentQuestion.correctAnswerIndex;
    final showResult = showExplanation;

    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (showResult) {
      if (isSelected && isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        icon = Icons.cancel;
      } else if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        icon = Icons.check_circle_outline;
      }
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primaryContainer;
      borderColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: showResult ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: showResult && isCorrect
                    ? Colors.green
                    : theme.colorScheme.primary,
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: isCorrect ? Colors.green : Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
      showExplanation = true;

      if (index == currentQuestion.correctAnswerIndex) {
        correctAnswers++;
        totalScore += currentQuestion.pointsReward;
        _controller.forward().then((_) => _controller.reverse());
      }
    });
  }

  void _handleNext() {
    if (isLastQuestion) {
      _showQuizResults();
    } else {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        showExplanation = false;
      });
    }
  }

  void _showQuizResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              totalScore.toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You got $correctAnswers out of ${widget.quiz.totalQuestions} correct!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${((correctAnswers / widget.quiz.totalQuestions) * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: Share results
            },
            child: const Text('Share Results'),
          ),
        ],
      ),
    );
  }
}
