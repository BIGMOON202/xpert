import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Screens/LoginPage.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
class ChooseRolePage extends StatefulWidget {
  @override
  _ChooseRolePageState createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {

  static Color _backgroundColor = SharedParameters().mainBackgroundColor;
  static Color  _selectedColor = Colors.white.withOpacity(0.1);

  UserType _selectedUserType;


  void _selectUserType(int atIndex) {
    setState(() {
      _selectedUserType = atIndex == 0 ? UserType.endWearer : UserType.salesRep;
    });
  }

  @override
  Widget build(BuildContext context) {

    var titleText = Padding(
      padding: EdgeInsets.all(40),
      child: CustomText("Before start, select your role"),
    );


    var buttonsContainer = Align(
      alignment: Alignment.center,
      child: Container(
        height: 182,
        color: _backgroundColor,
        padding: EdgeInsets.all(12),
        child:Row(
          children: [
            Expanded(
                child:Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child:FlatButton(
                      onPressed: () {
                        _selectUserType(0);
                      },

                      color: _selectedUserType == UserType.endWearer ? _selectedColor : _backgroundColor,
                      highlightColor: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              width: 45,
                              height: 61,
                              child:ResourceImage.imageWithName(_selectedUserType == UserType.endWearer ? UserType.endWearer.selectedImageName() : UserType.endWearer.unselectedImageName())),
                          SizedBox(height: 24),
                          Text('I\'m the end-wearer', style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ))),
            Expanded(
                child:FlatButton(
                  onPressed: (){
                    _selectUserType(1);
                  },
                  color: _selectedUserType == UserType.salesRep ? _selectedColor : _backgroundColor,
                  highlightColor: Colors.grey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: <Widget>[
                      SizedBox(
                          width: 45,
                          height:61,
                          child:ResourceImage.imageWithName(_selectedUserType == UserType.salesRep ? UserType.salesRep.selectedImageName() : UserType.salesRep.unselectedImageName())),
                      SizedBox(height: 24),
                      Text('I\'m the sales rep', style: TextStyle(color: Colors.white),),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );

    void _moveToNextPage() {
        Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
        LoginPage(userType: _selectedUserType)
          // EventsPage()
        ));
    }

    var nextButton = Visibility(
        visible: true,
        child:Align(
            alignment: Alignment.bottomCenter,
            child:SafeArea(child: Container(
                width: double.infinity,
                child: MaterialButton(
                  textTheme: ButtonTextTheme.accent,
                  onPressed: _selectedUserType != null ? () {
                    _moveToNextPage();
                    print('next button pressed');
                  } : null,
                  textColor: Colors.black,
                  disabledColor: Colors.white.withOpacity(0.5),
                  child: Text('PROCEED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                  color: Colors.white,
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),

                  ),
                  // padding: EdgeInsets.all(4),
                )),
            )));


    var bottomPart = new FractionallySizedBox (
      alignment: Alignment.bottomCenter,
      heightFactor: 0.6,
      child: Stack(children: [
        Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          color: HexColor.fromHex("#16181B")
        ),

        child: Column(
          children: [titleText, buttonsContainer],
        ),
    ), nextButton])
    );


    var topPart = new Container(
      child: SafeArea(child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: 1.0,
        child: Column(

          children: [
            SizedBox(child: ResourceImage.imageWithName("expertfit_logo.png"), width: 171, height: 40,),
            Padding(padding: EdgeInsets.all(50), child: Text('Take the guesswork out of fitting and do it all in the convenience of your home. ExpertFit virtual sizing '
                'technology is accurate and fast.', style: TextStyle(color: HexColor.fromHex('898A9D')),  textAlign: TextAlign.center,))],
        ),
      ),
    ));

    var container = Container(
      color: Colors.black,
      child: bottomPart,
    );

    var stack = Stack(alignment: Alignment.bottomCenter,
      children: [container, topPart],);

    var scaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: stack,
    );

    return scaffold;
  }
}

