// Archivo: somnolencia_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/somnolencia_provider.dart';
import '../../data/models/somnolencia_model.dart';

class SomnolenciaScreen extends StatelessWidget {
  const SomnolenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SomnolenciaProvider(),
      child: const _SomnolenciaContent(),
    );
  }
}

class _SomnolenciaContent extends StatelessWidget {
  const _SomnolenciaContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SomnolenciaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Somnolencia'),
        backgroundColor: const Color(0xFFF35F34),
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: provider.showSurvey
            ? _buildSurvey(context, provider)
            : _buildAlert(context),
      ),
    );
  }

  Widget _buildSurvey(BuildContext context, SomnolenciaProvider provider) {
    return Container(
      key: const ValueKey('survey'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              // Generamos las tarjetas dinámicamente
              ...List.generate(
                provider.preguntasActivas.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildQuestionCard(context, i, provider),
                ),
              ),

              const SizedBox(height: 16),
              _buildSubmitButton(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    int index,
    SomnolenciaProvider provider,
  ) {
    // Definimos el tipo explícito para evitar warnings de import
    PreguntaConfig pregunta = provider.preguntasActivas[index];
    bool? respuestaUsuario = provider.userAnswers[index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: respuestaUsuario != null
              ? const Color(0xFFF35F34).withOpacity(0.3)
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF35F34).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF35F34),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pregunta.texto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnswerButton(
                  'Sí',
                  Icons.check_circle_outline,
                  respuestaUsuario == true,
                  () => provider.setAnswer(index, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnswerButton(
                  'No',
                  Icons.cancel_outlined,
                  respuestaUsuario == false,
                  () => provider.setAnswer(index, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF35F34) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF35F34) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    SomnolenciaProvider provider,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: provider.allQuestionsAnswered
              ? [
                  const Color(0xFFF35F34),
                  const Color.fromARGB(255, 185, 120, 104),
                ]
              : [Colors.grey.shade400, Colors.grey.shade500],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: provider.allQuestionsAnswered
            ? [
                BoxShadow(
                  color: const Color(0xFFF35F34).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (!provider.allQuestionsAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor responde todas las preguntas'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          final aprobado = provider.submitSurvey();

          if (aprobado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Test Aprobado'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Alerta: Estado NO RECOMENDADO PARA CONDUCIR.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Enviar Encuesta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(BuildContext context) {
    return Container(
      key: const ValueKey('alert'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Alerta de Somnolencia!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los resultados indican un nivel de somnolencia elevado. Por favor, no continúe con sus tareas y busque descanso.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF35F34),
                        Color.fromARGB(255, 185, 120, 104),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF35F34).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Volver',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.bed_outlined, size: 48, color: Color(0xFFF35F34)),
          const SizedBox(height: 16),
          const Text(
            'Encuesta de Somnolencia',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF35F34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor responde las siguientes preguntas sobre tu estado de alerta',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
