class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Explore the World",
    image: "assets/images/onboarding_1.png",
    desc: "Search destinations, explore attractions, check weather forecasts, and find the perfect places for your next unforgettable journey.",
  ),
  OnboardingContents(
    title: "AI-Powered Trip Planning",
    image: "assets/images/onboarding_2.png",
    desc:
    "Generate personalized itineraries, manage travel expenses, compare hotels and flights, and organize every detail of your trip effortlessly.",
  ),
  OnboardingContents(
    title: "Share & Relive Every Moment",
    image: "assets/images/onboarding_3.png",
    desc:
    "Share trips with friends, track locations on interactive maps, receive smart notifications, chat with your AI travel assistant, and preserve memories in your travel journal.",
  ),
];