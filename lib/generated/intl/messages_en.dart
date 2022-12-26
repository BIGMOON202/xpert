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
        "title": MessageLookupByLibrary.simpleMessage("XpertFit")
      };
}
