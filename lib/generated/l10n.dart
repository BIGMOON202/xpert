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

  /// `Add`
  String get common_add {
    return Intl.message(
      'Add',
      name: 'common_add',
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

  /// `New end-wearer`
  String get page_title_new_ew {
    return Intl.message(
      'New end-wearer',
      name: 'page_title_new_ew',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get text_phone_number {
    return Intl.message(
      'Phone number',
      name: 'text_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Customer email`
  String get text_customer_email {
    return Intl.message(
      'Customer email',
      name: 'text_customer_email',
      desc: '',
      args: [],
    );
  }

  /// `End-wearer name`
  String get text_ew_name {
    return Intl.message(
      'End-wearer name',
      name: 'text_ew_name',
      desc: '',
      args: [],
    );
  }

  /// `An invitation with credentials was\nsuccessfully sent to the user`
  String get text_ew_invite_sent_desc {
    return Intl.message(
      'An invitation with credentials was\nsuccessfully sent to the user',
      name: 'text_ew_invite_sent_desc',
      desc: '',
      args: [],
    );
  }

  /// `Invite sent successfully`
  String get text_ew_invite_sent {
    return Intl.message(
      'Invite sent successfully',
      name: 'text_ew_invite_sent',
      desc: '',
      args: [],
    );
  }

  /// `Back to event details`
  String get button_back_to_event_detail {
    return Intl.message(
      'Back to event details',
      name: 'button_back_to_event_detail',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get error_smt_wrong {
    return Intl.message(
      'Something went wrong',
      name: 'error_smt_wrong',
      desc: '',
      args: [],
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
