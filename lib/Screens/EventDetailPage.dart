import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/Future+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/RefreshStatus+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/EventInfoWorker.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/MeasurementsListWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/EventCompletionGraphWidget.dart';
import 'package:tdlook_flutter_app/Screens/BadgePage.dart';
import 'package:tdlook_flutter_app/Screens/RecommendationsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/utilt/emoji_utils.dart';

import 'ChooseGenderPage.dart';

class EventDetailPage extends StatefulWidget {
  final String? currentUserId;
  final UserType? userType;
  final Event? event;
  final MeasurementsList? measurementsList;

  const EventDetailPage(
      {Key? key, this.currentUserId, this.userType, this.event, this.measurementsList})
      : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> with SingleTickerProviderStateMixin {
  Event? event;
  EventInfoWorkerBloc? _eventInfoWorkerBloc;
  MeasurementsListWorkerBloc? _bloc;
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  String _searchText = '';
  bool _isKeyboardAppeare = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    event = widget.event;
    // TODO: implement initState
    _bloc = MeasurementsListWorkerBloc(event?.id.toString());
    _bloc?.call();

    _eventInfoWorkerBloc = EventInfoWorkerBloc(event?.id.toString());
    _eventInfoWorkerBloc?.chuckListStream.listen((updatedEvent) {
      if (updatedEvent.status == null) return;
      switch (updatedEvent.status!) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          setState(() {
            debugPrint('updated: ${updatedEvent.data}');
            this.event = updatedEvent.data;
          });
          break;
        case Status.ERROR:
          break;
      }
    });
    _eventInfoWorkerBloc?.call();

    SessionParameters().selectedUser = widget.userType;

    if (widget.measurementsList != null && (widget.measurementsList?.data?.length ?? 0) > 0) {
      // widget.measurementsList.data =  widget.measurementsList.data.where((i) => i.endWearer.id == widget.currentUserId).toList();
    }
  }

  void filter({String? withText}) async {
    debugPrint('filter with ${withText}');
    _searchText = withText ?? '';
    _bloc?.call(name: withText);
  }

  _clearText() {
    setState(() {
      _searchText = '';
    });
    _searchController.clear();
    filter(withText: '');
  }

  onSearchTextChanged(String text) {
    //debugPrint('update: $text');
    var searchText = EmojiUtils.removeAllEmoji(text);
    if (searchText.length < 1) {
      searchText = '';
    }
    setState(() {
      _searchText = searchText;
    });
    debugPrint("searchText: $searchText");
    FutureExtension.enableContinueTimer(delay: 1).then((value) {
      debugPrint('should search $searchText - $text');
      if (searchText == text) {
        debugPrint('searching');
        filter(withText: searchText);
      }
    });
  }

  Future<void> _refreshList() async {
    await _bloc?.call(name: _searchText);
  }

  Future<List<MeasurementResults>> _pageFetch(int offset) async {
    MeasurementsList? result;

    if (event?.status == EventStatus.scheduled) {
      return offset == 0 ? [MeasurementResults()] : [];
    }

    final total = _bloc?.worker.paging?.count ?? 0;
    final left = total - offset;
    if (left <= 0) {
      return [];
    }
    final page = (offset / kDefaultMeasurementsPerPage).round();

    result = await _bloc?.asyncCall(page: page + 1, name: _searchText);

    return result?.data ?? [];
  }

  Widget headerForList() {
    var eventName = widget.event?.name ?? 'Event Name';
    var companyName = widget.event?.agency?.name ?? '-';
    var companyType = widget.event?.agency?.type?.replaceAll('_', ' ').capitalizeFirst() ?? '-';

    final startTime = widget.event?.startDateTime?.toLocal();
    var eventStartDate = startTime != null ? DateFormat('d MMM yyyy').format(startTime) : '';
    var eventStartTime = startTime != null ? DateFormat('K:mm a').format(startTime) : '';

    final endTime = widget.event?.endDateTime?.toLocal();
    var eventEndDate = endTime != null ? DateFormat('d MMM yyyy').format(endTime) : '';
    var eventEndTime = endTime != null ? DateFormat('K:mm a').format(endTime) : '';

    var eventStatus = widget.event?.status?.displayName() ?? "In progress";
    var eventStatusColor = Colors.white;
    var eventStatusTextColor = widget.event?.status?.textColor() ?? Colors.black;

    var _textColor = Colors.white;
    var _descriptionColor = HexColor.fromHex('BEC1D4');
    var _textStyle = TextStyle(color: _textColor);
    var _descriptionStyle = TextStyle(color: _descriptionColor);

    Widget _configureGraphWidgetFor(Event? _event) {
      if (_event?.status?.shouldShowCountGraph() == true && widget.userType == UserType.salesRep) {
        return EventCompletionGraphWidget(event: _event);
      } else {
        return Container();
      }
    }

    Widget _subchild() {
      debugPrint('subchild ${_isKeyboardAppeare}');
      if (_isKeyboardAppeare == false) {
        return Padding(
            padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: HexColor.fromHex('1E7AE4')),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: TextStyle(color: Colors.white),
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
                                                  child: ResourceImage.imageWithName(
                                                      'ic_event_place.png')),
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
                                                  child: ResourceImage.imageWithName(
                                                      'ic_event_date.png'),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                    child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(eventStartDate,
                                                            style: _textStyle)),
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
                                              Expanded(
                                                  child: Text(eventEndDate, style: _textStyle)),
                                              Expanded(
                                                  child:
                                                      Text(eventEndTime, style: _descriptionStyle)),
                                            ],
                                          ))
                                    ],
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              color: eventStatusColor),
                                          child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                eventStatus,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: eventStatusTextColor),
                                              )),
                                        ),
                                        Flexible(child: _configureGraphWidgetFor(event))
                                      ],
                                    ),
                                  )),
                            ],
                          ))
                    ],
                  ),
                )));
      } else {
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: HexColor.fromHex('1E7AE4')));
      }
    }

    var container = Container(color: _backgroundColor, child: _subchild());

    var searchField = Container(
        height: 64,
        color: SessionParameters().mainBackgroundColor,
        child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                color: SessionParameters().mainFontColor.withOpacity(0.1),
                child: new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      onEditingComplete: () {
                        debugPrint('on complete');
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isKeyboardAppeare = false;
                        });
                      },
                      onTap: () {
                        debugPrint('on start');
                        setState(() {
                          _isKeyboardAppeare = true;
                        });
                      },
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 13),
                      controller: _searchController,
                      decoration: new InputDecoration(
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
                          icon: Icon(
                            Icons.search,
                            color: SessionParameters().mainFontColor.withOpacity(0.8),
                          ),
                          hintText: 'Search by end-wearer\'s name or email',
                          hintStyle: TextStyle(
                              color: SessionParameters().mainFontColor.withOpacity(0.8),
                              fontSize: 12),
                          border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    )))));

    var column = Column(
      children: [
        AnimatedSize(
            vsync: this,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 500),
            child: container),
        widget.userType != UserType.endWearer ? searchField : Container()
      ],
    );
    return column;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget listBody() {
      if (widget.measurementsList != null && widget.measurementsList?.data?.length != 0) {
        debugPrint('config list body');
        return MeasuremetsListWidget(
            event: event,
            measurementsList: widget.measurementsList,
            userType: widget.userType,
            onRefreshList: _refreshList,
            refreshController: _refreshController);
      } else {
        debugPrint('config list body async');
        return StreamBuilder<Response<MeasurementsList>>(
          stream: _bloc?.chuckListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              debugPrint('status: ${snapshot.data?.status}');
              if (snapshot.data?.status == null) return const SizedBox();
              switch (snapshot.data!.status!) {
                case Status.LOADING:
                  return Center(child: Loading(loadingMessage: snapshot.data?.message));
                case Status.COMPLETED:
                  return MeasuremetsListWidget(
                      event: event,
                      measurementsList: snapshot.data?.data,
                      userType: widget.userType,
                      currentUserId: widget.currentUserId,
                      onRefreshList: _refreshList,
                      onFetchList: _pageFetch,
                      refreshController: _refreshController);
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data?.message,
                    onRetryPressed: () => _bloc?.call(name: _searchText),
                  );
              }
            }
            return Container(width: 0.0, height: 0.0);
          },
        );
      }
    }

    var scaffold = Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          title: Text('Event details'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: _backgroundColor,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [headerForList(), listBody()]));

    return scaffold;
  }
}

class MeasuremetsListWidget extends StatefulWidget {
  final String? currentUserId;
  final Event? event;
  final MeasurementsList? measurementsList;
  final UserType? userType;
  final RefreshController? refreshController;
  final AsyncCallback? onRefreshList;
  final Future<List<MeasurementResults>> Function(int)? onFetchList;

  const MeasuremetsListWidget(
      {Key? key,
      this.event,
      this.measurementsList,
      this.userType,
      this.currentUserId,
      this.onRefreshList,
      this.onFetchList,
      this.refreshController})
      : super(key: key);

  @override
  _MeasuremetsListWidgetState createState() => _MeasuremetsListWidgetState();
}

class _MeasuremetsListWidgetState extends State<MeasuremetsListWidget> {
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _pullRefresh() async {
    await widget.onRefreshList?.call();
    widget.refreshController?.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    void _moveToMeasurementAt(MeasurementResults? measurement) {
      // var measurement = measurementsList.data[index];
      measurement?.askForWaistLevel = widget.event?.shouldAskForWaistLevel();
      measurement?.askForOverlap = widget.event?.manualOverlap;
      debugPrint('open measurement\n '
          'id:${measurement?.id}\n'
          'uuid:${measurement?.uuid}');

      // TODO: Uncommin for test
      // if (Application.isInDebugMode) {
      //   if (SessionParameters().selectedCompany == CompanyType.armor) {
      //     Navigator.push(
      //         context,
      //         CupertinoPageRoute(
      //             builder: (BuildContext context) =>
      //                 BadgePage(arguments: BadgePageArguments(measurement, widget.userType))));
      //   } else {
      //     Navigator.push(
      //         context,
      //         CupertinoPageRoute(
      //             builder: (BuildContext context) =>
      //                 ChooseGenderPage(argument: ChooseGenderPageArguments(measurement))));
      //   }
      //   return;
      // }

      if (measurement?.isComplete == false && widget.event?.status == EventStatus.in_progress) {
        // if sales rep - open gender
        if (SessionParameters().selectedCompany == CompanyType.armor) {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) =>
                      BadgePage(arguments: BadgePageArguments(measurement, widget.userType))));
        } else {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) =>
                      ChooseGenderPage(argument: ChooseGenderPageArguments(measurement))));
        }
      } else if (measurement?.isComplete == true) {
        Navigator.pushNamed(context, RecommendationsPage.route,
            arguments:
                RecommendationsPageArguments(measurement: measurement, showRestartButton: false));
      } else if (widget.event?.status != EventStatus.in_progress) {
        // _showCupertinoDialog('Event is not in progress now');
      }
    }

    _showCupertinoDialog(String text) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => new CupertinoAlertDialog(
                // title: new Text("Cupertino Dialog"),
                content: new Text(text),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    }

    void closePopup() {
      Navigator.of(context, rootNavigator: true).pop("Discard");
    }

    Future<void> openSetting() async {
      debugPrint('open settings');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                content: new Text(
                    'Oops! Widget requires access to the camera to allow you to make photos that are required to calculate your body measurements. Please reopen widget and try again.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("Open Settings"),
                    onPressed: () => {openAppSettings(), closePopup()},
                  ),
                  CupertinoDialogAction(
                      isDefaultAction: true, child: Text('Discard'), onPressed: () => closePopup()),
                ],
              ));
    }

    Future<void> askForPermissionsAndMove(MeasurementResults? _measurement) async {
      debugPrint('askForPermissionsAndMove');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
      ].request();

      debugPrint('statuses: $statuses');
      if (statuses[Permission.camera] == PermissionStatus.granted) {
        _moveToMeasurementAt(_measurement);
      } else if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied) {
        openSetting();
      }
    }

    Future<void> checkPermissionsAndMoveTo({MeasurementResults? measurement}) async {
      // var measurement = measurementsList.data[index];

      if (Application.isInDebugMode == false) {
        if (measurement?.isComplete == false && widget.event?.status == EventStatus.in_progress) {
          // move to camera permissions
        } else if (measurement?.isComplete == true) {
          _moveToMeasurementAt(measurement);
          return;
        } else if (widget.event?.status != EventStatus.in_progress) {
          return;
        }
      } else {
        _moveToMeasurementAt(measurement);
        return;
      }

      var cameraStatus = await Permission.camera.status;
      var isPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
      var isDenied = await Permission.camera.isDenied;
      var isGranted = await Permission.camera.isGranted;
      var isRestricted = await Permission.camera.isRestricted;

      debugPrint('isRestricted: $isRestricted');
      debugPrint('isGranted: $isGranted');
      debugPrint('status: $cameraStatus');
      debugPrint('isPermanentlyDenied: $isPermanentlyDenied');
      debugPrint('isDenied: $isDenied');

      if (await cameraStatus.isGranted == false &&
          await cameraStatus.isPermanentlyDenied == false &&
          await Permission.camera.isRestricted == false) {
        askForPermissionsAndMove(measurement);
      } else if (await Permission.camera.isRestricted ||
          await Permission.camera.isDenied ||
          await cameraStatus.isPermanentlyDenied) {
        openSetting();
        // The OS restricts access, for example because of parental controls.
      } else {
        _moveToMeasurementAt(measurement);
      }
    }

    Widget itemAt({int? index, MeasurementResults? measurement, bool? showEmptyView}) {
      Container container;

      if (showEmptyView == true) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: EmptyStateWidget(
                messageName:
                    'The event has not been started yet. \nPlease wait until the start date'));
      }

      var ind = (index ?? 0) - 1;
      // var measurement = measurementsList.data[ind];

      var userName = measurement?.endWearer?.name ?? '-';
      var userEmail = measurement?.endWearer?.email ?? '-';

      final completeMeasureTime = measurement?.completedAtTime?.toLocal();

      var measurementDate;
      if (completeMeasureTime != null) {
        var completeDate = DateFormat('d MMM yyyy').format(completeMeasureTime);
        var completeTime = DateFormat('h:mm a').format(completeMeasureTime);

        measurementDate = '$completeDate, $completeTime';
      } else {
        measurementDate = '-';
      }

      var measurementStatus = measurement?.statusName() ?? "-";
      var eventStatusColor = measurement?.statusColor() ?? Colors.white;
      var eventStatusIcon = measurement?.statusIconName() ?? '-';

      var _textColor = Colors.white;
      var _descriptionColor = HexColor.fromHex('BEC1D4');
      var _textStyle = TextStyle(color: _textColor);
      var _descriptionStyle = TextStyle(color: _descriptionColor);

      bool isMyMeasure = false;
      if (widget.userType == UserType.endWearer &&
          measurement?.endWearer?.id.toString() == widget.currentUserId) {
        isMyMeasure = true;
      }

      bool showDate = true;
      if (isMyMeasure == true && measurement?.isComplete == false) {
        showDate = false;
      }

      bool canAddMeasurement = true;
      if (showDate == false && widget.event?.status == EventStatus.completed) {
        canAddMeasurement = false;
      }

      Widget dateLineWidget() {
        if (showDate) {
          return Expanded(
              flex: 1,
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: ResourceImage.imageWithName('ic_checkmark.png'),
                    ),
                    SizedBox(width: 8),
                    Text(measurementDate, style: _textStyle)
                  ],
                ),
              ));
        } else {
          debugPrint('canAddMeasurement: ${canAddMeasurement}');
          Widget content;
          if (canAddMeasurement) {
            content = MaterialButton(
              onPressed: (() {
                checkPermissionsAndMoveTo(measurement: measurement);
              }),
              textColor: Colors.white,
              child: Text(
                'FIND MY FIT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              color: SessionParameters().selectionColor,
              // padding: EdgeInsets.only(left: 12, right: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            );
          } else {
            content = EmptyStateWidget(
                messageName:
                    'The event has been already finished.\nPlease contact your sales representative.',
                iconName: 'ic_clock.png');
          }

          return Expanded(
              flex: 4,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 0.5, child: Container(color: SessionParameters().optionColor)),
                  SizedBox(height: 16),
                  Flexible(child: content)
                ],
              ));
        }
      }

      container = Container(
        color: _backgroundColor,
        child: Padding(
            padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
            child: Container(
                color: Colors.black,
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.all(Radius.circular(5)),
                //     color: Colors.black
                // ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(userName, style: TextStyle(color: Colors.white)),
                            ),
                            isMyMeasure
                                ? Flexible(
                                    flex: 2,
                                    child: Container(
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                                color: Colors.white.withOpacity(0.1)),
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 3, bottom: 3, left: 5, right: 5),
                                                child: Text('You',
                                                    style: TextStyle(color: Colors.white))))))
                                : Container(),
                            Spacer(),
                            Container(
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
                                        child: Row(children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: ResourceImage.imageWithName(eventStatusIcon),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            measurementStatus,
                                            style: TextStyle(color: eventStatusColor),
                                          )
                                        ]),
                                      ))
                                ],
                              ),
                            )
                          ]),
                      SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                          height: showDate
                              ? 52
                              : canAddMeasurement
                                  ? 90
                                  : 170,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  height: 16,
                                                  width: 16,
                                                  child: ResourceImage.imageWithName(
                                                      'ic_contact.png')),
                                              SizedBox(width: 8),
                                              Flexible(
                                                  child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    userEmail,
                                                    style: _textStyle,
                                                    overflow: TextOverflow.ellipsis,
                                                  )),
                                                ],
                                              ))
                                            ],
                                          )),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      dateLineWidget(),
                                    ],
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
          debugPrint('did Select at $index');
          checkPermissionsAndMoveTo(measurement: measurement);
          // _moveToMeasurementAt(index-1);
        },
      );

      return gesture;
    }

    var eventInfoViewCount = 1;
    var measurementsCount = widget.measurementsList?.data?.length ?? 0;
    var emptyStateViewCount = 0;
    if (widget.event?.status == EventStatus.scheduled) {
      measurementsCount = 0;
      emptyStateViewCount = 1;
    }

    var paginationList = PaginationView<MeasurementResults>(
        itemBuilder: (BuildContext context, MeasurementResults measurement, int index) =>
            itemAt(index: index, measurement: measurement, showEmptyView: emptyStateViewCount == 1),
        pullToRefresh: true,
        paginationViewType: PaginationViewType.listView,
        footer: SliverToBoxAdapter(child: SizedBox(height: 24)),
        scrollDirection: Axis.vertical,
        onError: (dynamic error) => Center(
              child: Text('Some error occured'),
            ),
        onEmpty: Center(
          child: const SizedBox(),
        ),
        pageFetch: widget.onFetchList!);

    Color _refreshColor = HexColor.fromHex('#898A9D');
    var list = SmartRefresher(
        header: CustomHeader(
          builder: (context, mode) {
            Widget body;
            if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
              body = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.arrow_downward,
                  color: _refreshColor,
                ),
                SizedBox(width: 6),
                Text(
                  mode?.title() ?? '',
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
        controller: widget.refreshController!,
        onLoading: _pullRefresh,
        child: paginationList,
        onRefresh: widget.onRefreshList);

    return Expanded(child: paginationList);

    // return RefreshView(
    //   controller: widget.refreshController,
    //   child: listView,
    //   onRefresh: widget.onRefreshList,
    //   onLoading: _pullRefresh,
    // );
  }
}
