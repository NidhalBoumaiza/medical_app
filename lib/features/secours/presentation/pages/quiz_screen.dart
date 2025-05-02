import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String videoTitle;

  const QuizScreen({super.key, required this.videoTitle});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int? _selectedAnswerIndex;

  // Sample quiz questions related to first aid
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quelle est la fréquence recommandée des compressions thoraciques lors d\'une RCP pour un adulte ?',
      'answers': [
        {'text': '60-80 par minute', 'isCorrect': false},
        {'text': '100-120 par minute', 'isCorrect': true},
      ],
    },
    {
      'question': 'Quelle est la première étape pour gérer une hémorragie externe ?',
      'answers': [
        {'text': 'Appeler les secours', 'isCorrect': false},
        {'text': 'Appliquer une pression directe', 'isCorrect': true},
      ],
    },
    {
      'question': 'Que faut-il faire si une personne s’étouffe et ne peut pas parler ?',
      'answers': [
        {'text': 'Effectuer la manœuvre de Heimlich', 'isCorrect': true},
        {'text': 'Donner de l’eau à boire', 'isCorrect': false},
      ],
    },
  ];

  void _answerQuestion(bool isCorrect, int index) {
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      _selectedAnswerIndex = index;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showFeedback = false;
        _selectedAnswerIndex = null;
      });
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  void _finishQuiz(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quiz - ${widget.videoTitle}",
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2FA7BB),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Progress Bar
              Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[200],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentQuestionIndex + 1) / _questions.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2FA7BB),
                          const Color(0xFF2FA7BB).withOpacity(0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2FA7BB),
                ),
              ),
              const SizedBox(height: 24),
              // Quiz Card
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Question
                          Text(
                            currentQuestion['question'],
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Answer Options
                          Expanded(
                            child: ListView.builder(
                              itemCount: (currentQuestion['answers'] as List<Map<String, dynamic>>).length,
                              itemBuilder: (context, index) {
                                final answer = currentQuestion['answers'][index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GestureDetector(
                                    onTap: _showFeedback
                                        ? null
                                        : () {
                                      _answerQuestion(answer['isCorrect'], index);
                                    },
                                    child: AnimatedOpacity(
                                      opacity: _showFeedback && _selectedAnswerIndex != index ? 0.6 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: _showFeedback && _selectedAnswerIndex == index
                                              ? (answer['isCorrect']
                                              ? const Color(0xFF2FA7BB)
                                              : Colors.red)
                                              : Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFF2FA7BB).withOpacity(0.5),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                answer['text'],
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: _showFeedback && _selectedAnswerIndex == index
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (_showFeedback && _selectedAnswerIndex == index)
                                              Icon(
                                                answer['isCorrect'] ? Icons.check_circle : Icons.cancel,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Next/Finish Button
                          if (_showFeedback)
                            GestureDetector(
                              onTapDown: (_) {}, // Placeholder for animation
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton(
                                  onPressed: _currentQuestionIndex == _questions.length - 1
                                      ? () => _finishQuiz(context)
                                      : _nextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2FA7BB),
                                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    shadowColor: const Color(0xFF2FA7BB).withOpacity(0.3),
                                  ),
                                  child: Text(
                                    _currentQuestionIndex == _questions.length - 1 ? "Terminer" : "Suivant",
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}