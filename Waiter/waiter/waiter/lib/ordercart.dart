import 'package:flutter/material.dart';
import 'model/ordermodel.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final Function(Order)? onStartCooking; // Callback for "Start Cooking"
  final Function(Order)? onCompleteOrder; // Callback for "Finish"

  OrderCard({required this.order, this.onStartCooking, this.onCompleteOrder});

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOverdue = widget.order.timer <= 0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${widget.order.orderNumber}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                'Table ${widget.order.tableNumber}',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                '${widget.order.timer} min remaining',
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
          trailing: isOverdue
              ? FadeTransition(
                  opacity: _controller,
                  child: _buildStatusLabel(widget.order.status),
                )
              : _buildStatusLabel(widget.order.status),
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.order.items
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '• ${item.quantity}x ${item.name} (${item.instructions})',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.order.status == 'New')
                        _buildButton('Start Cooking', Colors.orange, () {
                          if (widget.onStartCooking != null) {
                            widget.onStartCooking!(widget.order);
                          }
                        }),
                      if (widget.order.status == 'In Progress')
                        _buildButton('Finish', Colors.green, () {
                          if (widget.onCompleteOrder != null) {
                            widget.onCompleteOrder!(widget.order);
                          }
                        }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color color = status == 'New'
        ? Colors.red
        : status == 'In Progress'
            ? Colors.orange
            : Colors.green;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color,
        ),
        child: Text(text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
