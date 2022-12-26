import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

enum _SizeType { top, bottom }

extension _SizeTypeExtension on _SizeType {
  List<String> sizesFor({Gender? gender}) {
    switch (this) {
      case _SizeType.top:
        return [
          'XXS',
          'XS',
          'S',
          'M',
          'L',
          'XL',
          'XXL',
          'XXXL',
          '4XL',
          '5XL',
          '6XL',
          '7XL',
          '8XL',
          '9XL',
          '10XL',
          '11XL',
          '12XL'
        ];
      case _SizeType.bottom:
        return gender == Gender.female
            ? [
                '0',
                '2',
                '4',
                '6',
                '8',
                '10',
                '12',
                '14',
                '16',
                '18',
                '20',
                '22',
                '24',
                '26',
                '28',
                '30',
                '32',
                '34',
                '36'
              ]
            : [
                '24',
                '25',
                '26',
                '27',
                '28',
                '29',
                '30',
                '31',
                '32',
                '33',
                '34',
                '35',
                '36',
                '37',
                '38',
                '40',
                '42',
                '44',
                '46',
                '48',
                '50',
                '52',
                '54',
                '56',
                '58',
                '60',
                '62',
                '64',
                '66',
                '68',
                '70',
                '72',
                '74',
                '76',
                '78',
                '80',
                '82',
                '84'
              ];
    }
  }

  String title() {
    switch (this) {
      case _SizeType.top:
        return 'Choose shirt/top size';
      case _SizeType.bottom:
        return 'Choose pants/shorts size';
    }
  }
}

class QuestionaryPage extends StatefulWidget {
  final Gender? gender;
  final MeasurementSystem? selectedMeasurementSystem;
  final MeasurementResults? measurement;

  const QuestionaryPage({
    Key? key,
    this.gender,
    this.selectedMeasurementSystem,
    this.measurement,
  }) : super(key: key);

  @override
  _QuestionaryPageState createState() => _QuestionaryPageState();
}

class _QuestionaryPageState extends State<QuestionaryPage> {
  Map<_SizeType, String> selectedSizes = {};

  void _moveToNextPage() {
    widget.measurement?.selectedTopSize = selectedSizes[_SizeType.top];
    widget.measurement?.selectedBottomSize = selectedSizes[_SizeType.bottom];

    if (SessionParameters().selectedUser == UserType.endWearer) {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => ChooseCaptureModePage(
                  argument: ChooseCaptureModePageArguments(
                      gender: widget.gender, measurement: widget.measurement))));
    } else {
      SessionParameters().captureMode = CaptureMode.withFriend;
      logger.i('${Application.isProMode}');
      if (Application.isProMode) {
        Navigator.pushNamed(context, CameraCapturePage.route,
            arguments: CameraCapturePageArguments(
                photoType: PhotoType.front,
                measurement: widget.measurement,
                frontPhoto: null,
                sidePhoto: null));
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) =>
                    HowTakePhotoPage(gender: widget.gender, measurements: widget.measurement)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget optionWith({_SizeType? type}) {
      var values = type?.sizesFor(gender: widget.gender);
      var title = type?.title();
      var selected = selectedSizes != null ? selectedSizes[type] : null;

      List<DropdownMenuItem<String>>? menuItems() {
        return values
            ?.map((String value) => DropdownMenuItem<String>(
                child: Padding(
                    padding: EdgeInsets.only(left: 14, right: 14),
                    child: Text(
                      value,
                      style: TextStyle(
                          color: value == selected
                              ? SessionParameters().mainFontColor
                              : SessionParameters().mainFontColor.withOpacity(0.65)),
                    )),
                value: value))
            .toList();
      }

      ;

      Widget _hint() {
        return Padding(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: Text(
                'Choose ${SessionParameters().selectedUser == UserType.endWearer ? 'your' : ''} size',
                style: TextStyle(
                    color: HexColor.fromHex('#6B6B6B'),
                    fontSize: 14,
                    fontWeight: FontWeight.normal)));
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title ?? '',
                style: TextStyle(
                    color: SessionParameters().mainFontColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start),
            SizedBox(height: 11),
            SizedBox(
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6), color: Colors.white.withOpacity(0.1)),
                child: DropdownButton(
                  value: selected,
                  hint: _hint(),
                  iconEnabledColor: SessionParameters().mainFontColor,
                  dropdownColor: Color.fromRGBO(35, 35, 36, 1),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: menuItems(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSizes[type!] = newValue as String;
                    });
                  },
                ),
              ),
            )
          ],
        ),
      );
    }

    var container = Padding(
        padding: EdgeInsets.only(left: 12, right: 12, top: 35, bottom: 12),
        child: Column(
          children: [
            optionWith(type: _SizeType.top),
            optionWith(type: _SizeType.bottom),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  child: MaterialButton(
                    disabledColor: SessionParameters().disableColor,
                    onPressed: (selectedSizes != null && selectedSizes.length > 1)
                        ? _moveToNextPage
                        : null,
                    child: CustomText.withColor(
                        'NEXT',
                        (selectedSizes != null && selectedSizes.length > 1)
                            ? Colors.white
                            : SessionParameters().disableTextColor),
                    color: SessionParameters().selectionColor,
                    height: 50,
                    // padding: EdgeInsets.only(left: 12, right: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    // padding: EdgeInsets.all(4),
                  ),
                ),
              ),
            )
          ],
        ));

    String titleForm =
        SessionParameters().selectedUser == UserType.endWearer ? 'do you' : 'does End-wearer';
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            //children align to center.
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(right: 56),
                      child: Container(
                          child: Text('What size $titleForm usually wear?',
                              textAlign: TextAlign.center, maxLines: 3))))
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}
