import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _birthChartKey = 'birth_chart';
  static const String _subscriptionKey = 'subscription_tier';
  static const String _aiProviderKey = 'ai_provider';
  static const String _usageKey = 'usage_stats';
  
  // Birth Chart
  static Future<void> saveBirthChart(Map<String, dynamic> chartData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthChartKey, json.encode(chartData));
  }
  
  static Future<Map<String, dynamic>?> getBirthChart() async {
    final prefs = await SharedPreferences.getInstance();
    final chartString = prefs.getString(_birthChartKey);
    if (chartString != null) {
      return json.decode(chartString) as Map<String, dynamic>;
    }
    return null;
  }
  
  static Future<void> deleteBirthChart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_birthChartKey);
  }
  
  // Subscription
  static Future<void> saveSubscriptionTier(String tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionKey, tier);
  }
  
  static Future<String> getSubscriptionTier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subscriptionKey) ?? 'free';
  }
  
  // AI Provider
  static Future<void> saveAIProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiProviderKey, provider);
  }
  
  static Future<String> getAIProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiProviderKey) ?? 'gemini';
  }
  
  // Usage Statistics
  static Future<void> saveUsageStats(Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageKey, json.encode(stats));
  }
  
  static Future<Map<String, dynamic>> getUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsString = prefs.getString(_usageKey);
    if (statsString != null) {
      return json.decode(statsString) as Map<String, dynamic>;
    }
    return {
      'identifications': 0,
      'lastReset': DateTime.now().toIso8601String(),
    };
  }
  
  static Future<void> incrementIdentifications() async {
    final stats = await getUsageStats();
    stats['identifications'] = (stats['identifications'] as int) + 1;
    await saveUsageStats(stats);
  }
  
  static Future<void> resetMonthlyUsage() async {
    await saveUsageStats({
      'identifications': 0,
      'lastReset': DateTime.now().toIso8601String(),
    });
  }
}