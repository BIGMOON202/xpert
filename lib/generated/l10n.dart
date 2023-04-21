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

  /// `Success`
  String get common_success {
    return Intl.message(
      'Success',
      name: 'common_success',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get common_email {
    return Intl.message(
      'Email',
      name: 'common_email',
      desc: '',
      args: [],
    );
  }

  /// `SMS`
  String get common_sms {
    return Intl.message(
      'SMS',
      name: 'common_sms',
      desc: '',
      args: [],
    );
  }

  /// `Version: {number}`
  String common_store_version_num(Object number) {
    return Intl.message(
      'Version: $number',
      name: 'common_store_version_num',
      desc: '',
      args: [number],
    );
  }

  /// `Update now`
  String get common_update {
    return Intl.message(
      'Update now',
      name: 'common_update',
      desc: '',
      args: [],
    );
  }

  /// `And`
  String get common_and {
    return Intl.message(
      'And',
      name: 'common_and',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get common_continue {
    return Intl.message(
      'Continue',
      name: 'common_continue',
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

  /// `Terms of Use and Privacy Notice`
  String get page_title_terms_and_privacy {
    return Intl.message(
      'Terms of Use and Privacy Notice',
      name: 'page_title_terms_and_privacy',
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

  /// `End-wearer has been added successfully`
  String get text_ew_invite_sent_desc {
    return Intl.message(
      'End-wearer has been added successfully',
      name: 'text_ew_invite_sent_desc',
      desc: '',
      args: [],
    );
  }

  /// `Send invite via`
  String get text_ew_send_invite_via {
    return Intl.message(
      'Send invite via',
      name: 'text_ew_send_invite_via',
      desc: '',
      args: [],
    );
  }

  /// `The SMS invitation with credentials was sent to the user via the provided phone number`
  String get text_ew_invite_sent_via_sms_desc {
    return Intl.message(
      'The SMS invitation with credentials was sent to the user via the provided phone number',
      name: 'text_ew_invite_sent_via_sms_desc',
      desc: '',
      args: [],
    );
  }

  /// `The email invitation with credentials was sent to the user via the provided email address`
  String get text_ew_invite_sent_via_email_desc {
    return Intl.message(
      'The email invitation with credentials was sent to the user via the provided email address',
      name: 'text_ew_invite_sent_via_email_desc',
      desc: '',
      args: [],
    );
  }

  /// `New update is available`
  String get text_available_updates {
    return Intl.message(
      'New update is available',
      name: 'text_available_updates',
      desc: '',
      args: [],
    );
  }

  /// `The current version of the `
  String get text_update_text_span1 {
    return Intl.message(
      'The current version of the ',
      name: 'text_update_text_span1',
      desc: '',
      args: [],
    );
  }

  /// `XpertFit `
  String get text_update_text_span2 {
    return Intl.message(
      'XpertFit ',
      name: 'text_update_text_span2',
      desc: '',
      args: [],
    );
  }

  /// `is no longer supported. Please `
  String get text_update_text_span3 {
    return Intl.message(
      'is no longer supported. Please ',
      name: 'text_update_text_span3',
      desc: '',
      args: [],
    );
  }

  /// `update the application to the latest version `
  String get text_update_text_span4 {
    return Intl.message(
      'update the application to the latest version ',
      name: 'text_update_text_span4',
      desc: '',
      args: [],
    );
  }

  /// `and enjoy your experience.`
  String get text_update_text_span5 {
    return Intl.message(
      'and enjoy your experience.',
      name: 'text_update_text_span5',
      desc: '',
      args: [],
    );
  }

  /// `I accept Privacy Policy and Terms of Use`
  String get text_accept_privacy_notice {
    return Intl.message(
      'I accept Privacy Policy and Terms of Use',
      name: 'text_accept_privacy_notice',
      desc: '',
      args: [],
    );
  }

  /// `To provide you with a touchless and automated method of capturing your body measurements and assist you in choosing the appropriate size for your body armor, we'd need to collect and process certain information about you. In particular, we collect and process information about your body parameters (which we obtain as a result of processing the photos you provide via XpertFit), your height, weight, and gender.`
  String get text_privacy_notice_span1 {
    return Intl.message(
      'To provide you with a touchless and automated method of capturing your body measurements and assist you in choosing the appropriate size for your body armor, we\'d need to collect and process certain information about you. In particular, we collect and process information about your body parameters (which we obtain as a result of processing the photos you provide via XpertFit), your height, weight, and gender.',
      name: 'text_privacy_notice_span1',
      desc: '',
      args: [],
    );
  }

  /// `We do not store the images you upload to the XpertFit app. Your photos are deleted immediately after processing, during which we receive information about your parameters. When you download and/or use the XpertFit app, you agree to comply with the XpertFit Terms of Use and Privacy Policy.`
  String get text_privacy_notice_span2 {
    return Intl.message(
      'We do not store the images you upload to the XpertFit app. Your photos are deleted immediately after processing, during which we receive information about your parameters. When you download and/or use the XpertFit app, you agree to comply with the XpertFit Terms of Use and Privacy Policy.',
      name: 'text_privacy_notice_span2',
      desc: '',
      args: [],
    );
  }

  /// `This notice provides you with a short overview only and should be read in conjunction with the complete XpertFit `
  String get text_privacy_notice_span3 {
    return Intl.message(
      'This notice provides you with a short overview only and should be read in conjunction with the complete XpertFit ',
      name: 'text_privacy_notice_span3',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get terms_of_use {
    return Intl.message(
      'Terms of Use',
      name: 'terms_of_use',
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
