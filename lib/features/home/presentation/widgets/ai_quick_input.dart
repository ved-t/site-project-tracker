import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/features/home/presentation/controller/ai_quick_input_state.dart';
import 'package:site_project_tracker/features/home/presentation/controller/providers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/widgets/animated_gradient_container.dart';
import '../../../../core/widgets/bouncing_button.dart';

class AIQuickInput extends ConsumerStatefulWidget {
  const AIQuickInput({super.key});

  @override
  ConsumerState<AIQuickInput> createState() => _AIQuickInputState();
}

class _AIQuickInputState extends ConsumerState<AIQuickInput> {
  final _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;

  final List<String> _hints = const [
    'Ask me anything…',
    'Add quick expense',
    'Paid 500 for cement',
    'Show last week’s expenses',
    'Get project reports',
  ];

  int _hintIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startHintRotation();
  }

  void _startHintRotation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_controller.text.isNotEmpty || _isListening) return;
      setState(() {
        _hintIndex = (_hintIndex + 1) % _hints.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() => _isListening = false);
      },
    );

    if (!available) return;

    setState(() => _isListening = true);

    await _speech.listen(
      listenMode: ListenMode.dictation,
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to state changes
    ref.listen<LLMInputState>(llmInputControllerProvider, (previous, next) {
      next.whenOrNull(
        success: (draft) {
          final encoder = const JsonEncoder.withIndent('  ');
          final formattedJson = encoder.convert(draft.toJson());

          setState(() {
            _controller.text = formattedJson;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense Parsed Successfully!')),
          );
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $message'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    final state = ref.watch(llmInputControllerProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      child: AnimatedGradientContainer(
        borderRadius: 24,
        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  BouncingButton(
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                      onPressed: _toggleListening,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              state.maybeWhen(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                orElse: () => Text(
                  _isListening ? 'Listening...' : 'How can I help you?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Input box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          filled: false,
                          hintText: _hints[_hintIndex],
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        onSubmitted: (text) => _onSubmit(ref, text),
                      ),
                    ),
                    BouncingButton(
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _onSubmit(ref, _controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit(WidgetRef ref, String text) {
    if (text.trim().isEmpty) return;
    debugPrint('[AI INPUT]: $text');

    // Call the controller
    ref.read(llmInputControllerProvider.notifier).submit(text);
  }
}
