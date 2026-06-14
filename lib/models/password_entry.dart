class PasswordEntry {
  final String id;
  final String siteName;
  final String username;
  final String password;
  final String? pin;

  final List<Map<String, String>> challenges;

  PasswordEntry({
    required this.id,
    required this.siteName,
    required this.username,
    required this.password,
    this.pin,
    this.challenges = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteName': siteName,
      'username': username,
      'password': password,
      'pin': pin,
      'challenges': challenges,
    };
  }

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> loadedChallenges = [];

    if (json['challenges'] != null) {
      loadedChallenges = List<Map<String, dynamic>>.from(json['challenges'])
          .map((item) => {
                'question': item['question'] as String,
                'answer': item['answer'] as String,
              })
          .toList();
    } 
    else if (json['challengeQuestion'] != null && json['challengeAnswer'] != null) {
      loadedChallenges.add({
        'question': json['challengeQuestion'],
        'answer': json['challengeAnswer'],
      });
    }

    return PasswordEntry(
      id: json['id'],
      siteName: json['siteName'],
      username: json['username'],
      password: json['password'],
      pin: json['pin'],
      challenges: loadedChallenges,
    );
  }
}