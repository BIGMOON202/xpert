
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/main.dart';

class ChooseCaptureModePageArguments {
  Gender gender;
  MeasurementResults measurement;
  ChooseCaptureModePageArguments({this.gender, this.measurement});
}

class ChooseCaptureModePage extends StatefulWidget {
  static var route = '/choose_capture_mode';
  final ChooseCaptureModePageArguments argument;
  ChooseCaptureModePage({Key key, this.argument}): super(key:key);

  @override
  _ChooseCaptureModePageState createState() => _ChooseCaptureModePageState();
}

class _ChooseCaptureModePageState extends State<ChooseCaptureModePage> {

  CaptureMode _selectedMode;

  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  static Color  _selectedColor = Colors.white.withOpacity(0.1);

  Gender _passedGender;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _passedGender = widget.argument.gender;
  }

  void _selectMode(CaptureMode newMode) {
    setState(() {
      _selectedMode = newMode;
    });
  }

  void _moveToNextPage() {
    SessionParameters().captureMode = _selectedMode;
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
        HowTakePhotoPage(gender: _passedGender, measurements: widget.argument.measurement)
    ));
  }

  @override
  Widget build(BuildContext context) {

    var nextButton = Visibility(
        visible: _selectedMode != null,
        child:Align(
            alignment: Alignment.bottomCenter,
            child:SafeArea(child: 
            Padding(padding: EdgeInsets.only(left:12, right: 12),
                child:Container(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: () {
                    _moveToNextPage();
                    print('next button pressed');
                  },
                  textColor: Colors.white,
                  child: CustomText('NEXT'),
                  color: HexColor.fromHex('1E7AE4'),
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),

                  ),
                  // padding: EdgeInsets.all(4),
                ))),
            )));

    var titleText = Padding(
      padding: EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 0),
      child: Text('How should we proceed?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16), textAlign: TextAlign.center,),
    );


    var buttonsContainer = Container(
      height: 182,
      padding: EdgeInsets.all(12),
      child:Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child:Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child:FlatButton(
                    onPressed: () {
                      _selectMode(CaptureMode.withFriend);
                    },

                    color: _selectedMode == CaptureMode.withFriend ? _selectedColor : _backgroundColor,
                    highlightColor: Colors.grey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            width: 95,
                            height: 61,
                            child:ResourceImage.imageWithName(_selectedMode == CaptureMode.withFriend ? CaptureMode.withFriend.selectedImageName() : CaptureMode.withFriend.unselectedImageName())),
                        SizedBox(height: 24),
                        Text('With a friend', style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ))),
          Expanded(
              child:FlatButton(
                onPressed: (){
                  _selectMode(CaptureMode.handsFree);
                },
                color: _selectedMode == CaptureMode.handsFree ? _selectedColor : _backgroundColor,
                highlightColor: Colors.grey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    SizedBox(
                        width: 45,
                        height:61,
                        child:ResourceImage.imageWithName(_selectedMode == CaptureMode.handsFree ?
                        _passedGender.selectedImageName() :_passedGender.unselectedImageName())),
                    SizedBox(height: 24),
                    Text('Hands-free', style: TextStyle(color: Colors.white),),
                  ],
                ),
              )),
        ],
      ),
    );

    var container = Column(
      children: [
        Flexible(
          flex: 1,
            child:
          Container(
            child: Center(
                child: Padding(padding: EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)
                        ),
                        color: Colors.white.withAlpha(10)
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                      child: Row(
                        children: [SizedBox(width: 30, height: 50, child: ResourceImage.imageWithName('ic_security-on.png'),),
                          SizedBox(width: 16,),
                          Flexible(child:Text('We take your privacy very seriously and delete your photos after we process your measurements',
                              maxLines: 4,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12)))],
                      ),
                    ),
                  ),

                ),
            ),
          )
        ),
        Flexible(flex: 1,
            child:
        Container(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
              child:Text('You can either ask someone to help you or take photos with the guidance of our Hands-free mode.',
                maxLines: 4,
                textAlign:  TextAlign.center,
                style: TextStyle(color: HexColor.fromHex('898A9D'), fontWeight: FontWeight.normal, fontSize: 14)),
          )),
        )),
        Flexible(flex: 4,
            child:Stack(children:
            [Container(
              child: Column(
                children: [titleText,
                  buttonsContainer,
                ],
              ),),
              nextButton
            ]))
      ],
    );


    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Let\'s take two photos'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: SessionParameters().mainBackgroundColor,
      body: container,
    );


    return scaffold;
  }
}