import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:package_info/package_info.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
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
import 'package:tdlook_flutter_app/utilt/emoji_utils.dart';
import 'package:tuple/tuple.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tdlook_flutter_app/Extensions/RefreshStatus+Extension.dart';
import 'package:intl/intl.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Future+Extension.dart';

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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Response<Tuple2<EventList, MeasurementsList>> events;
  Response<Tuple2<EventList, MeasurementsList>> originalEvents;
  Tuple2<EventList, MeasurementsList> filteredevents;

  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  TextEditingController _searchController = TextEditingController();

  String _searchText;
  _clearText() {
    _searchText = '';
    _searchController.clear();
    filter(withText: '');
  }

  onSearchTextChanged(String text) {
    // print('update: $text');
    var searchText = EmojiUtils.removeAllEmoji(text ?? '');
    if (searchText.length < 1) {
      searchText = '';
    }
    _searchText = searchText;
    print("searchText: $searchText");
    FutureExtension.enableContinueTimer(delay: 1).then((value) {
      print('should search $searchText - $text');
      if (searchText == text) {
        print('searching');
        filter(withText: searchText);
      }
    });
  }


  filter({String withText}) async {
    // if (originalEvents == null) return;
    //
    // if (withText.isEmpty) {
    //   print('or: ${originalEvents.data.item1.data.length}');
    //   setState(() {
    //     events = originalEvents;
    //     filteredevents = originalEvents.data;
    //   });
    // } else {
      _bloc.call(eventName: withText);
    // }
  }

  void _toggle() {
    _innerDrawerKey.currentState.toggle(
        // direction is optional
        // if not set, the last direction will be used
        //InnerDrawerDirection.start OR InnerDrawerDirection.end
        direction: InnerDrawerDirection.start);
  }

  Future<void> _refreshList() {
    originalEvents = null;
    _bloc.call();
  }

  Future<List<Event>> _pageFetch(int offset) async {
    Tuple2<EventList, MeasurementsList> result;

    final total = _bloc.worker.paging.count;
    final left = total - offset;
    if (left <= 0) {
      return [];
    }
    final page = (offset / kDefaultMeasurementsPerPage).round();

    print(">>>>>> offset: $offset, from: $total, page: $page");

    result = await _bloc.asyncCall(searchFilter: _searchText, page: page + 1);

    print('measurementsList\n '
        'count:${_bloc.worker.paging.count}\n'
        'pageItemLimit:${_bloc.worker.paging.pageItemLimit}\n'
        'next:${_bloc.worker.paging.next}');
    print(result.item1);
    if (result.item1.data != null) {
      return result.item1.data;
    } else {
      return [];
    }
  }

  @override
  void initState() {
    _bloc = EventListWorkerBloc(widget.provider);
    _userInfoBloc = UserInfoBloc();
    print('get userInfo ${_userInfoBloc}');
    print('list selectedCompany:${SessionParameters().selectedCompany}');

    Future<Void> fetchUserType() async {
      prefs = await SharedPreferences.getInstance();

      _userType =
          EnumToString.fromString(UserType.values, prefs.getString("userType"));

      _userInfoBloc.set(userType: _userType);
      _userInfoBloc.chuckListStream.listen((user) {
        switch (user.status) {
          case Status.LOADING:
            print('loading header');
            break;
          case Status.COMPLETED:
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

    _bloc.chuckListStream.listen((event) {
      switch (event.status) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          filteredevents = event.data;
          if (originalEvents == null) {
            originalEvents = event;
          }
          break;
        case Status.ERROR:
          break;
      }
      setState(() {
        events = event;
      });
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _appVersion = 'App version: ' +
            packageInfo.version +
            ' ' +
            packageInfo.buildNumber;
      });
    });

    fetchUserType();
  }

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
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 70, left: 30, right: 8),
            child: _userInfoView(),
          ),
        ));

    Widget _createDrawerItem(
        {Icon icon, Image image, String text, GestureTapCallback onTap}) {
      return GestureDetector(
        child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Row(
          children: <Widget>[
            icon ?? SizedBox(width: 26, height: 26, child: image),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
              ),
            )
          ],
        )),
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
                content: Text('Are you sure that you want to logout?'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("Yes"),
                    onPressed: () => removeToken(),
                  ),
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text('No'),
                      onPressed: () => closePopup()),
                ],
              ));
    }

    Widget searchBar() {
      if (originalEvents == null ||
          originalEvents.data?.item1?.data?.isEmpty == true) {
        return Container();
      } else {
        return Container(
          height: 64,
          color: SessionParameters().mainBackgroundColor,
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: SessionParameters().mainFontColor.withOpacity(0.1),
              child: TextFormField(
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: SessionParameters().mainFontColor, fontSize: 13),
                controller: _searchController,
                decoration: new InputDecoration(
                    filled: true,
                    suffixIcon: Visibility(
                        visible: _searchController.value.text.isNotEmpty,
                        child: IconButton(
                          onPressed: () => _clearText(),
                          icon: Icon(
                            Icons.clear,
                            color: SessionParameters()
                                .mainFontColor
                                .withOpacity(0.8),
                          ),
                        )),
                    prefixIcon: Icon(
                      Icons.search,
                      color: SessionParameters().mainFontColor.withOpacity(0.8),
                    ),
                    hintText: 'Type to search',
                    hintStyle: TextStyle(
                        color:
                            SessionParameters().mainFontColor.withOpacity(0.8),
                        fontSize: 13),
                    border: InputBorder.none),
                onChanged: onSearchTextChanged,
              ),
            ),
          ),
        );
      }
    }

    Widget list() {
      Widget _child() {
        if (events != null) {
          switch (events.status) {
            case Status.LOADING:
              return Loading(loadingMessage: events.message);
              break;
            case Status.COMPLETED:
              var userId = _userInfo != null ? _userInfo.id.toString() : null;
              prefs.setString('temp_user', userId ?? '');
              print('buided after complete');
              print('${filteredevents.item1.data.length}');
              print('--');
              listWidget = EventsListWidget(
                  resultsList: filteredevents,
                  userType: _userType,
                  userId: userId,
                  onRefreshList: _refreshList,
                  onFetchList: _pageFetch,
                  refreshController: _refreshController);
              return listWidget;
              break;
            case Status.ERROR:
              return Error(
                errorMessage: events.message,
                onRetryPressed: () => _bloc.call(),
              );
              break;
          }
        }
        return Loading();
      }

      return Flexible(child: _child());
    }

    var scaffold = Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: _toggle),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('My Events'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: _backgroundColor,
        body: Column(
          children: [searchBar(), list()],
        ));

    var innerDrawer = InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true,
        // borderRadius: 40,
        colorTransitionScaffold: Colors.transparent,
        backgroundDecoration: BoxDecoration(color: Colors.black),
        leftChild: Material(
            child: Container(
          color: Colors.black,
          child: Column(children: [
            Expanded(
                flex: 8,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _createdHeader,
                    Divider(
                      color: Colors.white,
                    ),
                    SizedBox(height: 18),
                    _createDrawerItem(
                        icon: new Icon(
                          MdiIcons.shieldCheckOutline,
                          color: HexColor.fromHex('898A9D'),
                        ),
                        text: 'Privacy Policy and \nTerms & Conditions',
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (BuildContext context) =>
                                      PrivacyPolicyPage(showApply: false)));
                        }),
                  ],
                )),
            Expanded(child: _createDrawerItem(text: _appVersion)),
            Expanded(
                child: _createDrawerItem(
                    image: ResourceImage.imageWithName('ic_logout.png'),
                    text: '  Logout',
                    onTap: () {
                      _logoutAction();
                    }))
          ]),
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
  final void Function(int) onFetchList;
  final RefreshController refreshController;

  const EventsListWidget(
      {Key key,
      this.resultsList,
      this.userType,
      this.userId,
      this.onRefreshList,
        this.onFetchList,
      this.refreshController})
      : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _pullRefresh() async {
    await onRefreshList();
    refreshController.loadComplete();
    // why use freshWords var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {
    // if (resultsList.item1.data.isEmpty) {
    //   return EmptyStateWidget(messageName: 'There is no events yet');
    // }

    void _moveToEventAt(int index, Event event) {
      if (userId == null) {
        print('did not receive user profile info on main page');
        // return;
      }

      // var event = resultsList.item1.data[index];
      var measurements = resultsList.item2;

      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) =>
                  // LoginPage(userType: _selectedUserType)
                  EventDetailPage(
                    event: event,
                    measurementsList: null,
                    userType: userType,
                    currentUserId: userId,
                  )));
    }

    Widget itemAt(int index, Event event) {
      print('index for widget $index, event: ${event.id}');

      // var event = resultsList.item1.data[index];
      print('itemAt: $index $event');
      var eventName = event.name ?? 'Event Name';
      var companyName = event?.agency?.name ?? '-';
      var companyType = event?.agency?.type.replaceAll('_', ' ').capitalizeFirst() ?? '-';

      final startTime = event.startDateTime.toLocal();
      var eventStartDate = DateFormat('d MMM yyyy').format(startTime);
      var eventStartTime = DateFormat('h:mm a').format(startTime);

      final endTime = event.endDateTime.toLocal();
      var eventEndDate = DateFormat('d MMM yyyy').format(endTime);
      var eventEndTime = DateFormat('h:mm a').format(endTime);

      var eventStatus = event.status.displayName() ?? "In progress";
      var eventStatusColor = event.status.displayColor() ?? Colors.white;

      var _textColor = Colors.white;
      var _descriptionColor = HexColor.fromHex('898A9D');
      var _textStyle = TextStyle(color: _textColor);
      var _descriptionStyle = TextStyle(color: _descriptionColor);

      Widget _configureGraphWidgetFor(Event _event) {
        if (_event.status.shouldShowCountGraph() == true &&
            userType == UserType.salesRep) {
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
                    color: Colors.black),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                          height: 80,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    ResourceImage.imageWithName(
                                                        'ic_event_place.png'),
                                              ),
                                              SizedBox(width: 8),
                                              Flexible(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    companyName,
                                                    style: _textStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    companyType,
                                                    style: _descriptionStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ))
                                                ],
                                              ))
                                            ],
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 16,
                                                  width: 16,
                                                  child: ResourceImage
                                                      .imageWithName(
                                                          'ic_event_date.png'),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                    child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            eventStartDate,
                                                            style: _textStyle)),
                                                    Expanded(
                                                        child: Text(
                                                            eventStartTime,
                                                            style:
                                                                _descriptionStyle)),
                                                  ],
                                                ))
                                              ],
                                            ),
                                          )),
                                      Expanded(
                                          flex: 1,
                                          child: Row(
                                            children: [
                                              SizedBox(width: 24),
                                              Expanded(
                                                  child: Text(eventEndDate,
                                                      style: _textStyle)),
                                              Expanded(
                                                  child: Text(eventEndTime,
                                                      style:
                                                          _descriptionStyle)),
                                            ],
                                          ))
                                    ],
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              color: eventStatusColor
                                                  .withOpacity(0.1)),
                                          child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                eventStatus,
                                                style: TextStyle(
                                                    color: eventStatusColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Flexible(
                                            child:
                                                _configureGraphWidgetFor(event))
                                      ],
                                    ),
                                  )),
                            ],
                          ))
                    ],
                  ),
                ))),
      );

      var gesture = GestureDetector(
        child: container,
        onTap: () {
          print('did Select at $index');
          _moveToEventAt(index, event);
        },
      );

      return gesture;
    }

    // Widget listView;
    //
    // if (resultsList.item1.data.isEmpty) {
    //   listView = EmptyStateWidget(messageName: 'There is no events yet');
    // } else {
    //   listView = ListView.builder(
    //     itemCount: resultsList.item1.data.length,
    //     keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    //     itemBuilder: (_, index) => itemAt(index, null),
    //   );
    // }


    Color _refreshColor = HexColor.fromHex('#898A9D');


    Widget paginationList;
    if (resultsList.item1.data.isEmpty) {
      paginationList = EmptyStateWidget(messageName: 'There are no events yet');
    } else {
      paginationList = PaginationView<Event>(itemBuilder:  (BuildContext context, Event event, int index) =>
          itemAt(index, event),
          pullToRefresh: true,
          paginationViewType: PaginationViewType.listView,
          footer: SizedBox(height: 24),
          pageFetch: onFetchList);
    }


    var list = SmartRefresher(
        header: CustomHeader(
          builder: (BuildContext context, RefreshStatus mode) {
            Widget body;
            if (mode == RefreshStatus.idle ||
                mode == RefreshStatus.canRefresh) {
              body =
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.arrow_downward,
                  color: _refreshColor,
                ),
                SizedBox(width: 6),
                Text(
                  mode.title(),
                  style: TextStyle(color: _refreshColor, fontSize: 12),
                )
              ]);
            } else {
              body = Container();
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: refreshController,
        onLoading: _pullRefresh,
        child: paginationList,
        onRefresh: onRefreshList);
    return list;
  }
}

class UserInfoHeader extends StatelessWidget {
  final User userInfo;
  final UserType userType;

  const UserInfoHeader({Key key, this.userInfo, this.userType})
      : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        width: 40,
        height: 40,
        child: ResourceImage.imageWithName(userType.menuImageName()),
      ),
      SizedBox(width: 14),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(flex: 2, child: Container()),
          Expanded(
              flex: 2,
              child: Text('${userInfo.userFullName()}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
          Expanded(
              flex: 3,
              child: Text(userInfo.email,
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white.withOpacity(0.62)))),
          Flexible(flex: 2, child: Container())
        ],
      ))
    ]);
  }
}
