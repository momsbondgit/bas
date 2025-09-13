class BotUser {
  final String botId;
  final String nickname;
  final String quineResponse;
  final String goodbyeText;

  const BotUser({
    required this.botId,
    required this.nickname,
    required this.quineResponse,
    required this.goodbyeText,
  });

  Map<String, dynamic> toMap() {
    return {
      'botId': botId,
      'nickname': nickname,
      'quineResponse': quineResponse,
      'goodbyeText': goodbyeText,
    };
  }

  factory BotUser.fromMap(Map<String, dynamic> map) {
    return BotUser(
      botId: map['botId'] as String,
      nickname: map['nickname'] as String,
      quineResponse: map['quineResponse'] as String,
      goodbyeText: map['goodbyeText'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BotUser && other.botId == botId;
  }

  @override
  int get hashCode => botId.hashCode;

  @override
  String toString() {
    return 'BotUser(botId: $botId, nickname: $nickname)';
  }
}