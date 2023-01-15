import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/Future+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/EventListWorker.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UserInfoWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/UserModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/EventCompletionGraphWidget.dart';
import 'package:tdlook_flutter_app/ScreenComponents/inner_drawer/inner_drawer.dart';
import 'package:tdlook_flutter_app/Screens/EventDetailPage.dart';
import 'package:tdlook_flutter_app/Screens/PrivacyPolicyPage.dart';
import 'package:tdlook_flutter_app/Screens/SettingsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/common/utils/emoji_utils.dart';
import 'package:tdlook_flutter_app/constants/global.dart';
import 'package:tdlook_flutter_app/main.dart';
import 'package:tuple/tuple.dart';

class EventsPage extends StatefulWidget {
  final String? provider;
  EventsPage({this.provider});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  EventListWorkerBloc? _bloc;
  UserInfoBloc? _userInfoBloc;
  UserType _userType = UserType.salesRep;
  User? _userInfo;

  String _appVersion = '';
  EventsListWidget? listWidget;
  SharedPreferences? prefs;
  String? _provider;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  Response<Tuple2<EventList, MeasurementsList>>? events;
  Response<Tuple2<EventList, MeasurementsList>>? originalEvents;
  Tuple2<EventList, MeasurementsList>? filteredevents;

  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  TextEditingController _searchController = TextEditingController();

  String? _searchText;
  _clearText() {
    _searchText = '';
    _searchController.clear();
    filter(withText: '');
  }

  // Map _source = {ConnectivityResult.mobile: true};
  // MyConnectivity _connectivity = MyConnectivity.instance;
  // bool _isConnected = true;

  onSearchTextChanged(String text) {
    //logger.d('update: $text');
    var searchText = EmojiUtils.removeAllEmoji(text);
    if (searchText.length < 1) {
      searchText = '';
    }
    _searchText = searchText;
    logger.d("searchText: $searchText");
    FutureExtension.enableContinueTimer(delay: 1).then((value) {
      logger.d('should search $searchText - $text');
      if (searchText == text) {
        logger.i('searching');
        filter(withText: searchText);
      }
    });
  }

  filter({String? withText}) async {
    // if (originalEvents == null) return;
    //
    // if (withText.isEmpty) {
    //  logger.d('or: ${originalEvents.data.item1.data.length}');
    //   setState(() {
    //     events = originalEvents;
    //     filteredevents = originalEvents.data;
    //   });
    // } else {
    _bloc?.call(eventName: withText);
    // }
  }

  void _toggle() {
    _innerDrawerKey.currentState?.toggle(
        // direction is optional
        // if not set, the last direction will be used
        //InnerDrawerDirection.start OR InnerDrawerDirection.end
        direction: InnerDrawerDirection.start);
  }

  Future<void> _refreshList() async {
    originalEvents = null;
    await _bloc?.call();
  }

  Future<List<Event>> _pageFetch(int offset) async {
    Tuple2<EventList, MeasurementsList>? result;

    final total = _bloc?.worker.paging?.count ?? 0;
    final left = total - offset;
    if (left <= 0) {
      return [];
    }
    final page = (offset / kDefaultMeasurementsPerPage).round();

    logger.d(">>>>>> offset: $offset, from: $total, page: $page");

    result = await _bloc?.asyncCall(searchFilter: _searchText, page: page + 1);

    logger.d('measurementsList\n '
        'count:${_bloc?.worker.paging?.count}\n'
        'pageItemLimit:${_bloc?.worker.paging?.pageItemLimit}\n'
        'next:${_bloc?.worker.paging?.next}');
    if (result?.item1.data != null) {
      return result?.item1.data ?? [];
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _provider = kCompanyTypeArmorOnly ? CompanyType.armor.apiKey() : widget.provider;
    _bloc = EventListWorkerBloc(_provider);
    _userInfoBloc = UserInfoBloc();
    logger.d('get userInfo $_userInfoBloc');
    logger.d('list selectedCompany:${SessionParameters().selectedCompany}');

    Future<void> fetchUserType() async {
      prefs = await SharedPreferences.getInstance();
      Application.isProMode = prefs?.getBool(SessionParameters.keyProMode) ?? false;
      final value = prefs?.getString('userType');
      if (value != null) {
        _userType = EnumToString.fromString(UserType.values, value)!;
      }

      _userInfoBloc?.set(userType: _userType);
      _userInfoBloc?.chuckListStream?.listen((user) {
        if (user.status == null) return;
        switch (user.status!) {
          case Status.LOADING:
            break;
          case Status.COMPLETED:
            if (_userType == UserType.salesRep) {
              SessionParameters().selectedCompany =
                  kCompanyTypeArmorOnly ? CompanyType.armor : user.data?.provider;
            }
            setState(() {
              _userInfo = user.data;
            });

            _bloc?.set(_userType, user.data?.role, user.data?.id?.toString());
            _bloc?.call();

            break;
          case Status.ERROR:
            break;
        }
      });
      _userInfoBloc?.call();

      // _connectivity.initialise();
      // _connectivity.myStream.listen((source) {
      //   _source = source;
      //   var isConnected = _source.keys.toList()[0] != ConnectivityResult.none;
      //  logger.d('connection: ${_source.keys.toList()[0] }');
      //  logger.d('connection to network: $source, isConnected: $isConnected');
      // });
    }

    _bloc?.chuckListStream.listen((event) {
      if (event.status == null) return;
      switch (event.status!) {
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
      if (mounted) {
        setState(() {
          events = event;
        });
      }
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _appVersion = 'App version: ' + packageInfo.version + ' (' + packageInfo.buildNumber + ')';
      });
    });

    fetchUserType();
  }

  Widget? _createdHeader;

  @override
  Widget build(BuildContext context) {
    Widget _userInfoView() {
      if (_userInfo == null) {
        return CircularProgressIndicator();
      } else {
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

    Widget _createDrawerItem({Icon? icon, Image? image, String? text, GestureTapCallback? onTap}) {
      return GestureDetector(
        child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Row(
              children: <Widget>[
                icon ?? SizedBox(width: 26, height: 26, child: image),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    text ?? '',
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
        prefs.remove(SessionParameters.keyProMode);
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
                      isDefaultAction: true, child: Text('No'), onPressed: () => closePopup()),
                ],
              ));
    }

    Widget searchBar() {
      if (originalEvents == null || originalEvents?.data?.item1.data?.isEmpty == true) {
        return Container();
      } else {
        return Container(
          height: 64,
          color: SessionParameters().mainBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: SessionParameters().mainFontColor.withOpacity(0.1),
              child: TextFormField(
                textAlign: TextAlign.center,
                style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 13),
                controller: _searchController,
                decoration: InputDecoration(
                    filled: true,
                    suffixIcon: Visibility(
                        visible: _searchController.value.text.isNotEmpty,
                        child: IconButton(
                          onPressed: () => _clearText(),
                          icon: Icon(
                            Icons.clear,
                            color: SessionParameters().mainFontColor.withOpacity(0.8),
                          ),
                        )),
                    prefixIcon: Icon(
                      Icons.search,
                      color: SessionParameters().mainFontColor.withOpacity(0.8),
                    ),
                    hintText: 'Type to search',
                    hintStyle: TextStyle(
                        color: SessionParameters().mainFontColor.withOpacity(0.8), fontSize: 13),
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
          switch (events!.status!) {
            case Status.LOADING:
              return Loading(loadingMessage: events?.message);
            case Status.COMPLETED:
              var userId = _userInfo != null ? _userInfo?.id.toString() : null;
              prefs?.setString('temp_user', userId ?? '');

              listWidget = EventsListWidget(
                  resultsList: filteredevents,
                  userType: _userType,
                  userId: userId,
                  onRefreshList: _refreshList,
                  onFetchList: _pageFetch,
                  refreshController: _refreshController);
              return listWidget!;
            case Status.ERROR:
              return Error(
                errorMessage: events?.message,
                onRetryPressed: () => _bloc?.call(),
              );
          }
        }
        return Loading();
      }

      return Flexible(child: _child());
    }

    var scaffold = Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: _toggle),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('My Events'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: _backgroundColor,
        body: Column(
          children: [
            Visibility(
              child: searchBar(),
              visible: (filteredevents?.item2.data?.length ?? 0) > 1,
            ),
            list(),
          ],
        ));

    Widget settingsWidget() {
      if (_userType == UserType.salesRep) {
        return _createDrawerItem(
            image: ResourceImage.imageWithName('settings_icon.png'),
            text: 'Settings',
            onTap: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (BuildContext context) => SettingsPage()));
            });
      } else {
        return Container();
      }
    }

    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      colorTransitionScaffold: Colors.transparent,
      backgroundDecoration: BoxDecoration(color: Colors.black),
      leftChild: Material(
        child: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 8,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _createdHeader ?? const SizedBox(),
                    Divider(
                      color: Colors.white,
                    ),
                    SizedBox(height: 18),
                    _createDrawerItem(
                        image: ResourceImage.imageWithName('privacy_icon.png'),
                        text: 'Privacy Policy and \nTerms of Use',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (BuildContext context) =>
                                  PrivacyPolicyPage(showApply: false),
                            ),
                          );
                        }),
                    SizedBox(height: 18),
                    settingsWidget()
                  ],
                ),
              ),
              Expanded(child: _createDrawerItem(text: _appVersion)),
              Expanded(
                child: _createDrawerItem(
                  image: ResourceImage.imageWithName('ic_logout.png'),
                  text: '  Logout',
                  onTap: () {
                    _logoutAction();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      scaffold: scaffold,
    ); //innerDrawer;
  }
}

class EventsListWidget extends StatelessWidget {
  final String? userId;
  final UserType? userType;
  final Tuple2<EventList, MeasurementsList>? resultsList;
  final AsyncCallback? onRefreshList;
  final Future<List<Event>> Function(int)? onFetchList;
  final RefreshController? refreshController;

  const EventsListWidget(
      {Key? key,
      this.resultsList,
      this.userType,
      this.userId,
      this.onRefreshList,
      this.onFetchList,
      this.refreshController})
      : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _pullRefresh() async {
    await onRefreshList?.call();
    refreshController?.loadComplete();
    // why use freshWords var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {
    // if (resultsList.item1.data.isEmpty) {
    //   return EmptyStateWidget(messageName: 'There is no events yet');
    // }

    void _moveToEventAt(int index, Event event) {
      if (userId == null) {
        logger.i('did not receive user profile info on main page');
        // return;
      }

      // var event = resultsList.item1.data[index];
      var measurements = resultsList?.item2;

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
            onUpdate: () {
              _pullRefresh();
            },
          ),
        ),
      );
    }

    Widget itemAt(int index, Event event) {
      var eventName = event.name ?? 'Event Name';
      var companyName = event.agency?.name ?? '-';
      var companyType = event.agency?.type?.replaceAll('_', ' ').capitalizeFirst() ?? '-';

      final startTime = event.startDateTime?.toLocal();
      var eventStartDate = startTime != null ? DateFormat(kDefaultDateFormat).format(startTime) : '';
      var eventStartTime = startTime != null ? DateFormat(kDefaultHoursFormat).format(startTime) : '';

      final endTime = event.endDateTime?.toLocal();
      var eventEndDate = endTime != null ? DateFormat(kDefaultDateFormat).format(endTime) : '';
      var eventEndTime = endTime != null ? DateFormat(kDefaultHoursFormat).format(endTime) : '';

      var eventStatus = event.status?.displayName() ?? "In progress";
      var eventStatusColor = event.status?.displayColor() ?? Colors.white;

      var _textColor = Colors.white;
      var _descriptionColor = HexColor.fromHex('898A9D');
      var _textStyle = TextStyle(color: _textColor);
      var _descriptionStyle = TextStyle(color: _descriptionColor);

      Widget _configureGraphWidgetFor(Event _event) {
        if (_event.status?.shouldShowCountGraph() == true && userType == UserType.salesRep) {
          return EventCompletionGraphWidget(event: _event);
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
                borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.black),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: ResourceImage.imageWithName('ic_event_place.png'),
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                            child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              companyName,
                                              style: _textStyle,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                            Expanded(
                                                child: Text(
                                              companyType,
                                              style: _descriptionStyle,
                                              overflow: TextOverflow.ellipsis,
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: ResourceImage.imageWithName('ic_event_date.png'),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(eventStartDate, style: _textStyle)),
                                              Expanded(
                                                  child: Text(eventStartTime,
                                                      style: _descriptionStyle)),
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
                                        Expanded(child: Text(eventEndDate, style: _textStyle)),
                                        Expanded(
                                            child: Text(eventEndTime, style: _descriptionStyle)),
                                      ],
                                    ))
                              ],
                            )),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      color: eventStatusColor.withOpacity(0.1)),
                                  child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        eventStatus,
                                        style: TextStyle(
                                            color: eventStatusColor, fontWeight: FontWeight.bold),
                                      )),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Flexible(child: _configureGraphWidgetFor(event))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

      var gesture = GestureDetector(
        child: container,
        onTap: () {
          logger.d('did Select at $index');
          _moveToEventAt(index, event);
        },
      );

      return gesture;
    }

    Widget paginationList;
    if (resultsList?.item1.data?.isEmpty == true) {
      paginationList = EmptyStateWidget(messageName: 'There are no events yet');
    } else {
      paginationList = LayoutBuilder(
        builder: (context, constraints) {
          var itemsCount = resultsList?.item1.data?.length ?? 0;
          var footerHeight = constraints.maxHeight - 138 * itemsCount;
          return PaginationView<Event>(
              itemBuilder: (BuildContext context, Event event, int index) => itemAt(index, event),
              pullToRefresh: true,
              paginationViewType: PaginationViewType.listView,
              footer:
                  SliverToBoxAdapter(child: SizedBox(height: footerHeight < 0 ? 0 : footerHeight)),
              scrollDirection: Axis.vertical,
              onError: (dynamic error) => Center(
                    child: Text('Some error occured'),
                  ),
              onEmpty: Center(
                child: const SizedBox(),
              ),
              pageFetch: onFetchList!);
        },
      );
    }
    return paginationList;
  }
}

class UserInfoHeader extends StatelessWidget {
  final User? userInfo;
  final UserType? userType;

  const UserInfoHeader({Key? key, this.userInfo, this.userType}) : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        width: 40,
        height: 40,
        child: ResourceImage.imageWithName(userType?.menuImageName() ?? ''),
      ),
      SizedBox(width: 14),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(flex: 2, child: Container()),
          Expanded(
              flex: 2,
              child: Text('${userInfo?.userFullName() ?? ''}',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(
              flex: 3,
              child: Text(userInfo?.email ?? '',
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
