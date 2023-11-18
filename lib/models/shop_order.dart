import 'package:objectbox/objectbox.dart';
import 'package:orders_app/models/customer.dart';

@Entity()
class ShopOrder {
  late int id;
  late int price;
  final customer = ToOne<Customer>();

  ShopOrder({
    this.id = 0,
    required this.price,
  });
}
