
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UpdateMeasurementWorker.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseGenderPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';


class AnalizeErrorPageArguments {
  MeasurementResults measurement;
  XFile frontPhoto;
  XFile sidePhoto;

  AnalizeResult result;
  String errorText;
  AnalizeErrorPageArguments({Key key, this.measurement, this.frontPhoto, this.sidePhoto, this.result, this.errorText});

}

class AnalizeErrorPage extends StatefulWidget {
  static const String route = '/error_page';

  AnalizeErrorPageArguments arguments;
  AnalizeErrorPage({Key key, this.arguments});
  @override
  _AnalizeErrorPageState createState() => _AnalizeErrorPageState();
}

enum _PhotoError {
  front,
  side,
  both
}

class _AnalizeErrorPageState extends State<AnalizeErrorPage>  {

  static Color _backgroundColor = SharedParameters().mainBackgroundColor;
  static Color _textColor = Colors.white;
  static Color _optionalTextColor = HexColor.fromHex('898A9D');
  _PhotoError _photoError;

  String _buttonTitle = '';

  _continueAction() {
    print('continue');

    if (widget.arguments.result != null) {
      XFile _frontPhoto = widget.arguments.frontPhoto;
      XFile _sidePhoto = widget.arguments.sidePhoto;
      PhotoType _passedPhotoType;


      if (_photoError == _PhotoError.both) {
        _frontPhoto = null;
        _sidePhoto = null;
        _passedPhotoType = PhotoType.front;
      } else if(_photoError ==_PhotoError.front) {
        _frontPhoto = null;
        _passedPhotoType = PhotoType.front;
      } else if (_photoError == _PhotoError.side) {
        _sidePhoto = null;
        _passedPhotoType = PhotoType.side;
      }

      print('front: ${_frontPhoto != null}');
      print('side: ${_sidePhoto != null}');
      print('photoType: ${_passedPhotoType.index}');

      print('push camera');

      Navigator.pushNamedAndRemoveUntil(context, CameraCapturePage.route, (route) => false,
          arguments: CameraCapturePageArguments(
              measurement: widget.arguments.measurement,
              frontPhoto: _frontPhoto,
              sidePhoto: _sidePhoto, photoType: _passedPhotoType));
    } else {
      Navigator.pushNamedAndRemoveUntil(context, ChooseGenderPage.route, (route) => false,
          arguments: ChooseGenderPageArguments(widget.arguments.measurement));
      print('_restartAnalize');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var title = '';

    List<Detail> detail = List<Detail>();


    if (widget.arguments.result != null && widget.arguments.result.detail != null && widget.arguments.result.detail.isEmpty == false) {
      detail = widget.arguments.result.detail.where((i) => i.status != 'SUCCESS').toList();
    }

    print('number of errors: ${detail.length}');
    if (detail.isEmpty == false) {

      if (detail.length > 1) {
        title = 'Retake both photos';
        _photoError = _PhotoError.both;
        print('photoType${_photoError.index}');
      } else {
        var photoType = detail.first.type;
        if (photoType == ErrorProcessingType.side_skeleton_processing) {
          _photoError = _PhotoError.side;
        } else  {
          _photoError = _PhotoError.front;
        }
        print('photoType${_photoError.index}');
        title = 'Retake ${photoType.name()} photo';
      }
    } else {
      title = 'Try again';
    }
    setState(() {
      _buttonTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget _configUndefinedError() {
      return Padding(padding:EdgeInsets.only(left: 20, right: 20),
          child: Text(widget.arguments.errorText != null ? widget.arguments.errorText : 'We can’t find your Perfect Fit right now. Please Try again in a few minutes.',
        style: TextStyle(fontWeight:
        FontWeight.normal,
            fontSize: 16,
            color: _textColor),
        maxLines: 20,));
    }

    Widget _configErrorView(Detail errorDetail) {

      var errorType = errorDetail.type;
      var imageName = errorType.iconName();

      var _title = errorDetail.uiTitle();
      var _description = errorDetail.uiDescription();
      return Padding(padding:EdgeInsets.only(left: 20, right: 20), child: Row(
          children:[
            SizedBox(
              width: 70,
              height: 64,
              child: Container(color: Colors.white.withAlpha(10), child: Padding(child: ResourceImage.imageWithName(imageName), padding: EdgeInsets.all(4),),)),
            SizedBox(width: 16),
            Flexible(child: Column(
                children: [
                  Text(_title,
                    style: TextStyle(fontWeight:
                    FontWeight.bold,
                        fontSize: 14,
                        color: _textColor),
                    maxLines: 10,),
                  SizedBox(height: 10),
                  Text(_description,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _optionalTextColor), maxLines: 10,)
                ]
            ))
          ],
      ));
    }

    Widget configFor({AnalizeResult result}) {
      List<Widget> vertical = new List<Widget>();

      if (result == null || result.detail == null || result.detail.isEmpty) {

        vertical.add(Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text('Something went wrong',
          style: TextStyle(color: _optionalTextColor, fontSize: 14),),));
      }

      vertical.add(Padding(padding: EdgeInsets.only(top: 50, bottom: 48), child: ResourceImage.imageWithName('ic_error.png'),));

      if (widget.arguments.result == null || widget.arguments.result.detail == null || widget.arguments.result.detail.isEmpty) {
        vertical.add(_configUndefinedError());
      } else {
        var details = widget.arguments.result.detail.where((i) => i.status != 'SUCCESS').toList();

        for (var _error in details) {
          print(_error.type.name());
          print(_error.message);
          vertical.add(_configErrorView(_error));
          vertical.add(SizedBox(height: 20));
        }
      }

      return Column(
        children: vertical,
      );
    }

    var container = Column(
      children: [Flexible(
          child: configFor(result: widget.arguments.result)),
      SafeArea(
          child: Container(
              width: double.infinity,
              child: MaterialButton(

                onPressed: _continueAction,
                disabledColor: Colors.white.withOpacity(0.5),
                textColor: Colors.black,
                child: Text(_buttonTitle.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                color: Colors.white,
                height: 50,
                padding: EdgeInsets.only(left: 12, right: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                // padding: EdgeInsets.all(4),
              ),))],
    );


    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Error'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: container,
    );

    return scaffold;
  }
}