class Utils {
  static double mapRange(double value, double inputStart, double inputEnd, double outputStart, double outputEnd) {
    return ((value - inputStart) / (inputEnd - inputStart)) * (outputEnd - outputStart) + outputStart;
  }
}