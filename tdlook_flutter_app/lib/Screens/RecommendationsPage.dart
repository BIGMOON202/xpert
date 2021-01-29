
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/MeasurementsListWorker.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/ReccomendationsListWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

class RecommendationsPageArguments {
  MeasurementResults measurement;
  bool showRestartButton;
  RecommendationsPageArguments({Key key, this.measurement, this.showRestartButton});

}

class RecommendationsPage extends StatefulWidget {
  static const String route = '/recommendations';

  RecommendationsPageArguments arguments;
  RecommendationsPage({Key key, this.arguments}): super(key: key);

  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {

  List<RecommendationModel> recommendations;
  RecommendationsListBLOC _bloc;
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;

  @override
  void initState() {
    // TODO: implement initState
    _bloc = RecommendationsListBLOC(widget.arguments.measurement.id.toString());
    _bloc.call();
  }

  @override
  Widget build(BuildContext context) {

    Widget listBody() {
      if (recommendations != null && recommendations.length != 0) {
        print('config list recom');
        return RecommendationsListWidget(
          measurement: widget.arguments.measurement,
          recommendations: recommendations,
          showRestartButton: widget.arguments.showRestartButton,);
      } else {
        print('config list recom async');
        return StreamBuilder<Response<List<RecommendationModel>>>(
          stream: _bloc.chuckListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print('recom list status: ${snapshot.data.status}');
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return RecommendationsListWidget(
                      measurement: widget.arguments.measurement,
                      recommendations: snapshot.data.data,
                      showRestartButton: widget.arguments.showRestartButton);
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
          title: Text('Profile details'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: _backgroundColor,
        body: listBody()
    );

    return scaffold;
  }
}

class RecommendationsListWidget extends StatelessWidget {
  final MeasurementResults measurement;
  final bool showRestartButton;
  final   List<RecommendationModel> recommendations;


  const RecommendationsListWidget({Key key, this.measurement, this.recommendations, this.showRestartButton}) : super(key: key);
  static Color _backgroundColor = SharedParameters().mainBackgroundColor;


  @override
  Widget build(BuildContext context) {

    // _showCupertinoDialog(String text) {
    //   showDialog(
    //       context: context,
    //       builder: (_) => new CupertinoAlertDialog(
    //         // title: new Text("Cupertino Dialog"),
    //         content: new Text(text),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text('OK'),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           )
    //         ],
    //       ));
    // }


    // void _moveToMeasurementAt(int index) {
    //
    //   var measurement = measurementsList.data[index];
    //   print('open measurement\n '
    //       'id:${measurement.id}\n'
    //       'uuid:${measurement.uuid}');
    //
    //   if (Application.isInDebugMode) {
    //     Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
    //     // LoginPage(userType: _selectedUserType)
    //     ChooseGenderPage(measurement:  measurement)
    //     ));
    //     return;
    //   }
    //
    //   if (measurement.isComplete == false && event.status == EventStatus.in_progress) {
    //     Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
    //     // LoginPage(userType: _selectedUserType)
    //     ChooseGenderPage(measurement:  measurement)
    //     ));
    //   } else if (measurement.isComplete == true) {
    //     _showCupertinoDialog('Measurement completed, move to results');
    //   } else if (event.status != EventStatus.in_progress) {
    //     _showCupertinoDialog('Event is not in progress now');
    //
    //   }
    //
    //
    // }





    Widget itemAt(int index) {

      Container container;

      var _highlightColor = HexColor.fromHex('1E7AE4');

      if (index == 0) {

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
                      color: _highlightColor
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
                                          color: Colors.white
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                            children:[
                                              SizedBox(width: 12, height: 12, child: ResourceImage.imageWithName(eventStatusIcon),),
                                              SizedBox(width: 6,),
                                              Text(measurementStatus,
                                                style: TextStyle(
                                                    color: eventStatusColor, fontWeight: FontWeight.bold),)]),)
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
      } else {

        // return Container(color: Colors.orange);

        var recomendation = recommendations[index - 1];
        var title = recomendation.product.name;
        var code = recomendation.product.style.toString();
        var size = recomendation.size;
        var optionColor = HexColor.fromHex('898A9D');
        var _textStyle = TextStyle(color: Colors.white);

        List<Widget> _sizeWidgets(RecommendationModel recommendation) {
          var widgets =  List<Widget>();

          var column = Column(
              children: [
                Text('Size', style: TextStyle(color: optionColor, fontSize: 12, fontWeight: FontWeight.w400)),
                SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(4)),
                      color: Colors.white.withAlpha(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(size, style: TextStyle(color: _highlightColor, fontWeight: FontWeight.bold)))
              )]);
          widgets.add(column);
          return widgets;
        }

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Expanded(child:Text(title, style: TextStyle(color: Colors.white), maxLines: 5) ),
                              Text(code,
                                style: TextStyle(
                                    color: optionColor),)]),
                        SizedBox(height: 18,),
                        Row(
                          children: _sizeWidgets(recomendation),
                        )

                      ],
                    ),
                  )
              )),
        );
      }

      var gesture = GestureDetector(
        child: container,
        onTap: () {
          // print('did Select at $index');
          // if (index > 0) {
          //   _moveToMeasurementAt(index-1);
          // }
        },
      );

      return gesture;
    }

    var list = ListView.builder(itemCount: recommendations.length + 1,
      itemBuilder: (_, index) => itemAt(index),
    );

    _moveToHomePage() {
      print('move to home page');
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

    _restartAnalize() {
      print('_restartAnalize');
    }


    var container = Column(
      children: [Flexible(
        flex: 8,
          child: list),
      Visibility(visible: showRestartButton, child:Flexible(flex:2,
        child: Container(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [Flexible(child: MaterialButton(
                  onPressed: () {
                    print('next button pressed');
                    _moveToHomePage();
                  },
                  textColor: Colors.white,
                  child: Text('Complete Profile'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  color: HexColor.fromHex('1E7AE4'),
                  height: 50,
                  padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // padding: EdgeInsets.all(4),
                )),
                  Flexible(child: MaterialButton(
                    onPressed: () {
                      print('next button pressed');
                      _restartAnalize();
                    },
                    textColor: Colors.white,
                    child: Text('rescan'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    color: Colors.white.withAlpha(6),
                    height: 50,
                    padding: EdgeInsets.only(left: 12, right: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    // padding: EdgeInsets.all(4),
                  ))],
              ),
            ),
          )
    )))],

    );


    return container;
  }
}