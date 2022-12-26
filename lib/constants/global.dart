RegExp kLatinAvailableCharactersRegExp = RegExp("[a-zA-Z0-9]");
RegExp kLatinAvailableCharactersWithWhitespaceRegExp = RegExp("[a-zA-Z0-9_ ]");
RegExp kNameAvailableCharactersRegExp = RegExp("[a-zA-Z0-9'-_ ,.]");

//
RegExp kDigitsOnlyRegExp = RegExp(r"\D");
RegExp kEmailAvailableCharactersRegExp = RegExp("[-a-zA-Z0-9.+_@]");
RegExp kEmailValidatorRegExp = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

const kBackstage = 'backstage';
const kRelease = 'release';
