class UserProgress {
  int stars;
  int completedWords;

  UserProgress({this.stars = 0, this.completedWords = 0});

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        stars: json['stars'] ?? 0,
        completedWords: json['completedWords'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'stars': stars,
        'completedWords': completedWords,
      };
}
