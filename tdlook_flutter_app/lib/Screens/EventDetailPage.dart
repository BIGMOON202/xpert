
import 'dart:developer';

import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
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
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  @override
  void initState() {
    // TODO: implement initState
    _bloc = MeasurementsListWorkerBloc(widget.event.id.toString());
    _bloc.call();

    SharedParameters().selectedUser = widget.userType;

    if (widget.measurementsList != null && widget.measurementsList.data.length > 0) {
      // widget.measurementsList.data =  widget.measurementsList.data.where((i) => i.endWearer.id == widget.currentUserId).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget listBody() {
      if (widget.measurementsList != null && widget.measurementsList.data.length != 0) {
        print('config list body');
        return MeasuremetsListWidget(event: widget.event, measurementsList: widget.measurementsList, userType: widget.userType,);
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
                  return MeasuremetsListWidget(event: widget.event, measurementsList: snapshot.data.data, userType: widget.userType,);
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
  final Event event;
  final MeasurementsList measurementsList;
  final UserType userType;

  const MeasuremetsListWidget({Key key, this.event, this.measurementsList, this.userType}) : super(key: key);
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;


  @override
  Widget build(BuildContext context) {

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


    void _moveToMeasurementAt(int index) {

      var measurement = measurementsList.data[index];
      print('open measurement\n '
          'id:${measurement.id}\n'
          'uuid:${measurement.uuid}');

      // if (Application.isInDebugMode) {
      //   Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      //   // LoginPage(userType: _selectedUserType)
      //   ChooseGenderPage(measurement:  measurement)
      //   ));
      //   return;
      // }

      if (measurement.isComplete == false && event.status == EventStatus.in_progress) {
        // if sales rep - open gender
        if (SharedParameters().selectedCompany == CompanyType.armor) {
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
        _showCupertinoDialog('Event is not in progress now');

      }
      }





    Widget itemAt(int index) {

      Container container;

      if (index == 0) {

      var eventName = event?.name ?? 'Event Name';
      var companyName = event.agency?.name ?? 'Agency name';
      var companyType = event.agency?.type ?? 'Agency type';

      final startTimeSplit = event.createdAt.split('T');

      var eventStartDate = startTimeSplit.first ?? '-';
      var eventStartTime = startTimeSplit.last.substring(0,8) ?? '-';

      final endTimeSplit = event.endDate.split('T');

      var eventEndDate = endTimeSplit.first ?? '-';
      var eventEndTime = endTimeSplit.last.substring(0,8) ?? '-';
      var eventStatus = event.status.displayName() ?? "In progress";
      var eventStatusColor = event.status.displayColor() ?? Colors.white;


      var _textColor = Colors.white;
      var _descriptionColor = HexColor.fromHex('BEC1D4');
      var _textStyle = TextStyle(color: _textColor);
      var _descriptionStyle = TextStyle(color: _descriptionColor);


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
                              Expanded(flex: 5,
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
                                                  color: eventStatusColor),)),)
                                      ],),)),
                            ],
                          ))
                    ],
                  ),
                )
            )),
      );

      } else {
        var ind = index - 1;
        var measurement = measurementsList.data[ind];


        var userName = measurement.endWearer.name ?? '-';
        var userEmail = measurement.endWearer.email ?? '-';

        var completeTimeSplit = measurement.completedAt?.split('T');
        var measurementDate;
        if (completeTimeSplit != null) {
          var completeDate = completeTimeSplit?.first ?? '-';
          var completeTime = completeTimeSplit?.last?.substring(0,8) ?? '-';
          measurementDate = '$completeDate,$completeTime';
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


        container = Container(
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
                        Row(
                            children: [Expanded(child:Text(userName, style: TextStyle(color: Colors.white)),),
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
                            height: 52,
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
                                        Expanded(flex: 1,
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
                                                ],),)),

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
            _moveToMeasurementAt(index-1);
          }
        },
      );

      return gesture;
    }

    var list = ListView.builder(itemCount: measurementsList.data.length + 1,
      itemBuilder: (_, index) => itemAt(index),
    );
    return list;
  }
}