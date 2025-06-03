import 'package:dastkaari/services/cart/cart_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService cartService;

  CartBloc(this.cartService) : super(CartLoading()) {
    on<LoadCart>(_onLoadCart);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<DecreaseQuantity>(_onDecreaseQuantity);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      final items = await cartService.fetchCartItems();
      Map<String, List<Map<String, dynamic>>> grouped = {};
      Set<String> sellerIds = {};

      for (var item in items) {
        String sellerId = item['sellerId'];
        sellerIds.add(sellerId);
        if (!grouped.containsKey(sellerId)) {
          grouped[sellerId] = [];
        }
        grouped[sellerId]!.add(item);
      }

      Map<String, String> sellerNamesMap = {};
      for (String sellerId in sellerIds) {
        final doc = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(sellerId)
            .get();
        sellerNamesMap[sellerId] = doc.data()?['storeName'] ?? 'Unknown Seller';
      }

      emit(CartLoaded(groupedCartItems: grouped, sellerNames: sellerNamesMap));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onAddItem(AddItem event, Emitter<CartState> emit) async {
    cartService.updateCartItem(event.productId, event.newQuantity);
    add(LoadCart());
  }

  Future<void> _onRemoveItem(RemoveItem event, Emitter<CartState> emit) async {
    cartService.removeFromCart(event.productId);
    add(LoadCart());
  }

  Future<void> _onDecreaseQuantity(
      DecreaseQuantity event, Emitter<CartState> emit) async {
    cartService.updateCartItem(event.productId, event.newQuantity);
    add(LoadCart());
  }
}
