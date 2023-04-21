import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

enum _TutorialStep { twoPhotos, avatar, recommendations }

extension _TutorialStepExtension on _TutorialStep {
  String get imageName {
    switch (this) {
      case _TutorialStep.twoPhotos:
        return 'tutorial_1.png';
      case _TutorialStep.avatar:
        return 'tutorial_2.png';
      case _TutorialStep.recommendations:
        return 'tutorial_3.png';
    }
  }

  String get title {
    switch (this) {
      case _TutorialStep.twoPhotos:
        return 'Take only';
      case _TutorialStep.avatar:
        return 'Generate a';
      case _TutorialStep.recommendations:
        return 'Get your';
    }
  }

  String get highlitedTitle {
    switch (this) {
      case _TutorialStep.twoPhotos:
        return 'two scans';
      case _TutorialStep.avatar:
        return '3D avatar';
      case _TutorialStep.recommendations:
        return 'size recommendation';
    }
  }

  String get subtitle {
    return '';
  }

  // int get indexTitle {
  //   switch (this) {
  //     case _TutorialStep.twoPhotos: return 'tutorial_1.png';
  //     case _TutorialStep.avatar:  return 'tutorial_2.png';
  //     case _TutorialStep.recommendations:  return 'tutorial_3.png';
  //   }
  // }
}

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  _TutorialStep selectedStep = _TutorialStep.twoPhotos;
  late PageController _controller;
  bool _markedAsDoNotShow = false;
  SharedPreferences? prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSettings();

    _controller = PageController();
  }

  void initSettings() async {
    this.prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _closeWindow() {
      Navigator.pop(context);
    }

    void _skipPages() {
      //move to flow
      _closeWindow();
    }

    void _moveToNextPage() {
      if (selectedStep != _TutorialStep.recommendations) {
        _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        prefs?.setBool('intro_seen', _markedAsDoNotShow); // for string value
        _closeWindow();
      }
    }

    Widget buildPaginationWidget() {
      Widget dotFor({_TutorialStep? step}) {
        var selected = step == this.selectedStep;
        return AnimatedContainer(
          width: 24,
          height: 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(2.5)),
              color: selected
                  ? SessionParameters().selectionColor
                  : SessionParameters().mainFontColor.withOpacity(0.1)),
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          dotFor(step: _TutorialStep.twoPhotos),
          SizedBox(width: 6),
          dotFor(step: _TutorialStep.avatar),
          SizedBox(width: 6),
          dotFor(step: _TutorialStep.recommendations),
        ],
      );
    }

    Widget buildPageFor({_TutorialStep? step}) {
      return Padding(
          padding: EdgeInsets.all(38),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: ResourceImage.imageWithName(step?.imageName ?? '')),
              SizedBox(height: 34),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(step?.title ?? '',
                    style: TextStyle(
                        color: SessionParameters().mainFontColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: SessionParameters().mainFontColor),
                    child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(step?.highlitedTitle ?? '',
                            style: TextStyle(
                                color: SessionParameters().selectionColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))))
              ]),
              Padding(
                  padding: EdgeInsets.only(top: 8, left: 37, right: 37, bottom: 20),
                  child: Text(step?.subtitle ?? '',
                      style: TextStyle(
                          color: SessionParameters().mainFontColor.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.normal)))
            ],
          ));
    }

    var container = Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Container(
                      // color: Colors.orange,
                      child: AspectRatio(
                          aspectRatio: 1.2,
                          child: Container(
                              child: PageView(
                            controller: _controller,
                            onPageChanged: (index) => {
                              setState(() {
                                selectedStep = _TutorialStep.values[index];
                              })
                            },
                            children: [
                              buildPageFor(step: _TutorialStep.twoPhotos),
                              buildPageFor(step: _TutorialStep.avatar),
                              buildPageFor(step: _TutorialStep.recommendations)
                            ],
                          ))))),
              buildPaginationWidget()
            ]),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
              visible: selectedStep == _TutorialStep.recommendations,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white),
                    child: Checkbox(
                      onChanged: (newValue) {
                        setState(() {
                          _markedAsDoNotShow = newValue!;
                        });
                      },
                      activeColor: HexColor.fromHex('1E7AE4'),
                      checkColor: Colors.white,
                      value: _markedAsDoNotShow,
                    ),
                  ),
                  Text(
                    'Do not show me this again',
                    style: TextStyle(
                        color: SessionParameters().mainFontColor,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )
                ],
              )),
          SizedBox(height: 16),
          Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: SafeArea(
                child: Container(
                    width: double.infinity,
                    child: MaterialButton(
                      splashColor: Colors.transparent,
                      elevation: 0,
                      disabledColor: SessionParameters().disableColor,
                      onPressed: _moveToNextPage,
                      textColor: Colors.white,
                      child: CustomText(
                          selectedStep == _TutorialStep.recommendations ? 'GOT IT' : 'NEXT'),
                      color: SessionParameters().selectionColor,
                      height: 50,
                      // padding: EdgeInsets.only(left: 12, right: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      // padding: EdgeInsets.all(4),
                    )),
              ))
        ])
      ],
    );

    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          actions: [
            MaterialButton(
              splashColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Text('SKIP'),
              textColor: SessionParameters().mainFontColor,
              onPressed: _skipPages,
              color: SessionParameters().mainBackgroundColor,
            )
          ],
          centerTitle: true,
          title: Text(
            'How it works',
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}
