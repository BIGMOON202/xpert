import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/AuthWorker.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UserInfoWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:tdlook_flutter_app/Screens/PrivacyPolicyPage.dart';
import 'package:tdlook_flutter_app/Screens/TutorialPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/constants/global.dart';

class LoginPage extends StatefulWidget {
  final UserType? userType;

  const LoginPage({Key? key, this.userType}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Status? _authRequestStatus;
  AuthWorkerBloc? _authBloc;
  UserInfoBloc? _userInfoBloc;

  String _errorMessage = '';

  AuthCredentials? _credentials;
  CompanyType? _provider;
  String _email = '';
  String _password = '';
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    if (Application.isInDebugMode) {
      _email = 'andrew+dublesr@3dlook.me';
      _password = '!Qa123456789Qa';

      _email = 'animaltut+7@gmail.com';
      _password = '1qa2ws#ED7';

      // _email = 'andrew+fhsr2@3dlook.me';
      // _password = 'Qa123456789Qa.';
      _email = 'andrewsl@3dlook.me';
      _password = 'Qa123456789Qa.';

      if (widget.userType == UserType.endWearer) {
        _email = 'andrew+ew1@qa.qa';
        _password = '346795';

        _email = 'animaltut+1@gmail.com';
        _password = '300031';

        _email = 'qaz@a.aa';
        _password = '778507';

        // _email = 'qw@qw.qw';
        // _password = '847259';

        // _email = 'artem.oliynyk+ew1@3dlook.me';
        // _password = '515954';
        _email = 'qa@qa.qa';
        _password = '853564';
      }
    }
    if (kCompanyTypeArmorOnly) {
      _provider = CompanyType.armor;
    }
    initPreferences();
  }

  void initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _moveToNextScreen() {
    Future<void> _moveToNext() async {
      var agreementSigned = prefs?.getBool('agreement') ?? false;
      var isUserTypeForcedToShow = widget.userType == UserType.endWearer;
      if (agreementSigned == false || isUserTypeForcedToShow == true) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => PrivacyPolicyPage(
                      credentials: _credentials,
                      userType: widget.userType,
                    )));
      } else {
        prefs?.setString('refresh', _credentials?.refresh ?? ''); // for string value
        prefs?.setString('access', _credentials?.access ?? ''); // for string value
        prefs?.setString('userType', EnumToString.convertToString(widget.userType));

        if (widget.userType == UserType.salesRep) {
          Navigator.pushNamedAndRemoveUntil(context, '/events_list', (route) => false);
        } else {
          if (kCompanyTypeArmorOnly) {
            _moveToEventsAsArmorCompany();
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/choose_company', (route) => false);
          }
        }

        if (prefs?.getBool('intro_seen') != true) {
          Navigator.push(
              context,
              MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return TutorialPage();
                },
                fullscreenDialog: true,
              ));
        }
      }
    }

    //check if user is valid to login
    _userInfoBloc = UserInfoBloc();
    _userInfoBloc?.set(userType: widget.userType, accessKey: _credentials?.access);
    _userInfoBloc?.chuckListStream?.listen((user) {
      if (user.status == null) return;
      switch (user.status!) {
        case Status.LOADING:
          logger.i('loading header...');
          break;
        case Status.COMPLETED:
          logger.d('ROLE: ${user.data?.role}');
          if ((user.data?.role == null) ||
              ((user.data?.role != null) &&
                  (user.data?.role == 'dealer' ||
                      user.data?.role == 'sales_rep' ||
                      user.data?.role == ''))) {
            //continue flow
            _moveToNext();
          } else {
            _authRequestStatus = Status.ERROR;
            // show error
            setState(() {
              _errorMessage = 'This type of user is not enable to Login in mobile application';
            });
          }
          break;
        case Status.ERROR:
          break;
      }
    });
    _userInfoBloc?.call();
  }

  void authCall() {
    FocusScope.of(context).unfocus();

    _authBloc = AuthWorkerBloc(AuthWorkerBlocArguments(
        email: _email.toLowerCase(),
        password: _password,
        userType: widget.userType,
        provider: _provider));
    _authBloc?.chuckListStream.listen((event) {
      setState(() {
        _authRequestStatus = event.status;
      });
      if (event.status == null) return;
      switch (event.status!) {
        case Status.COMPLETED:
          _credentials = event.data;
          _moveToNextScreen();
          break;
        case Status.ERROR:
          _errorMessage = event.message ?? '';
          break;
        case Status.LOADING:
          // TODO: Handle this case.
          break;
      }
      logger.d('OLOLO');
    });

    _authBloc?.call();
  }

  @override
  Widget build(BuildContext context) {
    String? _validateEmail(String? value) {
      return null;
    }

    String? _validatePassword(String? value) {
      return null;
    }

    bool _continueIsEnabled() {
      var providerSelected = true;
      if (widget.userType == UserType.salesRep && _provider == null) {
        providerSelected = false;
      }

      return _email.isNotEmpty &&
          _password.isNotEmpty &&
          _authRequestStatus != Status.LOADING &&
          providerSelected;
    }

    var nextButton = Visibility(
      visible: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            child: MaterialButton(
              onPressed: _continueIsEnabled() ? authCall : null,
              disabledColor: Colors.white.withOpacity(0.5),
              textColor: Colors.black,
              child: Text(
                'CONTINUE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              color: Colors.white,
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ),
    );

    final fillColor = Colors.white.withOpacity(0.1);
    final borderColor = _authRequestStatus == Status.ERROR ? Colors.red : Colors.transparent;
    Widget _providerField() {
      if (widget.userType == UserType.salesRep) {
        Widget _subRow({CompanyType? provider}) {
          return Theme(
            data: ThemeData.dark(), //set the dark theme or write your own theme
            child: Row(
              children: [
                Radio(
                    activeColor: Colors.white,
                    value: provider?.selectionIndex() ?? 0,
                    groupValue: _provider?.selectionIndex(),
                    onChanged: (value) {
                      setState(() {
                        _provider = provider;
                      });
                    }),
                SizedBox(width: 1),
                Text(
                  provider?.stringName() ?? '',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          );
        }

        var box = SizedBox(
            height: 44,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _subRow(provider: CompanyType.armor),
                SizedBox(width: 16),
                _subRow(provider: CompanyType.uniforms)
              ],
            ));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider',
              style: TextStyle(color: Colors.white),
            ),
            box
          ],
        );
      } else {
        return Container();
      }
    }

    Widget _passwordFieldForUser() {
      if (widget.userType == UserType.salesRep) {
        return SizedBox(
          height: 44,
          child: TextFormField(
            onChanged: (String value) {
              setState(() {
                _authRequestStatus = Status.COMPLETED;
                _password = value;
              });
            },
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(color: Colors.white),
            validator: _validateEmail,
            textCapitalization: TextCapitalization.none,
            initialValue: _password,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(width: 1, color: Colors.transparent)),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                hintText: 'Your password',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: borderColor),
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                hoverColor: Colors.brown,
                fillColor: fillColor),
          ),
        );
      } else {
        var field = Padding(
          padding: const EdgeInsets.only(top: 8),
          child: PinCodeTextField(
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            keyboardType: TextInputType.number,
            blinkDuration: Duration(milliseconds: 230),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(6),
              borderWidth: 1,
              selectedColor: borderColor,
              inactiveColor: borderColor,
              disabledColor: borderColor,
              activeColor: borderColor,
              inactiveFillColor: fillColor,
              selectedFillColor: fillColor,
              activeFillColor: fillColor,
              fieldHeight: 44,
              fieldWidth: 48,
            ),
            textStyle: TextStyle(fontSize: 14, color: Colors.white),
            animationDuration: Duration(milliseconds: 230),
            cursorHeight: 16,
            backgroundColor: _backgroundColor,
            enableActiveFill: true,
            enablePinAutofill: true,
            onCompleted: (pin) {
              setState(() {
                _authRequestStatus = Status.COMPLETED;
                _password = pin;
              });
            },
            onChanged: (value) {
              setState(() {
                _authRequestStatus = null;
                _password = value;
              });
            },
            beforeTextPaste: (text) {
              return true;
            },
            appContext: context,
          ),
        );

        var theme = Theme(
          data: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1,
                        color:
                            _authRequestStatus == Status.ERROR ? Colors.red : Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(6)))),
          ),
          child: field,
        );
        return theme;
      }
    }

    var container = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: SizedBox(
                    width: 49,
                    child: ResourceImage.imageWithName(widget.userType?.selectedImageName() ?? ''),
                  ))),
            )),
        Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  color: _backgroundColor),
              child: Padding(
                  padding: EdgeInsets.only(top: 30, left: 12, right: 12, bottom: 12),
                  child: Stack(children: [
                    SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                            height: 44,
                            child: TextFormField(
                              // textAlignVertical: TextAlignVertical.center,
                              enabled: _authRequestStatus != Status.LOADING,
                              onChanged: (String value) {
                                setState(() {
                                  _authRequestStatus = Status.COMPLETED;
                                  _email = value;
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Colors.white),
                              validator: _validateEmail,
                              textCapitalization: TextCapitalization.none,
                              initialValue: _email,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                      borderSide: BorderSide(width: 1, color: Colors.transparent)),
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                                  hintText: 'Your email',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: _authRequestStatus == Status.ERROR
                                              ? Colors.red
                                              : Colors.transparent),
                                      borderRadius: BorderRadius.all(Radius.circular(6))),
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  hoverColor: Colors.brown,
                                  fillColor: Colors.white.withOpacity(0.1)),
                            )),
                        SizedBox(height: 20),
                        Text(
                          widget.userType?._passwordFieldName() ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        _passwordFieldForUser(),
                        SizedBox(height: 20),
                        if (!kCompanyTypeArmorOnly) _providerField(),
                        Visibility(
                            visible: _authRequestStatus == Status.ERROR,
                            child: Container(
                                child: Center(
                                    child: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                ResourceImage.imageWithName('ic_error.png'),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ))))
                      ],
                    )),
                    nextButton
                  ])),
            ))
      ],
    );

    Widget loaderIndicator() {
      return _authRequestStatus == Status.LOADING
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Container(),
            );
    }

    var scaffold = Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Login as ${widget.userType?.displayName()}'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: Colors.black,
        body: Stack(children: [container, loaderIndicator()]));

    return scaffold;
  }

  void _moveToEventsAsArmorCompany() {
    SessionParameters().selectedCompany = CompanyType.armor;
    Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (BuildContext context) => EventsPage(
                provider: CompanyType.armor.apiKey(),
              )
          // EventsPage()
          ),
    );
  }
}

extension _UserTypeExtension on UserType {
  String _passwordFieldName() {
    switch (this) {
      case UserType.endWearer:
        return 'Secret code';
      case UserType.salesRep:
        return 'Password';
    }
  }
}
