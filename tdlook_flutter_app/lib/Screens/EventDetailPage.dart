
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/EventCompletionGraphWidget.dart';
import 'package:tdlook_flutter_app/Screens/BadgePage.dart';
import 'package:tdlook_flutter_app/Screens/RecommendationsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/MeasurementsListWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'ChooseGenderPage.dart';
import 'package:tdlook_flutter_app/Extensions/RefreshStatus+Extension.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final String currentUserId;
  final UserType userType;
  final Event event;
  final MeasurementsList measurementsList;

  const EventDetailPage({ Key key, this.currentUserId, this.userType, this.event, this.measurementsList}): super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {

  MeasurementsListWorkerBloc _bloc;
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    _bloc = MeasurementsListWorkerBloc(widget.event.id.toString());
    _bloc.call();

    SessionParameters().selectedUser = widget.userType;

    if (widget.measurementsList != null && widget.measurementsList.data.length > 0) {
      // widget.measurementsList.data =  widget.measurementsList.data.where((i) => i.endWearer.id == widget.currentUserId).toList();
    }
  }

  Future<void> _refreshList() {
    _bloc.call();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget listBody() {
      if (widget.measurementsList != null && widget.measurementsList.data.length != 0) {
        print('config list body');
        return MeasuremetsListWidget(event: widget.event,
            measurementsList: widget.measurementsList,
            userType: widget.userType,
            onRefreshList: _refreshList,
            refreshController: _refreshController);
      } else {
        print('config list body async');
        return StreamBuilder<Response<MeasurementsList>>(
          stream: _bloc.chuckListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print('status: ${snapshot.data.status}');
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return MeasuremetsListWidget(event: widget.event,
                    measurementsList: snapshot.data.data,
                    userType: widget.userType,
                    currentUserId: widget.currentUserId,
                    onRefreshList: _refreshList,
                    refreshController: _refreshController);
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
        );
      }
    }

    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Event details'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: listBody()
    );

    return scaffold;
  }
}

class MeasuremetsListWidget extends StatelessWidget {
  final String currentUserId;
  final Event event;
  final MeasurementsList measurementsList;
  final UserType userType;
  final RefreshController refreshController;
  final AsyncCallback onRefreshList;


  const MeasuremetsListWidget({Key key, this.event, this.measurementsList, this.userType, this.currentUserId, this.onRefreshList, this.refreshController}) : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _pullRefresh() async {
    await onRefreshList();
    refreshController.loadComplete();
  }




  @override
  Widget build(BuildContext context) {

    void _moveToMeasurementAt(int index) {

      var measurement = measurementsList.data[index];
      print('open measurement\n '
          'id:${measurement.id}\n'
          'uuid:${measurement.uuid}');
      // if (Application.isInDebugMode) {
      //   Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      //       ChooseGenderPage(argument:  ChooseGenderPageArguments(measurement))
      //   ));
      //   return;
      // }

      if (measurement.isComplete == false && event.status == EventStatus.in_progress) {
        // if sales rep - open gender
        if (SessionParameters().selectedCompany == CompanyType.armor) {
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
              BadgePage(arguments:  BadgePageArguments(measurement, userType))
          ));
        } else {
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
              ChooseGenderPage(argument:  ChooseGenderPageArguments(measurement))
          ));
        }

      } else if (measurement.isComplete == true) {

        Navigator.pushNamed(context, RecommendationsPage.route,
            arguments: RecommendationsPageArguments(measurement: measurement, showRestartButton: false));

      } else if (event.status != EventStatus.in_progress) {
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

    Future<void> askForPermissionsAndMove(int index) async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
      ].request();
      if (statuses[Permission.camera] == PermissionStatus.granted) {
        _moveToMeasurementAt(index);
      }
    }

    void closePopup() {
      Navigator.of(context, rootNavigator: true).pop("Discard");
    }

    Future<void> openSetting() async {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            content: new Text('Oops! Widget requires access to the camera to allow you to make photos that are required to calculate your body measurements. Please reopen widget and try again.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Open Settings"),
                onPressed: () => {
                  openAppSettings(),
                  closePopup()
                },
              ),
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Discard'),
                  onPressed: () => closePopup()
              ),
            ],
          )
      );
    }




    Future<void> checkPermissionsAndMoveTo({int index}) async {

      var measurement = measurementsList.data[index];

      if (Application.isInDebugMode == false) {
        if (measurement.isComplete == false && event.status == EventStatus.in_progress) {
          // move to camera permissions
        } else if (measurement.isComplete == true) {
          _moveToMeasurementAt(index);
          return;
        } else if (event.status != EventStatus.in_progress) {
          return;
        }
      }



      var cameraStatus = await Permission.camera.status;

      print('cameraStatus: ${cameraStatus.toString()}');

      if (await cameraStatus.isGranted == false && await cameraStatus.isPermanentlyDenied == false) {
        askForPermissionsAndMove(index);
      } else if (await Permission.camera.isRestricted || await Permission.camera.isDenied || await cameraStatus.isPermanentlyDenied) {
        openSetting();
        // The OS restricts access, for example because of parental controls.
      } else {
        _moveToMeasurementAt(index);
      }
    }


    Widget itemAt({int index, bool showEmptyView}) {

      Container container;

      if (index == 0) {

        var eventName = event?.name ?? 'Event Name';
        var companyName = event.agency?.name ?? '-';
        var companyType = event.agency?.type ?? '-';

        final startTime = event.startDateTime.toLocal();
        var eventStartDate = DateFormat('d MMM yyyy').format(startTime);
        var eventStartTime = DateFormat('K:mm a').format(startTime);

        final endTime = event.endDateTime.toLocal();
        var eventEndDate = DateFormat('d MMM yyyy').format(endTime);
        var eventEndTime = DateFormat('K:mm a').format(endTime);

        var eventStatus = event.status.displayName() ?? "In progress";
        var eventStatusColor = Colors.white;
        var eventStatusTextColor = event.status.textColor() ?? Colors.black;


        var _textColor = Colors.white;
        var _descriptionColor = HexColor.fromHex('BEC1D4');
        var _textStyle = TextStyle(color: _textColor);
        var _descriptionStyle = TextStyle(color: _descriptionColor);

        Widget _configureGraphWidgetFor(Event _event) {
          if (_event.status.shouldShowCountGraph() == true && userType == UserType.salesRep) {
            return EventCompletionGraphWidget(event: _event);
          } else {
            return Container();
          }
        }
        

        container = Container(
          color: _backgroundColor,
          child: Padding(
              padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: HexColor.fromHex('1E7AE4')
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eventName, style: TextStyle(color: Colors.white),),
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
                                                  child: ResourceImage.imageWithName('ic_event_place.png')),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(4)), 
                                                color: eventStatusColor), 
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(eventStatus,
                                                style: TextStyle(fontWeight: FontWeight.bold,
                                                    color: eventStatusTextColor),)),),
                                          Flexible(child: _configureGraphWidgetFor(event))
                                        ],),)),
                              ],
                            ))
                      ],
                    ),
                  )
              )),
        );

      } else {

        if (showEmptyView) {
          return Container(height: MediaQuery.of(context).size.height * 0.5, child:EmptyStateWidget(messageName: 'The event has not been started yet. \nPlease wait until the start date'));
        }


        var ind = index - 1;
        var measurement = measurementsList.data[ind];

        var userName = measurement.endWearer.name ?? '-';
        var userEmail = measurement.endWearer.email ?? '-';


        final completeMeasureTime = measurement.completedAtTime?.toLocal();

        var measurementDate;
        if (completeMeasureTime != null) {
          var completeDate = DateFormat('d MMM yyyy').format(completeMeasureTime);
          var completeTime = DateFormat('K:mm a').format(completeMeasureTime);

          measurementDate = '$completeDate, $completeTime';
        } else {
          measurementDate = '-';
        }

        var measurementStatus = measurement.statusName() ?? "-";
        var eventStatusColor = measurement.statusColor() ?? Colors.white;
        var eventStatusIcon = measurement.statusIconName() ?? '-';


        var _textColor = Colors.white;
        var _descriptionColor = HexColor.fromHex('BEC1D4');
        var _textStyle = TextStyle(color: _textColor);
        var _descriptionStyle = TextStyle(color: _descriptionColor);

        bool isMyMeasure = false;
        if (this.userType == UserType.endWearer && measurement.endWearer?.id.toString() == this.currentUserId) {
          isMyMeasure = true;
        }

        bool showDate = true;
        if (isMyMeasure == true && measurement.isComplete == false) {
          showDate = false;
        }

        bool canAddMeasurement = true;
        if (showDate == false && event.status == EventStatus.completed) {
          canAddMeasurement = false;
        }




        Widget dateLineWidget() {
          if (showDate) {
            return  Expanded(flex: 1,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .start,
                    children: [
                      SizedBox(height: 16,
                        width: 16,
                        child: ResourceImage.imageWithName(
                            'ic_checkmark.png'),),
                      SizedBox(width: 8),
                      Text(
                          measurementDate,
                          style: _textStyle)
                    ],),));
          } else {

            print('canAddMeasurement: ${canAddMeasurement}');
            Widget content;
            if (canAddMeasurement) {
              content = MaterialButton(
                onPressed: (() {
                  checkPermissionsAndMoveTo(index:index-1);
                }),
                textColor: Colors.white,
                child: Text('FIND MY FIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                color: SessionParameters().selectionColor,
                // padding: EdgeInsets.only(left: 12, right: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            } else {
              content = EmptyStateWidget(
                  messageName: 'The event has been already finished.\nPlease contact your sales representative.',
                  iconName: 'ic_clock.png');
            }


            return Expanded(
              flex:4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [SizedBox(height: 0.5, child: Container(color: SessionParameters().optionColor)),
              SizedBox(height: 16),
                Expanded(child:
                content)],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(flex: 2, child:Text(userName, style: TextStyle(color: Colors.white)),),
                              isMyMeasure ? Flexible(flex: 2, child: Container(child: Flexible( child:Container(decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(4)),
                                  color: Colors.white.withOpacity(0.1)
                              ), child: Padding(
                                padding: EdgeInsets.only(top: 3, bottom: 3, left: 5, right: 5),
                                child: Text('You', style: TextStyle(color: Colors.white))))))) : Container(),
                              Spacer(),
                              Container(
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
                                            child: Row(
                                                children:[
                                                  SizedBox(width: 12, height: 12, child: ResourceImage.imageWithName(eventStatusIcon),),
                                              SizedBox(width: 6,),
                                              Text(measurementStatus,
                                              style: TextStyle(
                                                  color: eventStatusColor),)]),)
                                      )],),)]),
                        SizedBox(height: 18,),
                        SizedBox(
                            height: showDate ? 52 : canAddMeasurement ? 90 : 170,
                            child: Row(
                              children: [
                                Expanded(flex: 2,
                                    child: Column(
                                      children:
                                      [
                                        Expanded(flex: 1,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(height: 16,
                                                    width: 16,
                                                    child: ResourceImage.imageWithName('ic_contact.png')),
                                                SizedBox(width: 8),
                                                Flexible(child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Expanded(child: Text(
                                                      userEmail,
                                                      style: _textStyle,
                                                      overflow: TextOverflow
                                                          .ellipsis,)),
                                                  ],))
                                              ],)),
                                        SizedBox(height: 12,),
                                        dateLineWidget(),
                                      ],
                                    )),
                              ],
                            ))
                      ],
                    ),
                  )
              )),
        );
      }

      var gesture = GestureDetector(
        child: container,
        onTap: () {
          print('did Select at $index');
          if (index > 0) {
            checkPermissionsAndMoveTo(index: index-1);
            // _moveToMeasurementAt(index-1);
          }
        },
      );

      return gesture;
    }

    var eventInfoViewCount = 1;
    var measurementsCount = measurementsList.data.length;
    var emptyStateViewCount = 0;
    if (event.status == EventStatus.scheduled) {
      measurementsCount = 0;
      emptyStateViewCount = 1;
    }
    var listView = ListView.builder(itemCount: measurementsCount + emptyStateViewCount + eventInfoViewCount,
      itemBuilder: (_, index) => itemAt(index:index, showEmptyView: emptyStateViewCount == 1),
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