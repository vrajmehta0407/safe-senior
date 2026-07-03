// lib/models/subscription_plan.dart

class SubscriptionPlan {
  final String id;
  final String name;
  final String label;
  final double price;
  final String period; // 'month' | 'year'
  final double? monthlyEquivalent;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.label,
    required this.price,
    required this.period,
    this.monthlyEquivalent,
  });

  static const SubscriptionPlan monthly = SubscriptionPlan(
    id: 'monthly',
    name: 'Basic Protection',
    label: 'Monthly Plan',
    price: 9.99,
    period: 'month',
  );

  static const SubscriptionPlan annual = SubscriptionPlan(
    id: 'annual',
    name: 'Premium Protection',
    label: 'Annual Plan',
    price: 89.99,
    period: 'year',
    monthlyEquivalent: 7.50,
  );

  static List<SubscriptionPlan> get all => [monthly, annual];

  String get priceLabel =>
      '\$${price.toStringAsFixed(2)} / $period';
}
