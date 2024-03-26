// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(number) => "Version: ${number}";

  static String m1(choose) => "${Intl.select(choose, {
            'true': 'What’s your clavicle?',
            'other': 'End-Wearer’s\nmanual clavicle?',
          })}";

  static String m2(choose) => "${Intl.select(choose, {
            'true': 'Select your gender',
            'other': 'Measure an end-wearer',
          })}";

  static String m3(choose) => "${Intl.select(choose, {
            'true': 'What’s your height?',
            'other': 'End-Wearer’s height?',
          })}";

  static String m4(choose) => "${Intl.select(choose, {
            'true': 'What’s your weight?',
            'other': 'End-Wearer’s weight?',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "button_back_to_event_detail":
            MessageLookupByLibrary.simpleMessage("Back to event details"),
        "common_add": MessageLookupByLibrary.simpleMessage("Add"),
        "common_and": MessageLookupByLibrary.simpleMessage("And"),
        "common_continue": MessageLookupByLibrary.simpleMessage("Continue"),
        "common_email": MessageLookupByLibrary.simpleMessage("Email"),
        "common_no": MessageLookupByLibrary.simpleMessage("No"),
        "common_ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "common_sms": MessageLookupByLibrary.simpleMessage("SMS"),
        "common_store_version_num": m0,
        "common_success": MessageLookupByLibrary.simpleMessage("Success"),
        "common_update": MessageLookupByLibrary.simpleMessage("Update now"),
        "common_yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "error_smt_wrong":
            MessageLookupByLibrary.simpleMessage("Something went wrong"),
        "page_title_choose_clavicle_as_ew": m1,
        "page_title_choose_gender_as_ew": m2,
        "page_title_choose_height_as_ew": m3,
        "page_title_choose_weight_as_ew": m4,
        "page_title_new_ew":
            MessageLookupByLibrary.simpleMessage("New end-wearer"),
        "page_title_terms_and_privacy": MessageLookupByLibrary.simpleMessage(
            "Terms of Use and Privacy Notice"),
        "privacy_policy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "terms_of_use": MessageLookupByLibrary.simpleMessage("Terms of Use"),
        "text_accept_privacy_notice": MessageLookupByLibrary.simpleMessage(
            "I accept Privacy Policy and Terms of Use"),
        "text_available_updates":
            MessageLookupByLibrary.simpleMessage("New update is available"),
        "text_customer_email":
            MessageLookupByLibrary.simpleMessage("Customer email"),
        "text_ew_invite_sent_desc": MessageLookupByLibrary.simpleMessage(
            "End-wearer has been added successfully"),
        "text_ew_invite_sent_via_email_desc": MessageLookupByLibrary.simpleMessage(
            "The email invitation with credentials was sent to the user via the provided email address"),
        "text_ew_invite_sent_via_sms_desc": MessageLookupByLibrary.simpleMessage(
            "The SMS invitation with credentials was sent to the user via the provided phone number"),
        "text_ew_name": MessageLookupByLibrary.simpleMessage("End-wearer name"),
        "text_ew_send_invite_via":
            MessageLookupByLibrary.simpleMessage("Send invite via"),
        "text_phone_number":
            MessageLookupByLibrary.simpleMessage("Phone number"),
        "text_privacy_notice_span1": MessageLookupByLibrary.simpleMessage(
            "To provide you with a touchless and automated method of capturing your body measurements and assist you in choosing the appropriate size for your body armor, we\'d need to collect and process certain information about you. In particular, we collect and process information about your body parameters (which we obtain as a result of processing the photos you provide via XpertFit), your height, weight, and gender."),
        "text_privacy_notice_span2": MessageLookupByLibrary.simpleMessage(
            "We do not store the images you upload to the XpertFit app. Your photos are deleted immediately after processing, during which we receive information about your parameters. When you download and/or use the XpertFit app, you agree to comply with the XpertFit Terms of Use and Privacy Policy."),
        "text_privacy_notice_span3": MessageLookupByLibrary.simpleMessage(
            "This notice provides you with a short overview only and should be read in conjunction with the complete XpertFit "),
        "text_update_text_span1":
            MessageLookupByLibrary.simpleMessage("The current version of the "),
        "text_update_text_span2":
            MessageLookupByLibrary.simpleMessage("XpertFit "),
        "text_update_text_span3": MessageLookupByLibrary.simpleMessage(
            "is no longer supported. Please "),
        "text_update_text_span4": MessageLookupByLibrary.simpleMessage(
            "update the application to the latest version "),
        "text_update_text_span5":
            MessageLookupByLibrary.simpleMessage("and enjoy your experience."),
        "text_welcome_footer": MessageLookupByLibrary.simpleMessage(
            "To complete the self-sizing process, you should check your e-mail and/or SMS Text message for your invitation to self-size. The message will provide the sign-on ID and 6-digit security code you need to begin."),
        "text_welcome_header": MessageLookupByLibrary.simpleMessage(
            "We are glad you using XpertFit. You have selected to size yourself. Self-sizing is only available to persons that were invited to size themselves."),
        "text_welcome_title": MessageLookupByLibrary.simpleMessage("Welcome!"),
        "title": MessageLookupByLibrary.simpleMessage("XpertFit")
      };
}
