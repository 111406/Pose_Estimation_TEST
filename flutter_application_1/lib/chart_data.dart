class ChartData {
  ChartData(this.sec, this.angle);

  final double sec;
  final int angle;

  Map toJson() => {
        'sec': sec,
        'angle': angle,
      };
}
