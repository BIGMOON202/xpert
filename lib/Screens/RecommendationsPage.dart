import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/RefreshStatus+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/MeasurementsWorker.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/ReccomendationsListWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/BadgePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseGenderPage.dart';
import 'package:tdlook_flutter_app/Screens/EventDetailPage.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/Loading.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/constants/global.dart';

class RecommendationsPageArguments {
  MeasurementResults? measurement;
  bool? showRestartButton;
  RecommendationsPageArguments({
    Key? key,
    this.measurement,
    this.showRestartButton,
  });
}

class RecommendationsPage extends StatefulWidget {
  static const String route = '/recommendations';

  RecommendationsPageArguments? arguments;
  RecommendationsPage({Key? key, this.arguments}) : super(key: key);

  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  SharedPreferences? prefs;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  Future<void> initShared() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _refreshList() async {
    setState(() {
      recommendations?.clear();
      recommendations = null;
    });
    _updateMeasurementBloc?.call();
    _bloc?.call();
  }

  List<RecommendationModel>? recommendations;
  List<RecommendationModel>? _filteredRecommendations;

  RecommendationsListBLOC? _bloc;
  MeasurementsWorkerBloc? _updateMeasurementBloc;
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  TextEditingController _controller = TextEditingController();

  String? _loadingError;
  String filterText = '';

  _clearText() {
    filterText = '';
    _controller.clear();
    filter(withText: filterText);
  }

  onSearchTextChanged(String newText) {
    filterText = newText;
    filter(withText: filterText);
  }

  filter({String? withText}) async {
    if (recommendations == null) return;

    List<RecommendationModel> filtered;
    if (withText?.isEmpty == true) {
      filtered = recommendations!;
    } else {
      filtered = await recommendations!.where((element) {
        final isContainsName = element.product?.name?.containsIgnoreCase(withText!) ?? false;
        final isContainsStyle = element.product?.style?.containsIgnoreCase(withText!) ?? false;
        return isContainsName || isContainsStyle;
      }).toList();
    }

    setState(() {
      _filteredRecommendations = filtered;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initShared();
    _updateMeasurementBloc = MeasurementsWorkerBloc(widget.arguments?.measurement?.id.toString());
    _updateMeasurementBloc?.chuckListStream.listen((event) {
      if (event.status == null) return;
      switch (event.status!) {
        case Status.LOADING:
          break;

        case Status.COMPLETED:
          setState(() {
            var askForWaistLevel = widget.arguments?.measurement?.askForWaistLevel;
            var askForOverlap = widget.arguments?.measurement?.askForWaistLevel;

            widget.arguments?.measurement = event.data;
            widget.arguments?.measurement?.askForWaistLevel = askForWaistLevel;
            widget.arguments?.measurement?.askForOverlap = askForOverlap;
          });
          break;
        case Status.ERROR:
          break;
      }
    });

    _bloc = RecommendationsListBLOC(widget.arguments?.measurement?.id.toString());
    _bloc?.chuckListStream.listen((event) {
      if (event.status == null) return;
      switch (event.status!) {
        case Status.LOADING:
          break;
        case Status.COMPLETED:
          setState(() {
            recommendations = event.data;
            _loadingError = null;
            if (filterText.isEmpty == true) {
              _filteredRecommendations = recommendations;
            } else {
              filter(withText: filterText);
            }
          });
          break;
        case Status.ERROR:
          setState(() {
            _loadingError = event.message;
          });
          break;
      }
    });

    _callRequests();
  }

  _callRequests() {
    setState(() {
      _loadingError = null;
    });

    _updateMeasurementBloc?.call();
    _bloc?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget listBody() {
      if (recommendations == null && _loadingError == null) {
        return Loading();
      } else if (_loadingError != null) {
        return Error(
          errorMessage: _loadingError,
          onRetryPressed: () => _callRequests(),
        );
      } else {
        return RecommendationsListWidget(
            measurement: widget.arguments?.measurement,
            recommendations: _filteredRecommendations,
            showRestartButton: widget.arguments?.showRestartButton,
            onRefreshList: _refreshList,
            refreshController: _refreshController);
      }
    }

    var topTextValue = '';
    final value = prefs?.getString("userType");
    if (prefs != null && value != null) {
      UserType type = EnumToString.fromString(UserType.values, value)!;
      topTextValue = type == UserType.endWearer
          ? "Your scans have been destroyed"
          : "Scans have been destroyed";
    }

    Widget searchBar() {
      if (recommendations == null || recommendations?.isEmpty == true) {
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
                style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 13),
                controller: _controller,
                decoration: new InputDecoration(
                    filled: true,
                    suffixIcon: Visibility(
                        visible: _controller.value.text.isNotEmpty,
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
                    hintText: 'Search by Product name or Style ID',
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

    var topText = Visibility(
        visible: widget.arguments?.showRestartButton ?? false,
        child: Column(
          children: [
            Text(topTextValue,
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400)),
            SizedBox(
              height: 32,
            )
          ],
        ));
    var scaffold = Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.arguments?.showRestartButton == true ? 'Thank you' : 'Profile details',
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: _backgroundColor,
        body: Column(
          children: [
            topText,
            Visibility(
              child: searchBar(),
              visible: (recommendations?.length ?? 0) > 1,
            ),
            //searchBar(),
            Flexible(child: listBody()),
          ],
        ));

    return scaffold;
  }
}

class RecommendationsListWidget extends StatelessWidget {
  MeasurementResults? measurement;
  bool? showRestartButton;
  List<RecommendationModel>? recommendations;
  AsyncCallback? onRefreshList;
  RefreshController? refreshController;

  SharedPreferences? prefs;

  Future<void> initShared() async {
    prefs = await SharedPreferences.getInstance();
  }

  RecommendationsListWidget({
    MeasurementResults? measurement,
    List<RecommendationModel>? recommendations,
    bool? showRestartButton,
    AsyncCallback? onRefreshList,
    required RefreshController refreshController,
  }) {
    this.measurement = measurement;
    this.recommendations = recommendations;
    this.showRestartButton = showRestartButton;
    this.refreshController = refreshController;
    this.onRefreshList = onRefreshList;
    initShared();
  }

  // const RecommendationsListWidget({Key key, this.measurement, this.recommendations, this.showRestartButton}) : super(key: key);
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  static var _optionColor = HexColor.fromHex('898A9D');
  static var _highlightColor = HexColor.fromHex('1E7AE4');

  void _pullRefresh() async {
    refreshController?.loadComplete();
    onRefreshList?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget _recommendationRow({
      String? title,
      String? size,
      String? secondSize,
    }) {
      final _textSize = size ?? 'Size is outside of size range';
      final _secondSizeText = secondSize ?? 'Null';
      // Color _textColor = size != null ? _highlightColor : Colors.red;
      // Widget _icon;
      // if (size != null) {
      //   _icon = Container();
      // } else {
      //   _icon = Padding(
      //       padding: EdgeInsets.only(
      //         right: 6,
      //       ),
      //       child: SizedBox(
      //         width: 12,
      //         height: 12,
      //         child: ResourceImage.imageWithName('warning_ic.png'),
      //       ));
      // }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title ?? '',
              style: TextStyle(
                color: _optionColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              )),
          // SizedBox(height: 6),
          // Container(
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.all(Radius.circular(4)),
          //         color: Colors.white.withAlpha(10)),
          //     child: Padding(
          //         padding: EdgeInsets.all(5),
          //         child: Row(
          //           children: [
          //             _icon,
          //             Text(_textSize,
          //                 style: TextStyle(color: _textColor, fontWeight: FontWeight.bold))
          //           ],
          //         ))),
          _WarningSizeWidget(text: _textSize, isWarning: size == null),
        ],
      );
    }

    Widget itemAt(int index) {
      Container container;

      if (index == 0) {
        var userName = measurement?.endWearer?.name ?? '-';
        var userEmail = measurement?.endWearer?.email ?? '-';

        var completeTimeSplit = measurement?.completedAtTime;
        var measurementDate;
        if (completeTimeSplit != null) {
          final completedTime = completeTimeSplit.toLocal();
          var completeDate = DateFormat(kDefaultDateFormat).format(completedTime);
          var completeTime = DateFormat(kDefaultHoursFormat).format(completedTime);
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

        container = Container(
          color: _backgroundColor,
          child: Padding(
            padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)), color: _highlightColor),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(userName, style: TextStyle(color: Colors.white)),
                      ),
                      Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                    color: Colors.white),
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
                                      style: TextStyle(
                                          color: eventStatusColor, fontWeight: FontWeight.bold),
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
                      height: 52,
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
                                        child: ResourceImage.imageWithName('ic_contact.png'),
                                      ),
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
                                  ),
                                ),
                                SizedBox(height: 12),
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
                                          child: ResourceImage.imageWithName('ic_checkmark.png'),
                                        ),
                                        SizedBox(width: 8),
                                        Text(measurementDate, style: _textStyle)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // return Container(color: Colors.orange);

        var recomendation = recommendations![index - 1];
        logger.d('type: ${recomendation.product?.sizechartType}');
        var title = recomendation.product?.name;
        var code = recomendation.product?.style.toString();
        var size = recomendation.size;
        final secondSize = recomendation.sizeSecond;
        var _textStyle = TextStyle(color: Colors.white);

        var inseamValue = measurement?.person?.frontParams?.inseam?.inImperial.toStringAsFixed(0);
        var sleeveValue = measurement?.person?.frontParams?.sleeve?.inImperial.toStringAsFixed(0);
        var riseValue = measurement?.person?.frontParams?.rise?.inImperial.toStringAsFixed(0);
        var waistValue = measurement?.person?.frontParams?.waist?.inImperial.toStringAsFixed(0);

        List<Widget> _sizeWidgets(RecommendationModel recommendation) {
          var widgets = <Widget>[];

          if (SessionParameters().selectedCompany == CompanyType.uniforms &&
              measurement?.person != null &&
              measurement?.person?.frontParams != null) {
            logger.d('config for: ${recommendation.product} - ${measurement?.gender}');
            if (recommendation.product?.sizechartType == 'pants' &&
                recommendation.product?.gender == 'male') {
              widgets.add(
                _recommendationRow(
                  title: 'Waist',
                  size: recommendation.size,
                ),
              );
              if (recommendation.sizeSecond != null) {
                widgets.add(
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _recommendationRow(
                      title: 'Rise',
                      size: recommendation.sizeSecond,
                    ),
                  ),
                );
              }
              widgets.add(
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: _recommendationRow(title: 'Inseam', size: inseamValue),
                ),
              );
            } else if (recommendation.product?.sizechartType == 'pants' &&
                recommendation.product?.gender == 'female') {
              widgets.add(_recommendationRow(title: 'Waist', size: recommendation.size));
              widgets.add(Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: _recommendationRow(title: 'Inseam', size: inseamValue)));
            } else if (recommendation.product?.sizechartType == 'long_sleeve_shirt') {
              widgets.add(_recommendationRow(title: 'Recommended Size', size: recommendation.size));
              if (recommendation.sizeSecond != null) {
                widgets.add(
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _recommendationRow(title: 'Sleeve', size: recommendation.sizeSecond),
                  ),
                );
              }
            } else if (recommendation.product?.sizechartType == 'short_sleeve_shirt') {
              widgets.add(_recommendationRow(title: 'Recommended Size', size: recommendation.size));
            } else if (recommendation.product?.sizechartType == 'dress_coat' ||
                recommendation.product?.sizechartType == 'outerwear') {
              widgets.add(_recommendationRow(title: 'Recommended Size', size: recommendation.size));
              if (recommendation.sizeSecond != null) {
                widgets.add(Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _recommendationRow(title: 'Length', size: recommendation.sizeSecond)));
              }
            } else {
              widgets.add(_recommendationRow(title: 'Recommended Size', size: recommendation.size));
            }

            return widgets;
          } else {
            widgets.add(_recommendationRow(
              title: 'Recommended Size',
              size: recommendation.size,
              secondSize: recommendation.sizeSecond,
            ));
          }
          return widgets;
        }

        container = Container(
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
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Text(
                          title ?? '',
                          style: TextStyle(color: Colors.white),
                          maxLines: 5,
                        ),
                      ),
                      Spacer(),
                      Text(
                        code ?? '',
                        style: TextStyle(color: _optionColor),
                      ),
                    ]),
                    SizedBox(
                      height: 18,
                    ),
                    // ListView(
                    //   // shrinkWrap: true,
                    //   physics: NeverScrollableScrollPhysics(),
                    //   scrollDirection: Axis.horizontal,
                    //   children: _sizeWidgets(recomendation),
                    // ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _sizeWidgets(recomendation))),
                    // SingleChilqdScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //     child: Flexible(child: Row(
                    //   children: _sizeWidgets(recomendation),
                    // )))
                    if (secondSize != null)
                      Row(
                        children: [
                          _WarningSizeWidget(
                            text: secondSize,
                            isWarning: true,
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      var gesture = GestureDetector(
        child: container,
        onTap: () {
          //logger.d('did Select at $index');
          // if (index > 0) {
          //   _moveToMeasurementAt(index-1);
          // }
        },
      );

      return gesture;
    }

    var listView = ListView.builder(
        itemCount: (recommendations?.length ?? 0) + 1, itemBuilder: (_, index) => itemAt(index));

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
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            } else {
              return Container();
            }
          },
        ),
        controller: refreshController!,
        onLoading: _pullRefresh,
        child: listView,
        onRefresh: onRefreshList);

    _moveToHomePage() {
      logger.i('move to home page');
      final value = prefs?.getString("userType");
      if (value == null) return;
      var type = EnumToString.fromString(UserType.values, value);
      var user = prefs?.getString('temp_user');
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      if (type == UserType.endWearer) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => EventsPage(
                      provider: SessionParameters().selectedCompany?.apiKey(),
                    )));
      }
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) =>
                  // LoginPage(userType: _selectedUserType)
                  EventDetailPage(event: measurement?.event, userType: type, currentUserId: user)));
    }

    _restartAnalize() {
      void _restartAction() {
        logger.i('_restartAnalize');
        if (SessionParameters().selectedUser == UserType.salesRep ||
            SessionParameters().selectedCompany == CompanyType.uniforms) {
          Navigator.pushNamedAndRemoveUntil(context, ChooseGenderPage.route, (route) => false,
              arguments: ChooseGenderPageArguments(measurement));
        } else {
          Navigator.pushNamedAndRemoveUntil(context, BadgePage.route, (route) => false,
              arguments: BadgePageArguments(measurement, SessionParameters().selectedUser));
        }
      }

      void closePopup() {
        Navigator.of(context, rootNavigator: true).pop("Discard");
      }

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                content: Text(
                    'Are you sure that you want to retake the flow? All your progress will be lost'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("Yes"),
                    onPressed: () => _restartAction(),
                  ),
                  CupertinoDialogAction(
                      isDefaultAction: true, child: Text('No'), onPressed: () => closePopup()),
                ],
              ));
    }

    var container = Column(
      children: [
        Flexible(flex: 10, child: list),
        Visibility(
          visible: showRestartButton ?? false,
          child: Flexible(
            flex: 3,
            child: Container(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Flexible(
                          child: Container(
                              width: double.infinity,
                              child: MaterialButton(
                                splashColor: Colors.transparent,
                                elevation: 0,
                                onPressed: () {
                                  logger.i('next button pressed');
                                  _moveToHomePage();
                                },
                                textColor: Colors.white,
                                child: Text(
                                    'Complete${SessionParameters().selectedUser == UserType.endWearer ? ' my' : ''} Profile'
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white)),
                                color: SessionParameters().selectionColor,
                                height: 50,
                                padding: EdgeInsets.only(left: 12, right: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                // padding: EdgeInsets.all(4),
                              ))),
                      SizedBox(
                        height: 8,
                      ),
                      Flexible(
                        child: Container(
                          width: double.infinity,
                          child: MaterialButton(
                            splashColor: Colors.transparent,
                            elevation: 0,
                            onPressed: () {
                              _restartAnalize();
                            },
                            textColor: Colors.white,
                            child: Text('rescan'.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white)),
                            color: Colors.white.withOpacity(0.25),
                            height: 50,
                            padding: EdgeInsets.only(left: 12, right: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            // padding: EdgeInsets.all(4),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return container;
  }
}

class _WarningSizeWidget extends StatelessWidget {
  final String text;
  final bool isWarning;
  const _WarningSizeWidget({
    required this.text,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.white.withAlpha(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              isWarning
                  ? Padding(
                      padding: EdgeInsets.only(
                        right: 6,
                      ),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: ResourceImage.imageWithName('warning_ic.png'),
                      ))
                  : SizedBox.shrink(),
              Text(
                text,
                style: TextStyle(
                  color: isWarning ? Colors.red : HexColor.fromHex('1E7AE4'),
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
