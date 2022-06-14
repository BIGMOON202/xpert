setup:
	fvm install --verbose

clean:
	fvm flutter clean

get:
	fvm flutter pub get

get_packages:
	fvm flutter packages pub get

gen:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

intl:
	fvm flutter pub run intl_utils:generate --ignore-deprecation

run:
	fvm flutter run lib/main.dart -d emulator-5554

# Make Android app file 

app:
	fvm flutter build appbundle --flavor xpertfit --dart-define ENV=release -t lib/main.dart --release && \
	open build/app/outputs/bundle/xpertfitRelease/

app_backstage:
	fvm flutter build appbundle --flavor backstage --dart-define ENV=backstage -t lib/main.dart --release && \
	open build/app/outputs/bundle/backstageRelease/

# Make apk file

apk:
	fvm flutter build apk --flavor xpertfit --dart-define ENV=release -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

apk_test:
	fvm flutter build apk --flavor xpertfit --dart-define ENV=test -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

apk_stage:
	fvm flutter build apk --flavor xpertfit --dart-define ENV=stage -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

apk_hotfix:
	fvm flutter build apk --flavor xpertfit --dart-define ENV=hotfix -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

apk_backstage:
	fvm flutter build apk --flavor backstage --dart-define ENV=backstage -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

# -d 04BE249E-F963-454F-BF93-7ACB0DA0F51B
apk_run_backstage:
	fvm flutter run apk --flavor backstage --dart-define ENV=backstage -t lib/main.dart


# Make iOS ipa file 

ipa:
	fvm flutter build ipa --flavor xpertfit -t lib/main.dart --release && \
	open build/ios/archive/Runner.xcarchive

ipa_run:
	fvm flutter run ipa --flavor xpertfit --dart-define ENV=release -t lib/main.dart -d 04BE249E-F963-454F-BF93-7ACB0DA0F51B

ipa_backstage:
	fvm flutter build ipa --flavor backstage --dart-define ENV=backstage -t lib/main.dart --release && \
	open build/ios/archive/Runner.xcarchive