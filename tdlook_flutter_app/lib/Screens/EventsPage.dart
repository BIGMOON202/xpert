import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/Painter.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UserInfoWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/UserModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/EventCompletionGraphWidget.dart';
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
import 'package:tdlook_flutter_app/Extensions/RefreshStatus+Extension.dart';
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

  String _appVersion = '';
  EventsListWidget listWidget;
  SharedPreferences prefs;

  RefreshController _refreshController = RefreshController(initialRefresh: false);


  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _toggle()
  {
    _innerDrawerKey.currentState.toggle(
      // direction is optional
      // if not set, the last direction will be used
      //InnerDrawerDirection.start OR InnerDrawerDirection.end
        direction: InnerDrawerDirection.start
    );
  }

  Future<void> _refreshList() {
    _bloc.call();
  }

  @override
  void initState() {


    _bloc = EventListWorkerBloc(widget.provider);
    _userInfoBloc = UserInfoBloc();
    print('get userInfo ${_userInfoBloc}');
    print('list selectedCompany:${SessionParameters().selectedCompany}');

    Future<Void> fetchUserType() async {
      prefs = await SharedPreferences.getInstance();

      _userType = EnumToString.fromString(UserType.values, prefs.getString("userType"));

      _userInfoBloc.set(userType: _userType);
      _userInfoBloc.chuckListStream.listen((user) {

        switch (user.status) {
          case Status.LOADING:
            print('loading header');
            break;
          case Status.COMPLETED:
            print('completed header');
            if (_userType == UserType.salesRep) {
              SessionParameters().selectedCompany = user.data.provider;
            }
            print('company = ${user.data.provider.apiKey()}');
            setState(() {
              _userInfo = user.data;
            });

            _bloc.set(_userType, user.data.role, user.data.id?.toString());
            _bloc.call();

            break;
          case Status.ERROR:
            break;
        }
      });
      _userInfoBloc.call();
    }


    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {

      setState(() {
        _appVersion = 'App version: ' + packageInfo.version + ' ' + packageInfo.buildNumber;
      });
    });

    fetchUserType();
  }

  StreamBuilder _builder;
  Widget _createdHeader;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget _userInfoView() {
      if (_userInfo == null) {
        print('user info null');
          return CircularProgressIndicator();
        } else {
        print('user info not null');
        return UserInfoHeader(userInfo: _userInfo, userType: _userType);
      }
    }

    _createdHeader = DrawerHeader(
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.zero,
          child: Align(
            alignment:Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 70, left: 30, right: 8),
              child: _userInfoView(),
            ),
          ));

    Widget _createDrawerItem(
        {Icon icon, Image image, String text, GestureTapCallback onTap}) {
      return ListTile(
        title: Row(
          children: <Widget>[
            icon ?? SizedBox(width: 26, height: 26, child: image),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(text, style: TextStyle(color: Colors.white, fontSize: 14),),
            )
          ],
        ),
        onTap: onTap,
      );
    }

    void _logoutAction() {

      Future<void> removeToken() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString('access', 'value');
        // // prefs.setString('refresh', 'value');
        // return;
        
        prefs.remove('access');
        prefs.remove('refresh');
        NavigationService.instance.pushNamedAndRemoveUntil("/");
      }

      void closePopup() {
        Navigator.of(context, rootNavigator: true).pop("Discard");
      }

      showDialog(
        barrierDismissible: false,
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
                onPressed: () => closePopup()
              ),
            ],
          )
      );
    }


    var scaffold = Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu),
            onPressed: _toggle),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('My Events'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: StreamBuilder<Response<Tuple2<EventList, MeasurementsList>>>(
        stream: _bloc.chuckListStream,
        builder: (context, snapshot) {
          print('configure StreamBuilder');
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return Loading(loadingMessage: snapshot.data.message);
                break;
              case Status.COMPLETED:
                var userId = _userInfo != null ? _userInfo.id.toString() : null;
                prefs.setString('temp_user', userId ?? '');
                listWidget = EventsListWidget(resultsList: snapshot.data.data,
                    userType: _userType,
                    userId: userId,
                    onRefreshList: _refreshList,
                    refreshController: _refreshController);
                return listWidget;
                break;
              case Status.ERROR:
                return Error(
                  errorMessage: snapshot.data.message,
                  onRetryPressed: () => _bloc.call(),
                );
                break;
            }
          }
          return Loading();
        },
      ),
      );


    var innerDrawer = InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true,
      // borderRadius: 40,
      colorTransitionScaffold: Colors.transparent,
      backgroundDecoration: BoxDecoration(color: Colors.black),
      leftChild: Material(child: Container(
      color: Colors.black,
      child:Column(children: [Expanded(
          flex: 8,
          child:ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _createdHeader,

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
        Expanded(child: _createDrawerItem(text: _appVersion)),
        Expanded(child: _createDrawerItem(
            image: ResourceImage.imageWithName('ic_logout.png'),
            text: '  Logout',
            onTap: () {
              _logoutAction();
            }))]),
    )),
        scaffold: scaffold);

    return innerDrawer;
  }
}

class EventsListWidget extends StatelessWidget {
  final String userId;
  final UserType userType;
  final Tuple2<EventList, MeasurementsList> resultsList;
  final AsyncCallback onRefreshList;
  final RefreshController refreshController;

  const EventsListWidget({Key key, this.resultsList, this.userType, this.userId, this.onRefreshList, this.refreshController}) : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _pullRefresh() async {
    await onRefreshList();
    refreshController.loadComplete();
    // why use freshWords var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {

    if (resultsList.item1.data.isEmpty) {
      return EmptyStateWidget(messageName: 'There is no events yet');
    }

    void _moveToEventAt(int index) {

      if (userId == null) {
        print('did not receive user profile info on main page');
        // return;
      }

      var event = resultsList.item1.data[index];
      var measurements = resultsList.item2;

      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      // LoginPage(userType: _selectedUserType)
      EventDetailPage(event: event, measurementsList: null, userType: userType, currentUserId: userId,)
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

          return EventCompletionGraphWidget(event: _event);
          // var _doublePercent = (_event.completeMeasuremensCount /_event.totalMeasuremensCount);
          // var percent = _doublePercent.isNaN ? 0 : (_doublePercent * 100).toInt();
          // var angle = _doublePercent.isNaN ? 0.0 : _doublePercent * 360;
          // var w = new Row(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Stack(
          //       alignment: Alignment.center,
          //       children: [CustomPaint(
          //         painter: CurvePainter(color: eventStatusColor,
          //             angle: angle),
          //         child: SizedBox(width: 45, height: 45,),
          //       ),
          //         Text('$percent%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),)],
          //     ),
          //     SizedBox(width: 8,),
          //     Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [Text('${_event.completeMeasuremensCount}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          //         Text('/${_event.totalMeasuremensCount}', style: TextStyle(color: _descriptionColor, fontSize: 11, fontWeight: FontWeight.w400))],
          //     )
          //   ],
          // );
          // return w;
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
                              Expanded(flex: 4,
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
                                flex: 2,
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
                                                  color: eventStatusColor, fontWeight: FontWeight.bold),)),),
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

    var listView = ListView.builder(itemCount: resultsList.item1.data.length,
      itemBuilder: (_, index) => itemAt(index),
    );

    Color _refreshColor = HexColor.fromHex('#898A9D');
    var list = SmartRefresher(
      header: CustomHeader(
        builder: (BuildContext context, RefreshStatus mode){
          Widget body;
          if(mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh){
            body = Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children:[ Icon(Icons.arrow_downward, color: _refreshColor,),
              SizedBox(width: 6),
              Text(mode.title(), style: TextStyle(color: _refreshColor, fontSize: 12),)
            ]);
          } else {
            body = Container();
          }
          return Container(
            height: 55.0,
            child: Center(child:body),
          );
        },
      ),
      controller: refreshController,
        onLoading: _pullRefresh,
        child: listView, onRefresh: onRefreshList);
    return list;
  }
}

class UserInfoHeader extends StatelessWidget {
  final User userInfo;
  final UserType userType;

  const UserInfoHeader({Key key, this.userInfo, this.userType}) : super(key:key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 40, height: 40, child: ResourceImage.imageWithName(userType.menuImageName()),),
        SizedBox(width: 14),
        Expanded(child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Flexible(flex:2,
              child: Container()),
            Expanded(flex:2,child: Text('${userInfo.userFullName()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            Expanded(flex: 3, child : Text(userInfo.email, maxLines: 3, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.62)))),
            Flexible(flex:2,child: Container())],))
      ]);
  }
}