class Word {
  final String native;
  final String english;
  final String image;
  final String audioNative;
  final String audioEnglish;

  Word({
    required this.native,
    required this.english,
    required this.image,
    required this.audioNative,
    required this.audioEnglish,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        native: json['native'] ?? '',
        english: json['english'] ?? '',
        image: json['image'] ?? '',
        audioNative: json['audio_native'] ?? '',
        audioEnglish: json['audio_english'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'native': native,
        'english': english,
        'image': image,
        'audio_native': audioNative,
        'audio_english': audioEnglish,
      };
}
