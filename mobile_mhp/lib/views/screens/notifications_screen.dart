import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/blocs/notification_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/models/notification_model.dart';
import 'package:pharma_nathi/repositories/notification_repository.dart';
import 'package:pharma_nathi/views/widgets/notification_card.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late NotificationsBloc _notificationsBloc;
  late TabController _tabController; // Controller for the TabBar

  @override
  void initState() {
    super.initState();
    _notificationsBloc = NotificationsBloc(NotificationRepository());
    _notificationsBloc.fetchNotifications(); // Fetch notifications on init
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _notificationsBloc.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.PURE_WHITE,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
              color: Colors.white,
            ),
            padding: EdgeInsets.only(top: 25, right: 30, left: 30, bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Pallet.PRIMARY_COLOR,
                  ),
                ),
                SizedBox(width: 70),
                Text(
                  'Notifications',
                  style: GoogleFonts.openSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Pallet.PRIMARY_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TabBar(
                dividerColor: Pallet.PURE_WHITE,
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade400,
                labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                indicatorPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Pallet.PRIMARY_300,
                  borderRadius: BorderRadius.circular(2),
                ),
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Unread'),
                  Tab(text: 'Read'),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<NotificationModel>?>(
                valueListenable: _notificationsBloc.notificationsNotifier,
                builder: (context, notifications, _) {
                  if (notifications == null) {
                    return Center(child: CircularProgressIndicator()); // Loading state
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationList(notifications, 'all'),
                      _buildNotificationList(notifications, 'unread'),
                      _buildNotificationList(notifications, 'read'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, String filter) {
    List<NotificationModel> filteredNotifications = notifications.where((notification) {
      if (filter == 'all') return true;
      return filter == 'unread' ? !notification.isRead : notification.isRead;
    }).toList();

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];

        return NotificationCard(
          notification: notification,
          isExpanded: notification.isExpanded,
          onExpand: () {
            setState(() {
              notification.isExpanded = !notification.isExpanded;
            });
          },
          onMarkAsRead: () async {
            await _notificationsBloc.markNotificationAsRead(notification.id);
          },
        );
      },
    );
  }
}
