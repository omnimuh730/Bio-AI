import 'package:flutter/material.dart';
import 'strings/strings_en.dart';
import 'strings/strings_ar.dart';
import 'strings/strings_fr.dart';
import 'strings/strings_es.dart';
import 'strings/strings_ru.dart';
import 'strings/strings_zh.dart';
import 'strings/strings_ko.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale) {
    _initializeStrings();
  }

  void _initializeStrings() {
    switch (locale.languageCode) {
      case 'ar':
        _localizedStrings = stringsAr;
        break;
      case 'fr':
        _localizedStrings = stringsFr;
        break;
      case 'es':
        _localizedStrings = stringsEs;
        break;
      case 'ru':
        _localizedStrings = stringsRu;
        break;
      case 'zh':
        _localizedStrings = stringsZh;
        break;
      case 'ko':
        _localizedStrings = stringsKo;
        break;
      case 'en':
      default:
        _localizedStrings = stringsEn;
    }
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Dashboard screen strings
  String get bioSyncActive => get('bio_sync_active');
  String get helloUser => get('hello_user');
  String get newSuggestionLoaded => get('new_suggestion_loaded');
  String get comingSoon => get('coming_soon');

  // Setup & Dashboard labels
  String get finishSetup => get('finish_setup');
  String get setupDescription => get('setup_description');
  String get continueLabel => get('continue');
  String get liveVitals => get('live_vitals');
  String get vitalsSynced => get('vitals_synced');
  String get aiSuggestion => get('ai_suggestion');
  String get dailyFuel => get('daily_fuel');
  String get quickLog => get('quick_log');
  String get viewHistory => get('view_history');
  String get refresh => get('refresh');

  // Meal / suggestion
  String get whyThis => get('why_this');
  String eatThisCals(int cals) =>
      get('eat_this').replaceFirst('{cals}', cals.toString());

  // General strings
  String get hello => get('hello');
  String get welcome => get('welcome');
  String get logout => get('logout');
  String get settings => get('settings');
  String get profile => get('profile');
  String get about => get('about');
  String get version => get('version');
  String get language => get('language');
  String get english => get('english');
  String get arabic => get('arabic');
  String get save => get('save');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get edit => get('edit');
  String get add => get('add');
  String get loading => get('loading');
  String get error => get('error');
  String get success => get('success');
  String get tryAgain => get('try_again');

  // Health & Nutrition
  String get calories => get('calories');
  String get protein => get('protein');
  String get carbs => get('carbs');
  String get fat => get('fat');
  String get water => get('water');
  String get hydration => get('hydration');
  String get sleepScore => get('sleep_score');
  String get heartRate => get('heart_rate');
  String get steps => get('steps');
  String get stress => get('stress');
  String get stressLevel => get('stress_level');

  // Meal & Food
  String get meal => get('meal');
  String get meals => get('meals');
  String get breakfast => get('breakfast');
  String get lunch => get('lunch');
  String get dinner => get('dinner');
  String get snack => get('snack');
  String get logMeal => get('log_meal');
  String get mealSuggestion => get('meal_suggestion');
  String get recipe => get('recipe');
  String get ingredients => get('ingredients');
  String get portion => get('portion');
  String get servings => get('servings');

  // Analytics & Time
  String get analytics => get('analytics');
  String get today => get('today');
  String get week => get('week');
  String get month => get('month');
  String get year => get('year');
  String get daily => get('daily');
  String get weekly => get('weekly');
  String get monthly => get('monthly');
  String get history => get('history');
  String get trend => get('trend');

  // Pantry & Planner
  String get pantry => get('pantry');
  String get planner => get('planner');
  String get shopping => get('shopping');
  String get leftover => get('leftover');
  String get cookingMode => get('cooking_mode');
  String get eatingOut => get('eating_out');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'ar',
      'fr',
      'es',
      'ru',
      'zh',
      'ko',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
