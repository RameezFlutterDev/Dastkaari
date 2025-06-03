abstract class CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Map<String, List<Map<String, dynamic>>> groupedCartItems;
  final Map<String, String> sellerNames;

  CartLoaded({required this.groupedCartItems, required this.sellerNames});
}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}
