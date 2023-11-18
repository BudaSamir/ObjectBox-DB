import 'package:objectbox/objectbox.dart';
import 'package:orders_app/models/shop_order.dart';

@Entity()
class Customer {
  late int id;
  late String name;
  @Backlink()
  final orders = ToMany<ShopOrder>();
  Customer({this.id = 0, required this.name});
}
