import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class SecoursScreen extends StatelessWidget {
  const SecoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Premiers Secours",
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: ListView(
            children: [
              // Première carte: RCP
              _buildFirstAidCard(
                context,
                title: "Réanimation cardio-pulmonaire (RCP)",
                description:
                "Apprenez les étapes essentielles pour effectuer une RCP en cas d'arrêt cardiaque. Cette vidéo vous guide à travers les compressions thoraciques et la respiration artificielle.",
                quizTitle: "Quiz : RCP",
                quizQuestion:
                "Quelle est la fréquence recommandée des compressions thoraciques lors d'une RCP pour un adulte ?",
                options: [
                  _QuizOption(
                    text: "60-80 par minute",
                    isCorrect: false,
                    feedback:
                    "Incorrect ! La bonne réponse est 100-120 compressions par minute.",
                  ),
                  _QuizOption(
                    text: "100-120 par minute",
                    isCorrect: true,
                    feedback: "Correct !",
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deuxième carte: Hémorragies
              _buildFirstAidCard(
                context,
                title: "Gestion des hémorragies",
                description:
                "Découvrez comment arrêter une hémorragie externe en appliquant une pression directe et en élevant la partie blessée. Cette vidéo montre des techniques pratiques.",
                quizTitle: "Quiz : Hémorragies",
                quizQuestion:
                "Quelle est la première étape pour gérer une hémorragie externe ?",
                options: [
                  _QuizOption(
                    text: "Appeler les secours",
                    isCorrect: false,
                    feedback:
                    "Incorrect ! La première étape est d'appliquer une pression directe.",
                  ),
                  _QuizOption(
                    text: "Appliquer une pression directe",
                    isCorrect: true,
                    feedback: "Correct !",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstAidCard(
      BuildContext context, {
        required String title,
        required String description,
        required String quizTitle,
        required String quizQuestion,
        required List<_QuizOption> options,
      }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[200]!, Colors.grey[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 60,
                    color: AppColors.primaryColor.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // Quiz Button
              Center(
                child: GestureDetector(
                  onTapDown: (_) {}, // Placeholder for animation
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildQuizDialog(
                            context,
                            quizTitle: quizTitle,
                            quizQuestion: quizQuestion,
                            options: options,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withOpacity(0.3),
                      ),
                      child: Text(
                        "Lancer le Quiz",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
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

  Widget _buildQuizDialog(
      BuildContext context, {
        required String quizTitle,
        required String quizQuestion,
        required List<_QuizOption> options,
      }) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quiz Title
              Text(
                quizTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 12),

              // Question
              Text(
                quizQuestion,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Answer Options
              Column(
                children: options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  option.isCorrect ? Icons.check : Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option.feedback,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor:
                            option.isCorrect ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.5),
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
                          child: Text(
                            option.text,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizOption {
  final String text;
  final bool isCorrect;
  final String feedback;

  _QuizOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}