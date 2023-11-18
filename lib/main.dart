import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:orders_app/objectbox.g.dart';
import 'package:orders_app/order_data_table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models/customer.dart';
import 'models/shop_order.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final faker = Faker();
  late Store _store;
  late Stream<List<ShopOrder>> _stream;
  bool hasBeenInitialized = false;
  late Customer _customer;

  @override
  void initState() {
    super.initState();
    setNewCustomer();
    getApplicationDocumentsDirectory().then((dir) {
      _store = Store(
        getObjectBoxModel(),
        directory: join(dir.path, 'objectbox'),
      );

      openStore();

      setState(() {
        _stream = _store
            .box<ShopOrder>()
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find());
        hasBeenInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Orders App'),
          actions: [
            IconButton(
                onPressed: setNewCustomer,
                icon: const Icon(Icons.person_add_alt)),
            IconButton(
              onPressed: addFakeOrderForCurrentCustomer,
              icon: const Icon(Icons.attach_money),
            ),
          ],
        ),
        body: hasBeenInitialized
            ? StreamBuilder<List<ShopOrder>>(
                stream: _stream,
                builder: (context, snapshot) {
                  snapshot.connectionState == ConnectionState.active
                      ? debugPrint("ConnectionState is Active")
                      : debugPrint("ConnectionState isn't Active");
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return OrderDataTable(
                      onSort: (columnIndex, ascending) {
                        final newQueryBuilder = _store.box<ShopOrder>().query();
                        final sortField =
                            columnIndex == 0 ? ShopOrder_.id : ShopOrder_.price;
                        newQueryBuilder.order(sortField,
                            flags: ascending ? 0 : Order.descending);
                        setState(() {
                          _stream = newQueryBuilder
                              .watch(triggerImmediately: true)
                              .map((query) => query.find());
                        });
                      },
                      orders: snapshot.data!,
                      store: _store,
                    );
                  }
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  setNewCustomer() {
    _customer = Customer(name: faker.person.name());
    debugPrint("Name: ${_customer.name}");
  }

  addFakeOrderForCurrentCustomer() {
    final order = ShopOrder(price: faker.randomGenerator.integer(500, min: 10));
    debugPrint("Price: ${order.price}");
    order.customer.target = _customer;
    _store.box<ShopOrder>().put(order);
  }
}
