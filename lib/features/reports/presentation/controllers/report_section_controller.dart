import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/report_section.dart';

final reportSectionsProvider = StateNotifierProvider.family<ReportSectionController, List<ReportSection>, String>((ref, siteId) {
  return ReportSectionController(siteId);
});

class ReportSectionController extends StateNotifier<List<ReportSection>> {
  final String siteId;
  static const String _keyPrefix = 'report_sections_';

  ReportSectionController(this.siteId) : super([]) {
    _loadSections();
  }

  String get _storageKey => '$_keyPrefix$siteId';

  Future<void> _loadSections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final sections = jsonList.map((json) => ReportSection.fromJson(json)).toList();
        state = sections;
      } catch (e) {
        // Fallback to empty list on parsing error
        state = [];
      }
    }
  }

  Future<void> _saveSections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((section) => section.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_storageKey, jsonString);
  }

  void addSection(ReportSection section) {
    state = [...state, section];
    _saveSections();
  }

  void removeSection(String id) {
    state = state.where((section) => section.id != id).toList();
    _saveSections();
  }
}
