import 'package:flutter/material.dart';
import '../../../models/order_model.dart';

class NewOrderNotification extends StatefulWidget {
  final Order order;
  final VoidCallback onViewPressed;

  const NewOrderNotification({
    Key? key,
    required this.order,
    required this.onViewPressed,
  }) : super(key: key);

  @override
  _NewOrderNotificationState createState() => _NewOrderNotificationState();
}

class _NewOrderNotificationState extends State<NewOrderNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _slideAnimation.value + 16,
          right: 16,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          'New Order!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _controller.reverse().then((_) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('Order #${widget.order.id}'),
                    const SizedBox(height: 8),
                    // Text(
                    //   '${widget.order.items.length} items • ${widget.order.totalPrice.toStringAsFixed(2)}',
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _controller.reverse().then((_) {
                              widget.onViewPressed();
                            });
                          },
                          child: const Text('VIEW ORDER'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}