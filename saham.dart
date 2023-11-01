class Saham {
  int? tickerId;
  String ticker;
  int? open;
  int? high;
  int? last;
  String? change;

  Saham({
    this.tickerId,
    required this.ticker,
    this.open,
    this.high,
    this.last,
    this.change,
  });

  Map<String, dynamic> toMap() {
    return {
      'Tickerid': tickerId,
      'Ticker': ticker,
      'Open': open,
      'High': high,
      'Last': last,
      'Change': change,
    };
  }

  factory Saham.fromMap(Map<String, dynamic> map) {
    return Saham(
      tickerId: map['Tickerid'],
      ticker: map['Ticker'],
      open: map['Open'],
      high: map['High'],
      last: map['Last'],
      change: map['Change'],
    );
  }
}
