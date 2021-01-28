import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/Painter.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UserInfoWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/UserModel.dart';
import 'package:tdlook_flutter_app/Screens/PrivacyPolicyPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/EventListWorker.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/Screens/EventDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/main.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:tuple/tuple.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EventsPage extends StatefulWidget {

  final String provider;
  EventsPage({this.provider});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  EventListWorkerBloc _bloc;
  UserInfoBloc _userInfoBloc;
  UserType _userType = UserType.salesRep;
  User _userInfo;


  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  @override
  void initState() {

    _bloc = EventListWorkerBloc(widget.provider);
    _userInfoBloc = UserInfoBloc();
    print('get userInfo ${_userInfoBloc}');

    Future<Void> fetchUserType() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _userType = EnumToString.fromString(UserType.values, prefs.getString("userType"));

      _bloc.set(_userType);
      _bloc.call();

      _userInfoBloc.set(_userType);
      _userInfoBloc.call();

    }

    fetchUserType();
  }

  StreamBuilder _builder;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget _userInfoView() {
      if (_userInfo == null) {
        print('user info null');
        if (_builder == null) {
          _builder = StreamBuilder<Response<User>>(
            stream: _userInfoBloc.chuckListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    print('loading header');
                    return Loading(loadingMessage: snapshot.data.message);
                    break;
                  case Status.COMPLETED:
                    print('completed header');
                    _userInfo = snapshot.data.data;
                    return  UserInfoHeader(userInfo: snapshot.data.data, userType: _userType);
                    break;
                  case Status.ERROR:
                    return Expanded(child: Error(
                      errorMessage: snapshot.data.message,
                      showRetry: false,
                    ));
                    break;
                }
              }
              return CircularProgressIndicator();
            },
          );
        }
        return _builder;

      } else {
        print('user info not null');
        return UserInfoHeader(userInfo: _userInfo, userType: _userType);
      }
    }

    Widget _createHeader() {
      return DrawerHeader(
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.zero,
          child: Align(
            alignment:Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 70, left: 30, right: 8),
              child: Container(
                  child: _userInfoView()),
            ),
          ));
    }

    Widget _createDrawerItem(
        {Icon icon, String text, GestureTapCallback onTap}) {
      return ListTile(
        title: Row(
          children: <Widget>[
            icon,
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(text, style: TextStyle(color: Colors.white),),
            )
          ],
        ),
        onTap: onTap,
      );
    }

    void _logoutAction() {

      Future<void> removeToken() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('refresh');
        prefs.remove('access');

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

      }

      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            content: new Text('Are you sure that you want to logout?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Yes"),
                onPressed: () => removeToken(),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('No'),
              ),
            ],
          )
      );
    }


    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: StreamBuilder<Response<Tuple2<EventList, MeasurementsList>>>(
        stream: _bloc.chuckListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                print('loading');
                return Loading(loadingMessage: snapshot.data.message);
                break;
              case Status.COMPLETED:
                print('completed');
                return EventsListWidget(resultsList: snapshot.data.data, userType: _userType, userId: '');//_userInfo.id.toString()
                break;
              case Status.ERROR:
                return Error(
                  errorMessage: snapshot.data.message,
                  onRetryPressed: () => _bloc.call(),
                );
                break;
            }
          }
          return Container();
        },
      ),

      drawer: Drawer(

        child: Container(
          color: Colors.black,
          child:Column(children: [Expanded(
            flex: 8,
              child:ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(),

            Divider(color: Colors.white,),

            _createDrawerItem(
                icon: new Icon(MdiIcons.shieldCheckOutline, color: HexColor.fromHex('898A9D'),),
                text: 'Privacy Policy and  Terms & Conditions',
                onTap: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
                  PrivacyPolicyPage(showApply: false)
                  ));
            }),

          ],
        )),
          Expanded(child: _createDrawerItem(
              icon: Icon(Icons.logout, color: HexColor.fromHex('898A9D')),
              text: 'Logout',
              onTap: () {
                _logoutAction();
              }))]),
        )),
      );

    return scaffold;
  }
}

class EventsListWidget extends StatelessWidget {
  final String userId;
  final UserType userType;
  final Tuple2<EventList, MeasurementsList> resultsList;

  const EventsListWidget({Key key, this.resultsList, this.userType, this.userId}) : super(key: key);
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;


  @override
  Widget build(BuildContext context) {

    void _moveToEventAt(int index) {

      var event = resultsList.item1.data[index];
      var measurements = resultsList.item2;

      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      // LoginPage(userType: _selectedUserType)
      EventDetailPage(event: event, measurementsList: measurements, userType: userType, currentUserId: userId,)
      ));
    }


    Widget itemAt(int index) {

      var event = resultsList.item1.data[index];
      print('itemAt: $index $event');
      var eventName = event.name ?? 'Event Name';
      var companyName = event?.agency?.name ?? '-';
      var companyType = event?.agency?.type ?? '-';

      final startTimeSplit = event.createdAt.split('T');

      var eventStartDate = startTimeSplit.first ?? '-';
      var eventStartTime = startTimeSplit.last.substring(0,8) ?? '-';

      final endTimeSplit = event.endDate.split('T');

      var eventEndDate = endTimeSplit.first ?? '-';
      var eventEndTime = endTimeSplit.last.substring(0,8) ?? '-';
      var eventStatus = event.status.displayName() ?? "In progress";
      var eventStatusColor = event.status.displayColor() ?? Colors.white;


      var _textColor = Colors.white;
      var _descriptionColor = HexColor.fromHex('898A9D');
      var _textStyle = TextStyle(color: _textColor);
      var _descriptionStyle = TextStyle(color: _descriptionColor);


      Widget _configureGraphWidgetFor(Event _event) {

        if (_event.status.shouldShowCountGraph() == true && userType == UserType.salesRep) {

          var _doublePercent = (_event.completeMeasuremensCount /_event.totalMeasuremensCount);
          var percent = _doublePercent.isNaN ? 0 : _doublePercent.toInt();
          var angle = _doublePercent.isNaN ? 0.0 : _doublePercent * 360;
          print('percent $_doublePercent');
          var w = new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [CustomPaint(
                  painter: CurvePainter(color: eventStatusColor,
                      angle: angle),
                  child: SizedBox(width: 45, height: 45,),
                ),
                  Text('$percent%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),)],
              ),
              SizedBox(width: 8,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('${_event.completeMeasuremensCount}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('/${_event.totalMeasuremensCount}', style: TextStyle(color: _descriptionColor, fontSize: 11, fontWeight: FontWeight.w400))],
              )
            ],
          );
          return w;
        } else {
          return Container();
        }
      }

      var container = Container(
        color: _backgroundColor,
        child: Padding(
            padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventName, style: TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      SizedBox(height: 18,),
                      SizedBox(
                          height: 80,
                          child: Row(
                            children: [
                              Expanded(flex: 3,
                                  child: Column(
                                    children:
                                    [
                                      Expanded(flex: 2,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              SizedBox(height: 16,
                                                width: 16,
                                                child: ResourceImage
                                                    .imageWithName(
                                                    'ic_event_place.png'),),
                                              SizedBox(width: 8),
                                              Flexible(child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Expanded(child: Text(
                                                    companyName,
                                                    style: _textStyle,
                                                    overflow: TextOverflow
                                                        .ellipsis,)),
                                                  Expanded(child: Text(
                                                    companyType,
                                                    style: _descriptionStyle,
                                                    overflow: TextOverflow
                                                        .ellipsis,))
                                                ],))
                                            ],)),
                                      Expanded(flex: 1,
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(height: 16,
                                                  width: 16,
                                                  child: ResourceImage
                                                      .imageWithName(
                                                      'ic_event_date.png'),),
                                                SizedBox(width: 8),
                                                Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(child: Text(
                                                            eventStartDate,
                                                            style: _textStyle)),
                                                        Expanded(child: Text(
                                                            eventStartTime,
                                                            style: _descriptionStyle)),
                                                      ],))
                                              ],),)),
                                      Expanded(flex: 1,
                                          child: Row(
                                            children: [
                                              SizedBox(width: 24),
                                              Expanded(child: Text(eventEndDate,
                                                  style: _textStyle)),
                                              Expanded(child: Text(eventEndTime,
                                                  style: _descriptionStyle)),
                                            ],))
                                    ],
                                  )),
                              Expanded(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                            color: eventStatusColor.withOpacity(
                                                0.1)
                                        ),
                                        child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(eventStatus,
                                              style: TextStyle(
                                                  color: eventStatusColor),)),),
                                      SizedBox(height: 8,),
                                      Flexible(child: _configureGraphWidgetFor(event))
                                      ],),)),
                            ],
                          ))
                    ],
                  ),
                )
            )),
      );

      var gesture = GestureDetector(
        child: container,
        onTap: () {
          print('did Select at $index');
          _moveToEventAt(index);
        },
      );

      return gesture;
    }

    var list = ListView.builder(itemCount: resultsList.item1.data.length,
      itemBuilder: (_, index) => itemAt(index),
    );
    return list;
  }
}

class UserInfoHeader extends StatelessWidget {
  final User userInfo;
  final UserType userType;

  const UserInfoHeader({Key key, this.userInfo, this.userType}) : super(key:key);
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 40, height: 40, child: ResourceImage.imageWithName(userType.menuImageName()),),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(
              child: Container()),
            Expanded(child: Text('${userInfo.userFullName()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            Expanded(child: Text(userInfo.email, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.62)))),
            Expanded(child: Container())],)
      ]);
  }
}