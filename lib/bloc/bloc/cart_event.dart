abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddItem extends CartEvent {
  final String productId;
  final int newQuantity;

  AddItem({required this.productId, required this.newQuantity});
}

class RemoveItem extends CartEvent {
  final String productId;
  RemoveItem({required this.productId});
}

class DecreaseQuantity extends CartEvent {
  final String productId;
  final int newQuantity;

  DecreaseQuantity({required this.productId, required this.newQuantity});
}
