// import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
// import 'package:tuple/tuple.dart';
//
// import '';
// class CustomDateFormatter {
//   static DateFormat apiDateFormat = DateFormat('yyyy-MM-dd\'T\'k:mm:ss\'Z\'');
//   static DateFormat uiDateFormat = DateFormat('dd MMM yyyy');
//   static DateFormat uiTimeFormat = DateFormat('h:mma');
//
//   static Tuple2<String,String> convertToUI({String apiDate}) {
//     var dateTime = DateTime.now();
//     var date = apiDateFormat.parse(apiDate);
//     // var date = apiDateFormat.parse(parsedDate, true).toLocal();
//
//     var offset = dateTime.timeZoneOffset;
//     var hours  = offset.inHours > 0 ? offset.inHours : 1; // For fixing divide by zero error
//     // if (!offset.isNegative) {
//     //   date = date + "+" + offset.inHours.toString().padLeft(2, '0') + ":" + (offset.inMinutes%(hours*60)).toString().padLeft(2, '0');
//     // } else {
//     //   date = date + offset.inHours.toString().padLeft(2, '0') + ":" + (offset.inMinutes%(hours*60)).toString().padLeft(2, '0');
//     // }
//
//     debugPrint("converted $apiDate to $date, offset: $offset");
//     var uiDateStr = uiDateFormat.format(date);
//     var uiTimeStr = uiTimeFormat.format(date);
//     Tuple2<String,String> result = Tuple2(uiDateStr, uiTimeStr);
//     debugPrint("ui converted $date to ${result.item1} ${result.item2}");
//     return result;
//   }
// }