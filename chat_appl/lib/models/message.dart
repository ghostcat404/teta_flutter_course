class Message {
  final String userId;
  final String text;
  final int timestamp;

  Message({required this.userId, required this.text, required this.timestamp});

  Message.fromJson(Map<dynamic, dynamic> json)
    : userId = json['userId'],
      text = json['text'],
      timestamp = json['timestamp'];
  
  Map<dynamic, dynamic> toJson() => {'userId': userId, 'text': text, 'timestamp': timestamp};

  Message.fromMap(Map<dynamic, dynamic> data)
    : userId = data['userId'],
      text = data['text'],
      timestamp = data['timestamp'];
}