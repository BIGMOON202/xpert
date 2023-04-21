import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UpdateMeasurementWorker.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/BadgePage.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseGenderPage.dart';
import 'package:tdlook_flutter_app/Screens/WaitingPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

class AnalizeErrorPageArguments {
  MeasurementResults? measurement;
  XFile? frontPhoto;
  XFile? sidePhoto;
  bool? canRestartLastMeasurement = false;
  AnalizeResult? result;
  String? errorText;
  AnalizeErrorPageArguments({
    Key? key,
    this.measurement,
    this.frontPhoto,
    this.sidePhoto,
    this.result,
    this.errorText,
    this.canRestartLastMeasurement,
  });
}

class AnalizeErrorPage extends StatefulWidget {
  static const String route = '/error_page';

  AnalizeErrorPageArguments? arguments;
  AnalizeErrorPage({Key? key, this.arguments});
  @override
  _AnalizeErrorPageState createState() => _AnalizeErrorPageState();
}

enum PhotoError { front, side, both }

class _AnalizeErrorPageState extends State<AnalizeErrorPage> {
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  static Color _retakeButtonBackground = SessionParameters().selectionColor;
  static Color _textColor = Colors.white;
  static Color _optionalTextColor = HexColor.fromHex('898A9D');
  PhotoError? _photoError;

  String _buttonTitle = '';

  _continueAction() {
    logger.i('continue');

    if (widget.arguments?.result != null) {
      XFile? _frontPhoto = widget.arguments?.frontPhoto;
      XFile? _sidePhoto = widget.arguments?.sidePhoto;
      PhotoType? _passedPhotoType;

      if (_photoError == PhotoError.both) {
        _frontPhoto = null;
        _sidePhoto = null;
        _passedPhotoType = PhotoType.front;
      } else if (_photoError == PhotoError.front) {
        _frontPhoto = null;
        _passedPhotoType = PhotoType.front;
      } else if (_photoError == PhotoError.side) {
        _sidePhoto = null;
        _passedPhotoType = PhotoType.side;
      }

      logger.d('front: ${_frontPhoto != null}');
      logger.d('side: ${_sidePhoto != null}');
      logger.d('photoType: ${_passedPhotoType?.index}');
      logger.d('_photoError: ${_photoError?.index}');
      logger.i('push camera');

      Navigator.pushNamedAndRemoveUntil(
        context,
        CameraCapturePage.route,
        (route) => false,
        arguments: CameraCapturePageArguments(
          measurement: widget.arguments?.measurement,
          frontPhoto: _frontPhoto,
          sidePhoto: _sidePhoto,
          photoType: _passedPhotoType,
          previousPhotosError: _photoError,
        ),
      );
    } else {
      if (widget.arguments?.canRestartLastMeasurement == true) {
        Navigator.pushNamedAndRemoveUntil(context, WaitingPage.route, (route) => false,
            arguments: WaitingPageArguments(
                measurement: widget.arguments?.measurement,
                frontPhoto: widget.arguments?.frontPhoto,
                sidePhoto: widget.arguments?.sidePhoto,
                shouldUploadMeasurements: true));
        return;
      }

      if (SessionParameters().selectedUser == UserType.salesRep) {
        Navigator.pushNamedAndRemoveUntil(context, ChooseGenderPage.route, (route) => false,
            arguments: ChooseGenderPageArguments(widget.arguments?.measurement));
      } else {
        if (SessionParameters().selectedCompany == CompanyType.armor) {
          Navigator.pushNamedAndRemoveUntil(context, BadgePage.route, (route) => false,
              arguments: BadgePageArguments(
                  widget.arguments?.measurement, SessionParameters().selectedUser));
        } else {
          Navigator.pushNamedAndRemoveUntil(context, ChooseGenderPage.route, (route) => false,
              arguments: ChooseGenderPageArguments(widget.arguments?.measurement));
        }
      }
    }
    logger.i('_restartAnalize');
  }

  @override
  void initState() {
    super.initState();

    var title = '';

    List<Detail> detail = <Detail>[];

    if (widget.arguments?.result != null &&
        widget.arguments?.result?.detail != null &&
        widget.arguments?.result?.detail?.isEmpty == false) {
      detail = widget.arguments?.result?.detail?.where((i) => i.status != 'SUCCESS').toList() ?? [];
    }

    logger.d('number of errors: ${detail.length}');
    if (detail.isEmpty == false) {
      if (detail.length > 1) {
        title = 'Retake both scans';
        _photoError = PhotoError.both;
        logger.d('photoType${_photoError?.index}');
      } else {
        var photoType = detail.first.type;
        if (photoType == ErrorProcessingType.side_skeleton_processing) {
          _photoError = PhotoError.side;
        } else {
          _photoError = PhotoError.front;
        }
        logger.d('photoType${_photoError?.index}');
        title = 'Retake ${photoType?.name()} scan';
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
    Widget _configUndefinedError() {
      return Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            widget.arguments?.errorText != null
                ? widget.arguments?.errorText ?? ''
                : 'We can’t find your Perfect Fit right now. Please Try again in a few minutes.',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: _textColor),
            maxLines: 20,
          ));
    }

    Widget _configErrorView(Detail errorDetail) {
      var errorType = errorDetail.type;
      var imageName = errorType?.iconName();

      var _title = errorDetail.uiTitle();
      var _description = errorDetail.uiDescription();
      return Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 70,
                  height: 64,
                  child: Container(
                    color: Colors.white.withAlpha(10),
                    child: Padding(
                      child: ResourceImage.imageWithName(imageName),
                      padding: EdgeInsets.all(4),
                    ),
                  )),
              SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _textColor,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 10,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _description,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _optionalTextColor,
                      ),
                      maxLines: 10,
                    )
                  ],
                ),
              )
            ],
          ));
    }

    Widget configFor({AnalizeResult? result}) {
      List<Widget> vertical = <Widget>[];

      if (result == null || result.detail == null || result.detail?.isEmpty == true) {
        vertical.add(Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'Something went wrong',
            style: TextStyle(color: _optionalTextColor, fontSize: 14),
          ),
        ));
      }

      vertical.add(Padding(
        padding: EdgeInsets.only(top: 50, bottom: 48),
        child: ResourceImage.imageWithName('ic_error.png'),
      ));

      if (widget.arguments?.result == null ||
          widget.arguments?.result?.detail == null ||
          widget.arguments?.result?.detail?.isEmpty == true) {
        vertical.add(_configUndefinedError());
      } else {
        var details =
            widget.arguments?.result?.detail?.where((i) => i.status != 'SUCCESS').toList() ?? [];

        for (var _error in details) {
          logger.d(_error.type?.name());
          logger.e(_error.message);
          vertical.add(_configErrorView(_error));
          vertical.add(SizedBox(height: 20));
        }
      }

      return Column(
        children: vertical,
      );
    }

    var container = Column(
      children: [
        Flexible(child: configFor(result: widget.arguments?.result)),
        SafeArea(
            child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Container(
                    width: double.infinity,
                    child: MaterialButton(
                      splashColor: Colors.transparent,
                      elevation: 0,
                      onPressed: _continueAction,
                      disabledColor: _retakeButtonBackground.withOpacity(0.5),
                      textColor: Colors.white,
                      child: Text(
                        _buttonTitle.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      color: _retakeButtonBackground,
                      height: 50,
                      padding: EdgeInsets.only(left: 12, right: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      // padding: EdgeInsets.all(4),
                    ))))
      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Error'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: _backgroundColor,
      body: container,
    );

    return scaffold;
  }
}
