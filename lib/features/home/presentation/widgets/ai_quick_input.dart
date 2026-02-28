import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:site_project_tracker/features/expenses/domain/entities/expense.dart';
import 'package:site_project_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:site_project_tracker/features/home/domain/entities/llm_parsed_expense.dart';
import 'package:site_project_tracker/features/home/presentation/controller/ai_quick_input_state.dart';
import 'package:site_project_tracker/features/home/presentation/controller/providers.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/widgets/animated_gradient_container.dart';
import '../../../../core/widgets/bouncing_button.dart';
import '../../../../core/utils/logger.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/controllers/category_controller.dart';
import 'package:site_project_tracker/features/sites/settings/domain/entities/category.dart';
import 'package:site_project_tracker/features/projects/presentation/controllers/project_controller.dart';

import 'package:provider/provider.dart' as provider;

// --- Chat Models ---
enum ChatSender { user, ai }

abstract class ChatMessage {
  final String id;
  final ChatSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.timestamp,
  });
}

class UserMessage extends ChatMessage {
  final String text;

  UserMessage({
    required String id,
    required this.text,
    required DateTime timestamp,
  }) : super(id: id, sender: ChatSender.user, timestamp: timestamp);
}

class AIMessage extends ChatMessage {
  final LLMExpenseDraft? draft;
  final String? error;
  bool isSaved;

  AIMessage({
    required String id,
    this.draft,
    this.error,
    this.isSaved = false,
    required DateTime timestamp,
  }) : super(id: id, sender: ChatSender.ai, timestamp: timestamp);

  bool get hasError => error != null;
}

class AIQuickInput extends ConsumerStatefulWidget {
  const AIQuickInput({super.key});

  @override
  ConsumerState<AIQuickInput> createState() => _AIQuickInputState();
}

class _AIQuickInputState extends ConsumerState<AIQuickInput> {
  final _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final ScrollController _scrollController = ScrollController();

  bool _isListening = false;
  final List<ChatMessage> _messages = [];

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
      if (mounted) {
        setState(() {
          _hintIndex = (_hintIndex + 1) % _hints.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _speech.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        AppLogger.error('Speech error', error: error, name: 'AI_INPUT');
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

  Future<String?> _resolveSiteId(String? draftSiteId) async {
    if (draftSiteId != null && draftSiteId.isNotEmpty) {
      return draftSiteId;
    }

    final projectController = provider.Provider.of<ProjectController>(
      context,
      listen: false,
    );
    final projects = projectController.projects;

    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No projects available. Please create a project first.',
          ),
        ),
      );
      return null;
    }

    return await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Site'),
        children: projects
            .map(
              (p) => SimpleDialogOption(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                onPressed: () => Navigator.pop(context, p.id),
                child: Text(p.name, style: const TextStyle(fontSize: 16)),
              ),
            )
            .toList(),
      ),
    );
  }

  void _handleSave(AIMessage message) async {
    if (message.draft == null) return;

    final draft = message.draft!;

    // Resolve Site ID (from draft or user selection)
    final siteId = await _resolveSiteId(draft.siteId);
    if (siteId == null) return; // Cancelled or no sites

    // Resolve Category ID from Name if needed
    final categories = ref.read(categoriesProvider(siteId));
    String resolvedCategoryId = draft.categoryId ?? '';

    if (resolvedCategoryId.isNotEmpty) {
      ExpenseCategoryEntity? match;
      try {
        // 1. Try exact ID match
        match = categories.firstWhere((c) => c.id == resolvedCategoryId);
      } catch (_) {
        try {
          // 2. Try case-insensitive name match
          match = categories.firstWhere(
            (c) => c.name.toLowerCase() == resolvedCategoryId.toLowerCase(),
          );
        } catch (_) {
          // 3. Optional: Try partial name match?
          try {
            match = categories.firstWhere(
              (c) => c.name.toLowerCase().contains(
                resolvedCategoryId.toLowerCase(),
              ),
            );
          } catch (_) {
            // No match found
          }
        }
      }

      if (match != null) {
        resolvedCategoryId = match.id;
      }
    }

    // Check if we have enough info to Auto-Save
    final bool isComplete =
        draft.amount != null &&
        draft.categoryId != null &&
        draft.vendorId != null;

    if (isComplete) {
      // Auto Save
      AppLogger.debug(
        'Converting Draft to Expense: ${draft.title}, Amount: ${draft.amount}',
        name: 'AI_INPUT',
      );

      final deviceId = await ref
          .read(localStorageServiceProvider)
          .getDeviceId();

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: draft.title ?? 'Unknown',
        amount: draft.amount ?? 0,
        siteId: siteId,
        categoryId: resolvedCategoryId,
        vendor: draft.vendorId ?? '',
        date: draft.date ?? DateTime.now(),
        remarks: draft.remarks,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
        deviceId: deviceId,
        isPaymentCompleted: false,
      );

      AppLogger.debug(
        'Expense added successfully: ${expense.title}, ${expense.amount}, ${expense.siteId}, ${expense.categoryId}, ${expense.vendor}, ${expense.date}, ${expense.remarks}, ${expense.deviceId}, ${expense.isPaymentCompleted}',
        name: 'AI_INPUT',
      );

      await ref.read(expenseControllerProvider.notifier).addExpense(expense);

      // Invalidate the project expenses provider so list screens update
      ref.invalidate(projectExpensesProvider(siteId));

      setState(() {
        message.isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Incomplete -> Open Add Expense Sheet with resolved siteId
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: AddExpenseSheet(siteId: siteId, initialDraft: draft),
        ),
      );

      if (result == true) {
        setState(() {
          message.isSaved = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen to state changes from the LLM controller
    ref.listen<LLMInputState>(llmInputControllerProvider, (previous, next) {
      next.whenOrNull(
        success: (draft) {
          AppLogger.debug('API Response Received: $draft', name: 'AI_INPUT');
          AppLogger.debug(
            'Draft Content: Title="${draft.title}", Amount=${draft.amount}, '
            'Site="${draft.siteId}", Category="${draft.categoryId}", Vendor="${draft.vendorId}"',
            name: 'AI_INPUT',
          );
          setState(() {
            _messages.add(
              AIMessage(
                id: DateTime.now().toString(),
                draft: draft,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        },
        error: (message) {
          AppLogger.error('API Error: $message', name: 'AI_INPUT');
          setState(() {
            _messages.add(
              AIMessage(
                id: DateTime.now().toString(),
                error: message,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        },
      );
    });

    final state = ref.watch(llmInputControllerProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
    final hasMessages = _messages.isNotEmpty || isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: hasMessages
          ? MediaQuery.of(context).size.height * 0.5
          : math.max(240.0, MediaQuery.of(context).size.height * 0.25),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // --- Header ---
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
                        color: _isListening ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: _toggleListening,
                    ),
                  ),
                ],
              ),
              if (hasMessages)
                const Divider(color: Colors.white24, height: 24)
              else
                const Spacer(),

              // --- Chat Area ---
              if (hasMessages)
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: _messages.length + (isLoading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        // Loading indicator bubble
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }

                      final msg = _messages[index];
                      final isUser = msg.sender == ChatSender.user;

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isUser
                                        ? const Radius.circular(16)
                                        : Radius.zero,
                                    bottomRight: isUser
                                        ? Radius.zero
                                        : const Radius.circular(16),
                                  ),
                                ),
                                child: _buildMessageContent(msg),
                              ),
                            ),

                            if (!isUser &&
                                msg is AIMessage &&
                                msg.draft != null &&
                                !msg.hasError) ...[
                              // Save Button on the RIGHT of AI/Response message
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 4,
                                ),
                                child: BouncingButton(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: msg.isSaved
                                          ? Colors.green
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        msg.isSaved
                                            ? LucideIcons.check
                                            : LucideIcons.save,
                                        size: 14,
                                        color: msg.isSaved
                                            ? Colors.white
                                            : theme.primaryColor,
                                      ),
                                      onPressed: msg.isSaved
                                          ? null
                                          : () => _handleSave(msg),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 28,
                                        minHeight: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

              if (hasMessages)
                const SizedBox(height: 16)
              else
                const SizedBox(height: 8),

              if (!hasMessages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isListening ? 'Listening...' : 'How can I help you?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // --- Input Area ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
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
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
                          hintText: _isListening
                              ? 'Listening...'
                              : _hints[_hintIndex],
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        onSubmitted: (text) => _onSubmit(ref, text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BouncingButton(
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: isLoading
                            ? null
                            : () => _onSubmit(ref, _controller.text),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

  Widget _buildMessageContent(ChatMessage msg) {
    const textStyle = TextStyle(color: Colors.white, fontSize: 14);

    if (msg is UserMessage) {
      return Text(msg.text, style: textStyle);
    }

    if (msg is AIMessage) {
      if (msg.hasError) {
        return Text(
          'Error: ${msg.error}',
          style: textStyle.copyWith(color: Colors.redAccent),
        );
      }

      if (msg.draft != null) {
        final d = msg.draft!;
        // If it's just a greeting or text-only response (abused title for text)
        if (d.amount == null && d.siteId == null && d.vendorId == null) {
          return Text(d.title ?? '...', style: textStyle);
        }

        // It is an expense draft
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Expense Draft:',
              style: textStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text('Title: ${d.title ?? "N/A"}', style: textStyle),
            Text(
              'Amount: ${d.amount ?? 0}',
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            if (d.remarks != null)
              Text(
                'Memo: ${d.remarks}',
                style: textStyle.copyWith(fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 4),
            // Show status of completeness
            if (!d.isComplete)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Incomplete Info',
                  style: TextStyle(color: Colors.black, fontSize: 10),
                ),
              ),
          ],
        );
      }
    }

    return const SizedBox();
  }

  Future<void> _onSubmit(WidgetRef ref, String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        UserMessage(
          id: DateTime.now().toString(),
          text: text,
          timestamp: DateTime.now(),
        ),
      );
      _controller.clear();
      _scrollToBottom();
    });

    // Trigger sync before AI request to ensure context is up-to-date
    try {
      await ref.read(syncManagerProvider).sync();
    } catch (e) {
      AppLogger.error('Pre-AI sync failed', error: e, name: 'AI_INPUT');
      // Continue anyway
    }

    // Call the controller
    final deviceId = await ref.read(localStorageServiceProvider).getDeviceId();
    ref.read(llmInputControllerProvider.notifier).submit(text, deviceId);
  }
}
