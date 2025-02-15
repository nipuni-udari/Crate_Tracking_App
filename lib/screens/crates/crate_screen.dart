import 'package:flutter/material.dart';
import 'package:crate_tracking/screens/bottom_nav_bar.dart';
import 'package:crate_tracking/screens/crates/loading_tab.dart';
import 'package:crate_tracking/screens/crates/receiving_tab.dart';

class CrateScreen extends StatefulWidget {
  const CrateScreen({Key? key}) : super(key: key);

  @override
  _CrateScreenState createState() => _CrateScreenState();
}

class _CrateScreenState extends State<CrateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crate Tracking"),
        backgroundColor: const Color.fromARGB(255, 249, 139, 71),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Loading"), Tab(text: "Receiving")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [LoadingTab(), ReceivingTab()],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
