import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/EventListWorker.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/Screens/EventDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/main.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:enum_to_string/enum_to_string.dart';

class EventsPage extends StatefulWidget {

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  EventListWorkerBloc _bloc;
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  @override
  void initState() {
    // TODO: implement initState

    _bloc = EventListWorkerBloc();

    Future<Void> fetchUserType() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      UserType type = EnumToString.fromString(UserType.values, prefs.getString("userType"));

      _bloc.set(type);
      _bloc.call();
    }

    fetchUserType();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget _createHeader() {
      return DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Stack(children: <Widget>[
            Positioned(
                bottom: 12.0,
                left: 16.0,
                child: Text("",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500))),
          ]));
    }

    Widget _createDrawerItem(
        {IconData icon, String text, GestureTapCallback onTap}) {
      return ListTile(
        title: Row(
          children: <Widget>[
            Icon(icon, color: Colors.white,),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(text, style: TextStyle(color: Colors.white),),
            )
          ],
        ),
        onTap: onTap,
      );
    }


    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: StreamBuilder<Response<EventList>>(
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
                return EventsListWidget(eventsList: snapshot.data.data);
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
          child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(),
            // _createDrawerItem(icon: Icons.contacts,text: 'Contacts',),
            // _createDrawerItem(icon: Icons.event, text: 'Events',),
            // _createDrawerItem(icon: Icons.note, text: 'Notes',),
            Divider(color: Colors.white,),
            // _createDrawerItem(icon: Icons.collections_bookmark, text:'Steps'),
            // _createDrawerItem(icon: Icons.face, text: 'Authors'),
            // _createDrawerItem(icon: Icons.account_box, text: 'Flutter Documentation'),
            // _createDrawerItem(icon: Icons.stars, text: 'Useful Links'),
            // Divider(),
            _createDrawerItem(icon: Icons.logout, text: 'Logout', onTap: () {
              print('logout');
              Future<void> writeToken() async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('refresh');
                prefs.remove('access');

                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) =>
                // LoginPage(userType: _selectedUserType)
                LookApp()
                ));

              }
              writeToken();
            }),

          ],
        ),
        )),
      );

    return scaffold;
  }
}

class EventsListWidget extends StatelessWidget {
  final EventList eventsList;

  const EventsListWidget({Key key, this.eventsList}) : super(key: key);
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  @override
  Widget build(BuildContext context) {

    void _moveToEventAt(int index) {
      var event = eventsList.data[index];

      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      // LoginPage(userType: _selectedUserType)
      EventDetailPage(event: event)
      ));
    }


    Widget itemAt(int index) {

      var event = eventsList.data[index];
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
                                                  color: eventStatusColor),)),)
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

    var list = ListView.builder(itemCount: eventsList.data.length,
      itemBuilder: (_, index) => itemAt(index),
    );
    return list;
  }
}