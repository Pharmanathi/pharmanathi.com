import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/models/notification_model.dart';


class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isExpanded;
  final Function() onExpand;
  final Function() onMarkAsRead;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.isExpanded,
    required this.onExpand,
    required this.onMarkAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRead = notification.isRead;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      color: isRead ? Colors.grey.shade200 : Pallet.BACKGROUND_COLOR,
      elevation: 0,
      child: Opacity(
        opacity: isRead ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            gradient: isRead
                ? null
                : LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification.category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isRead ? Colors.grey : Colors.black,
                  ),
                ),
                Text(
                  DateFormat('HH:mm - dd MMM').format(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: isRead ? Colors.grey.shade600 : Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRead ? Colors.grey : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                if (isExpanded) // Show expanded content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (notification.shouldNavigate)
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, notification.screen);
                          },
                          child: Text('View'),
                        ),
                    ],
                  ),
              ],
            ),
            onTap: () {
              onExpand();
              onMarkAsRead();
            },
          ),
        ),
      ),
    );
  }
}
