import 'package:flutter/material.dart';

import 'models/shop_order.dart';
import 'objectbox.g.dart';

class OrderDataTable extends StatefulWidget {
  final Store store;
  final List<ShopOrder> orders;
  final void Function(int columnIndex, bool ascending) onSort;
  const OrderDataTable(
      {super.key,
      required this.onSort,
      required this.orders,
      required this.store});

  @override
  State<OrderDataTable> createState() => _OrderDataTableState();
}

class _OrderDataTableState extends State<OrderDataTable> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        columns: [
          DataColumn(
            label: const Text("Number"),
            onSort: _onDataColumnSort,
          ),
          const DataColumn(label: Text("Customer")),
          DataColumn(
              label: const Text("Price"),
              onSort: _onDataColumnSort,
              numeric: true),
          const DataColumn(label: SizedBox()),

          // const DataColumn(label: SizedBox()),
        ],
        rows: widget.orders
            .map((order) => DataRow(cells: [
                  DataCell(Text(order.id.toString())),
                  DataCell(Text(order.customer.target?.name ?? 'NONE'),
                      onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Material(
                        child: ListView(
                          children: order.customer.target!.orders
                              .map((_) => ListTile(
                                    title: Text(
                                        "${_.id} ${_.customer.target?.name} \$ ${_.price}"),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Text('\$ ${order.price}'),
                  ),
                  DataCell(
                    const Icon(Icons.delete),
                    onTap: () {
                      widget.store.box<ShopOrder>().remove(order.id);
                    },
                  ),
                ]))
            .toList(),
      ),
    );
  }

  _onDataColumnSort(int columnIndex, bool ascending) {
    setState(() {
      _sortAscending = ascending;
      _sortColumnIndex = columnIndex;
    });
    widget.onSort(columnIndex, ascending);
  }
}
