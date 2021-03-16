
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/RulerWeightPage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Screens/RulerPage.dart';

class ChooseGenderPageArguments{
  MeasurementResults measurement;
  ChooseGenderPageArguments(this.measurement);
}


class ChooseGenderPage extends StatefulWidget {

  static var route = '/choose_gender';
  final ChooseGenderPageArguments argument;
  ChooseGenderPage({Key key, this.argument}): super(key:key);

  @override
  _ChooseGenderPageState createState() => _ChooseGenderPageState();
}

class _ChooseGenderPageState extends State<ChooseGenderPage> {


  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  static Color  _selectedColor = Colors.white.withOpacity(0.1);
  int _selectedGender = -1;

  @override
  void initState() {


    super.initState();

    print('gender selectedCompany:${SessionParameters().selectedCompany}');
  }

  void _selectGender(int atIndex) {
    setState(() {
      _selectedGender = atIndex;
    });
  }

  void _moveToNextPage() {

    var gender =  _selectedGender == 0 ? Gender.male : Gender.female;
    // var meas = MeasurementModel(gender, UserType.endWearer);

    widget.argument.measurement.gender = gender.apiFlag();
    // var ads = SharedParameters().currentMeasurement;
    // print('CHECK $meas');
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
        // RulerPageWeight(),
      RulerPage(gender: gender, measuremet: widget.argument.measurement)
      ));
  }


  @override
  Widget build(BuildContext context) {

    var buttonsContainer = Align(
      alignment: Alignment.center,
      child: Container(
        height: 182,
        color: _backgroundColor,
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
                  _selectGender(0);
                    },

                  color: _selectedGender == 0 ? _selectedColor : _backgroundColor,
                  highlightColor: Colors.grey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 45,
                            height: 61,
                            child:ResourceImage.imageWithName(_selectedGender == 0 ? Gender.male.selectedImageName() : Gender.male.unselectedImageName())),
                        SizedBox(height: 24),
                        Text('Male', style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ))),
            Expanded(
            child:FlatButton(
              onPressed: (){
                _selectGender(1);
              },
              color: _selectedGender == 1 ? _selectedColor : _backgroundColor,
              highlightColor: Colors.grey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  SizedBox(
                    width: 45,
                      height:61,
                      child:ResourceImage.imageWithName(_selectedGender == 1 ? Gender.female.selectedImageName() : Gender.female.unselectedImageName())),
                  SizedBox(height: 24),
                  Text('Female', style: TextStyle(color: Colors.white),),
                ],
              ),
            )),
          ],
        ),
      ),
    );

    var nextButton = Visibility(
      visible: _selectedGender >= 0,
        child:Align(
          alignment: Alignment.bottomCenter,
          child:SafeArea(child: Container(
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
            )),
      )));

    var container = Stack(
      children: [
        buttonsContainer,
        nextButton
      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Measure an end-wearer'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: container,
    );


    return scaffold;
  }
}