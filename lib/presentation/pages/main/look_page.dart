import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCompanyPage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseRolePage.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/constants/global.dart';
import 'package:tdlook_flutter_app/presentation/widgets/loader/loader_box.dart';

class LookApp extends StatefulWidget {
  @override
  _LookAppState createState() => _LookAppState();
}

class _LookAppState extends State<LookApp> {
  bool? _isAuthorized;
  UserType? _activeUserType;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return _activeWidget();
  }

  Widget _activeWidget() {
    if (_isAuthorized == null) {
      return LoaderBox(
        isLoading: true,
        child: Container(),
      );
    }
    if (_isAuthorized == false) {
      return ChooseRolePage();
    } else if (_activeUserType == UserType.endWearer) {
      return kCompanyTypeArmorOnly ? _eventsForArmorCompany() : ChooseCompanyPage();
    } else {
      return EventsPage();
    }
  }

  Future<void> _checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access');
    final value = prefs.getString("userType");
    if (value != null) {
      _activeUserType = EnumToString.fromString(UserType.values, value);
    }
    logger.d('accessToken = $accessToken');
    setState(() {
      _isAuthorized = (accessToken != null);
    });
  }

  Widget _eventsForArmorCompany() {
    SessionParameters().selectedCompany = CompanyType.armor;
    return EventsPage();
  }
}
