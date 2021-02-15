
import 'dart:math';
extension Round on double {
  double roundToPrecision(int n) {
    int fac = pow(10, n);
    return (this * fac).round() / fac;
  }
}