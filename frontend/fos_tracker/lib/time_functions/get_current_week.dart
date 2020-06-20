DateTime getCurrentWeekStartDate(){
  DateTime today = DateTime.now();
  int day = today.weekday;
  DateTime startDay = today.subtract(new Duration(days: (day-1)));
  return startDay;
}

DateTime getCurrentWeekEndDate(){
  DateTime startDay = getCurrentWeekStartDate();
  DateTime endDay = startDay.add(new Duration(days: 6));
  return endDay;
}
