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

  static String m0(choose) => "${Intl.select(choose, {
            'true': 'What’s your clavicle?',
            'other': 'End-Wearer’s\nmanual clavicle?',
          })}";

  static String m1(choose) => "${Intl.select(choose, {
            'true': 'Select your gender',
            'other': 'Measure an end-wearer',
          })}";

  static String m2(choose) => "${Intl.select(choose, {
            'true': 'What’s your height?',
            'other': 'End-Wearer’s height?',
          })}";

  static String m3(choose) => "${Intl.select(choose, {
            'true': 'What’s your weight?',
            'other': 'End-Wearer’s weight?',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "button_back_to_event_detail":
            MessageLookupByLibrary.simpleMessage("Back to event details"),
        "common_add": MessageLookupByLibrary.simpleMessage("Add"),
        "common_no": MessageLookupByLibrary.simpleMessage("No"),
        "common_ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "common_yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "error_smt_wrong":
            MessageLookupByLibrary.simpleMessage("Something went wrong"),
        "page_title_choose_clavicle_as_ew": m0,
        "page_title_choose_gender_as_ew": m1,
        "page_title_choose_height_as_ew": m2,
        "page_title_choose_weight_as_ew": m3,
        "page_title_new_ew":
            MessageLookupByLibrary.simpleMessage("New end-wearer"),
        "text_customer_email":
            MessageLookupByLibrary.simpleMessage("Customer email"),
        "text_ew_invite_sent":
            MessageLookupByLibrary.simpleMessage("Invite sent successfully"),
        "text_ew_invite_sent_desc": MessageLookupByLibrary.simpleMessage(
            "An invitation with credentials was\nsuccessfully sent to the user"),
        "text_ew_name": MessageLookupByLibrary.simpleMessage("End-wearer name"),
        "text_phone_number":
            MessageLookupByLibrary.simpleMessage("Phone number"),
        "title": MessageLookupByLibrary.simpleMessage("XpertFit")
      };
}
