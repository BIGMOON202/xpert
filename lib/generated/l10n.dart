// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `XpertFit`
  String get title {
    return Intl.message(
      'XpertFit',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get common_yes {
    return Intl.message(
      'Yes',
      name: 'common_yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get common_no {
    return Intl.message(
      'No',
      name: 'common_no',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get common_ok {
    return Intl.message(
      'Ok',
      name: 'common_ok',
      desc: '',
      args: [],
    );
  }

  /// `{choose, select, true {What’s your height?} other {End-Wearer’s height?}}`
  String page_title_choose_height_as_ew(Object choose) {
    return Intl.select(
      choose,
      {
        'true': 'What’s your height?',
        'other': 'End-Wearer’s height?',
      },
      name: 'page_title_choose_height_as_ew',
      desc: '',
      args: [choose],
    );
  }

  /// `{choose, select, true {What’s your weight?} other {End-Wearer’s weight?}}`
  String page_title_choose_weight_as_ew(Object choose) {
    return Intl.select(
      choose,
      {
        'true': 'What’s your weight?',
        'other': 'End-Wearer’s weight?',
      },
      name: 'page_title_choose_weight_as_ew',
      desc: '',
      args: [choose],
    );
  }

  /// `{choose, select, true {What’s your clavicle?} other {End-Wearer’s\nmanual clavicle?}}`
  String page_title_choose_clavicle_as_ew(Object choose) {
    return Intl.select(
      choose,
      {
        'true': 'What’s your clavicle?',
        'other': 'End-Wearer’s\nmanual clavicle?',
      },
      name: 'page_title_choose_clavicle_as_ew',
      desc: '',
      args: [choose],
    );
  }

  /// `{choose, select, true {Select your gender} other {Measure an end-wearer}}`
  String page_title_choose_gender_as_ew(Object choose) {
    return Intl.select(
      choose,
      {
        'true': 'Select your gender',
        'other': 'Measure an end-wearer',
      },
      name: 'page_title_choose_gender_as_ew',
      desc: '',
      args: [choose],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
