
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/style.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:tdlook_flutter_app/Screens/PrivacyPolicyPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/AuthWorker.dart';
import 'package:otp_text_field/otp_text_field.dart';

class LoginPage extends StatefulWidget {
  final UserType userType;

  const LoginPage ({ Key key, this.userType }): super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Status _authRequestStatus;
  AuthWorkerBloc _authBloc;

  String _errorMessage = '';

  AuthCredentials _credentials;

  String _email = '';
  String _password = '';
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;


  @override
  void initState() {
    // TODO: implement initState

    if (Application.isInDebugMode) {
      _email = 'andrew+dealerinv@3dlook.me';//'annakarp13+99@gmail.com'
      _password = 'Qa123456789Qa.';//'Qa123456789Qia.'

      if (widget.userType == UserType.endWearer) {
        _email = 'john@gmail.com';//'garry@gmail.com';
        _password = '211567';//'723692';
      }
    }
  }

  void _moveToNextScreen() {

    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      PrivacyPolicyPage(credentials: _credentials, userType: widget.userType)
    ));
  }

  void authCall() {
      FocusScope.of(context).unfocus();

      _authBloc = AuthWorkerBloc(AuthWorkerBlocArguments(email: _email.toLowerCase(), password: _password, userType: widget.userType));
      _authBloc.chuckListStream.listen((event) {

        setState(() {
          _authRequestStatus = event.status;
        });

        switch (event.status) {
          case Status.COMPLETED:

            _credentials = event.data;
            _moveToNextScreen();
            break;
          //move to list

          case Status.ERROR:
          _errorMessage = event.message;
        }
        print('OLOLO');
        print('${event.status} status ${event.data.access}');
      });

      _authBloc.call();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    String _validateEmail(String value) {
      return null;
    }

    String _validatePassword(String value) {
      return null;
    }

    bool _continueIsEnabled() {
      return _email != null && _email.isNotEmpty &&  _password != null && _password.isNotEmpty && _authRequestStatus != Status.LOADING;
    }


    var nextButton = Visibility(
        visible: true,
        child:Align(
            alignment: Alignment.bottomCenter,
            child:SafeArea(child: Container(
                width: double.infinity,
                child: MaterialButton(

                  onPressed: _continueIsEnabled() ? authCall : null,
                  disabledColor: Colors.white.withOpacity(0.5),
                  textColor: Colors.black,
                    child: Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                  color: Colors.white,
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),

                  ),
                  // padding: EdgeInsets.all(4),
                )),
            )));

    Widget _passwordFieldForUser() {
      if (widget.userType == UserType.salesRep) {
        return TextFormField(
          onChanged: (String value) {
            setState(() {
              _authRequestStatus = Status.COMPLETED;
              _password = value;
            });
          },
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          style: TextStyle(
              color: Colors.white
          ),
          validator: _validateEmail,
          textCapitalization:  TextCapitalization.none,
          initialValue: _password,
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide:  BorderSide(width: 1, color: Colors.transparent)
              ),
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.1)
              ),
              hintText: 'Your password',
              enabledBorder: OutlineInputBorder(
                  borderSide:  BorderSide(width: 1, color: _authRequestStatus == Status.ERROR ? Colors.red : Colors.transparent),
                  borderRadius:  BorderRadius.all(Radius.circular(6))
              ),
              filled: true,
              hoverColor: Colors.brown,
              fillColor: Colors.white.withOpacity(0.1)
          ),
        );
      } else {

        var field = SizedBox(
            height: 44,
            child:OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldWidth: 48,
              fieldStyle: FieldStyle.box,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white
              ),
              onCompleted: (pin) {
                setState(() {
                  _authRequestStatus = Status.COMPLETED;
                  _password = pin;
                });
              },
            ));

        var theme = Theme(
          data: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                  borderSide:  BorderSide(width: 1, color: _authRequestStatus == Status.ERROR ? Colors.red : Colors.transparent),
                  borderRadius:  BorderRadius.all(Radius.circular(6))
              )
            ),
          ),
          child: field,
        );
        return theme;
        }
      }

    var container = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded( flex: 1, child: Container(
          color: Colors.black,
          child: Padding(padding: EdgeInsets.all(16), child: Center(
            child: SizedBox( width: 49, child:ResourceImage.imageWithName(widget.userType.selectedImageName()),
          ))),
        )),
        Expanded(flex: 5, child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              color: _backgroundColor
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 30, left: 12, right: 12),
            child: Stack(children: [SingleChildScrollView(
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email', style: TextStyle(color: Colors.white),),
                  SizedBox(height: 8),
                  SizedBox(
                      child:TextFormField(
                        // textAlignVertical: TextAlignVertical.center,
                      enabled: _authRequestStatus != Status.LOADING,
                      onChanged: (String value) {
                        setState(() {
                          _authRequestStatus = Status.COMPLETED;
                          _email = value;
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          color: Colors.white
                      ),
                      validator: _validateEmail,
                      textCapitalization:  TextCapitalization.none,
                      initialValue: _email,
                      decoration: InputDecoration(

                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide:  BorderSide(width: 1, color: Colors.transparent)
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.1)
                        ),
                        hintText: 'Your email',
                          enabledBorder: OutlineInputBorder(
                              borderSide:  BorderSide(width: 1, color: _authRequestStatus == Status.ERROR ? Colors.red : Colors.transparent),
                              borderRadius:  BorderRadius.all(Radius.circular(6))
                          ),
                        filled: true,
                        hoverColor: Colors.brown,
                        fillColor: Colors.white.withOpacity(0.1)
                      ),
                  )),
                  SizedBox(height: 20),
                  Text( widget.userType._passwordFieldName(), style: TextStyle(color: Colors.white),),
                  SizedBox(height: 8),
                  _passwordFieldForUser(),
                  Visibility(
                    visible: _authRequestStatus == Status.ERROR,
                      child: Container(
                        child:
                        Center(child:
                        Column(
                          children: [
                            SizedBox(height: 40,),
                            ResourceImage.imageWithName('ic_error.png'),
                            SizedBox(height: 10,),
                            Text(_errorMessage != null ? _errorMessage : '',
                              style: TextStyle(color: Colors.red), textAlign: TextAlign.center,)
                          ],

                  ))))
                ],
              )),
              nextButton])

          ),

        ))
      ],
    );

    Widget loaderIndicator() {
      return _authRequestStatus == Status.LOADING ? Center(child: CircularProgressIndicator()) : Center(child: Container(),);
    }

    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Login as ${widget.userType.displayName()}'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: Stack(children: [
        container,
        loaderIndicator()
      ])
    );


    return scaffold;
  }
}

extension _UserTypeExtension on UserType {
  String _passwordFieldName() {
    switch (this) {
      case UserType.endWearer: return 'Secret code';
      case UserType.salesRep: return 'Password';
    }
  }
}