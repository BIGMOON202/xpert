import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/application/assets/assets.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';
import 'package:tdlook_flutter_app/constants/global.dart';
import 'package:tdlook_flutter_app/constants/keys.dart';
import 'package:tdlook_flutter_app/data/enums/invite_type.dart';
import 'package:tdlook_flutter_app/data/models/errors/fields_errors.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';
import 'package:tdlook_flutter_app/presentation/cubits/end_wearer_cubit.dart';
import 'package:tdlook_flutter_app/presentation/states/end_wearer_state.dart';
import 'package:tdlook_flutter_app/presentation/widgets/buttons/action_text_button.dart';
import 'package:tdlook_flutter_app/presentation/widgets/buttons/body_text_button.dart';
import 'package:tdlook_flutter_app/presentation/widgets/loader/loader_box.dart';
import 'package:tdlook_flutter_app/presentation/widgets/scaffold/regular_scaffold.dart';

part 'widgets/error_box.dart';
part 'widgets/new_ew_invite_box.dart';
part 'widgets/success_box.dart';
part 'widgets/text_field_box.dart';

class NewEWPage extends StatefulWidget {
  final UserType userType;
  final Event event;
  final VoidCallback onUpdate;

  const NewEWPage({
    Key? key,
    required this.event,
    required this.userType,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<NewEWPage> createState() => _NewEWPageState();
}

class _NewEWPageState extends State<NewEWPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  late EWCubit _cubit;

  int get eventId => widget.event.id ?? 0;

  @override
  void initState() {
    super.initState();
    _cubit = EWCubit(userType: widget.userType);
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    PhoneInputFormatter.replacePhoneMask(countryCode: 'US', newMask: '+0 (000) 000-0000');
    PhoneInputFormatter.replacePhoneMask(countryCode: 'UA', newMask: '+000 (00) 000-0000');
    PhoneInputFormatter.replacePhoneMask(countryCode: 'RU', newMask: '+0 (000) 000-0000');
    PhoneInputFormatter.replacePhoneMask(countryCode: 'GB', newMask: '+00 (000) 000-0000');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EWCubit>(
      create: (_) => _cubit,
      child: BlocConsumer<EWCubit, EWState>(
        listener: (_, __) {},
        builder: (_, state) {
          return RegularScaffold(
              title: S.current.page_title_new_ew,
              isVisibleBackButton: !state.addToEventState.isSuccess,
              body: LoaderBox(
                isLoading: state.isLoading,
                child: state.addToEventState.isSuccess
                    ? _buildSuccessContent(state)
                    : _buildContent(state),
              ));
        },
        buildWhen: ((previous, current) => current != previous),
      ),
    );
  }

  Widget _buildContent(EWState state) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: _buildForm(state)),
            ActionTextButton(
              title: S.current.common_add,
              isEnabled: state.addToEventState.isValidData && !state.isLoading,
              isBordered: true,
              onPressed: () {
                _add();
              },
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(EWState state) {
    final availableCharactersFormatter = FilteringTextInputFormatter.allow(
        kNameAvailableCharactersRegExp); //kLatinAvailableCharactersWithWhitespaceRegExp
    final availableEmailCharactersFormatter =
        FilteringTextInputFormatter.allow(kEmailAvailableCharactersRegExp);
    final hasError = state.addToEventState.availableErrorMessage?.isNotEmpty == true;
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                _TextFieldBox(
                  key: Keys.newEwNameFieldKey,
                  isEnabled: !state.isLoading,
                  keyboardType: TextInputType.text,
                  title: S.current.text_ew_name,
                  controller: _nameCtrl,
                  errorMessage: state.addToEventState.errors?.nameErrorMessage,
                  inputFormatters: [
                    //availableCharactersFormatter,
                  ],
                  onChanged: (value) {
                    _cubit.setName(value);
                  },
                ),
                const SizedBox(height: 20),
                _TextFieldBox(
                  key: Keys.newEwEmailFieldKey,
                  isEnabled: !state.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  title: S.current.text_customer_email,
                  controller: _emailCtrl,
                  errorMessage: state.addToEventState.errors?.emailErrorMessage,
                  inputFormatters: [
                    availableEmailCharactersFormatter,
                  ],
                  onChanged: (value) {
                    _cubit.setEmail(value);
                  },
                ),
                const SizedBox(height: 20),
                _TextFieldBox(
                  key: Keys.newEwPhoneFieldKey,
                  isEnabled: !state.isLoading,
                  keyboardType: TextInputType.phone,
                  title: S.current.text_phone_number,
                  controller: _phoneCtrl,
                  errorMessage: state.addToEventState.errors?.phoneErrorMessage,
                  inputFormatters: [
                    PhoneInputFormatter(),
                  ],
                  onChanged: (value) {
                    _cubit.setPhone(value);
                  },
                ),
                const SizedBox(height: 20),
                InviteBox(
                  enabledTypes: state.addToEventState.enabledInviteTypes,
                  onSelectedTypes: (types) {
                    _cubit.setInviteTypes(types);
                  },
                  selectedTypes: state.addToEventState.inviteTypes,
                ),
                if (hasError)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: ErrorBox(
                      error: state.addToEventState.availableErrorMessage,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessContent(EWState state) {
    FocusScope.of(context).unfocus();
    return _SuccessBox(
      inviteType: state.addToEventState.inviteTypes.isEmpty
          ? null
          : state.addToEventState.inviteTypes.first,
      onFinishPressed: () {
        if (state.addToEventState.isSuccess) {
          widget.onUpdate();
        }
        Navigator.pop(context);
      },
    );
  }

  void _add() {
    // widget.onUpdate();
    // Navigator.pop(context);
    FocusScope.of(context).unfocus();
    _cubit.addToEvent(
      eventId,
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
    );
  }
}
