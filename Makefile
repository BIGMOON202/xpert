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

app:
	fvm flutter build appbundle -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

apk:
	fvm flutter build apk -t lib/main.dart --release && \
	open build/app/outputs/flutter-apk/

ipa:
	fvm flutter build ipa -t lib/main.dart --release && \
	open build/ios/archive/Runner.xcarchive