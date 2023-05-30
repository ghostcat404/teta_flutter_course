class Message {
  final String userId;
  final String text;
  final String timestamp;

  Message({required this.userId, required this.text, required this.timestamp});

  Message.fromJson(Map<String, dynamic> json)
    : userId = json['userId'],
      text = json['text'],
      timestamp = json['timestamp'];
  
  Map<String, dynamic> toJson() => {'userId': userId, 'text': text, 'timestamp': timestamp};

  Message.fromMap(Map<String, dynamic> data)
    : userId = data['userId'],
      text = data['text'],
      timestamp = data['timestamp'];
}