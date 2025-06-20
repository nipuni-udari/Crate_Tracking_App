import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking/user_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingTab extends StatefulWidget {
  const LoadingTab({Key? key}) : super(key: key);

  @override
  _LoadingTabState createState() => _LoadingTabState();
}

class _LoadingTabState extends State<LoadingTab> {
  List<String> scannedCrates = [];
  bool isScanning = false;
  String? selectedLorry;
  List<String> lorryNumbers = [];
  String serverResponse = "";
  int totalScannedCrates = 0;

  Future<List<String>> fetchVehicles(
    String subLocationId,
    String divisionId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/loading_person/backend/vehicle_details.php',
        ),
        body: {'sub_location_id': subLocationId, 'division_id': divisionId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception('Failed to load vehicles');
      }
    } on SocketException {
      throw ('No internet connection');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> _startScan() async {
    if (selectedLorry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a truck first")),
      );
      return;
    }

    var status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        isScanning = true;
        scannedCrates.clear();
        serverResponse = "";
        totalScannedCrates = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera permission is required to scan QR codes"),
        ),
      );
    }
  }

  Future<void> _sendTotalCratesToDatabase() async {
    if (selectedLorry == null || totalScannedCrates == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please scan correct crates ")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/loading_person/backend/save_load_total_crates.php',
        ),
        body: {
          'vehicle_no': selectedLorry!,
          'total_crates': totalScannedCrates.toString(),
        },
      );

      print("Response Code: ${response.statusCode}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  // New method to remove crate from database
  Future<bool> _removeCrateFromDatabase(String serialNumber) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/loading_person/backend/remove_loading_crate.php', // You'll need to create this endpoint
        ),
        body: {
          'serial': serialNumber,
          'vehicle_no': selectedLorry!,
          'user_name': userProvider.username,
          'mobile_number': userProvider.mobileNumber,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        setState(() {
          serverResponse = "Crate $serialNumber removed successfully!";
        });
        return true;
      } else {
        setState(() {
          serverResponse = "Failed to remove crate: ${responseData["message"]}";
        });
        return false;
      }
    } catch (e) {
      setState(() {
        serverResponse = "Error removing crate: ${e.toString()}";
      });
      return false;
    }
  }

  // Method to handle crate removal with confirmation
  Future<void> _removeCrate(String serialNumber) async {
    // Show confirmation dialog
    bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Crate'),
          content: Text(
            'Are you sure you want to remove crate: $serialNumber?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Try to remove from database first
      bool removed = await _removeCrateFromDatabase(serialNumber);

      // Close loading dialog
      Navigator.of(context).pop();

      if (removed) {
        // Remove from local list and update count
        setState(() {
          scannedCrates.remove(serialNumber);
          totalScannedCrates = scannedCrates.length;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Crate $serialNumber removed successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove crate $serialNumber"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _doneScanning() {
    setState(() {
      isScanning = false;
    });

    _sendTotalCratesToDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Total crates scanned and saved: $totalScannedCrates"),
      ),
    );
  }

  Future<void> _sendToDatabase(String serialNumber) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/loading_person/backend/loading_crate_log.php',
        ),
        body: {
          'serial': serialNumber,
          'vehicle_no': selectedLorry!,
          'user_name': userProvider.username,
          'mobile_number': userProvider.mobileNumber,
        },
      );

      final responseData = json.decode(response.body);

      setState(() {
        if (response.statusCode == 200) {
          if (responseData["status"] == "success") {
            serverResponse = "Crate $serialNumber saved successfully!";
            totalScannedCrates++;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Crate $serialNumber saved successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          } else if (responseData["status"] == "duplicate") {
            serverResponse = "You have already scanned this crate.";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Duplicate crate: $serialNumber"),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            serverResponse = "Failed to save crate: ${responseData["message"]}";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to save crate: ${responseData["message"]}",
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          serverResponse = "Server error: ${response.statusCode}";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        serverResponse = "Error: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetPage() {
    setState(() {
      isScanning = false;
      scannedCrates.clear();
      selectedLorry = null;
      serverResponse = "";
      totalScannedCrates = 0;
    });
  }

  Widget _buildTotalScannedCratesCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 139, 71),
              const Color.fromARGB(255, 255, 183, 77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Scanned Crates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              totalScannedCrates.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLorrySelection(UserProvider userProvider) {
    return FutureBuilder<List<String>>(
      future: fetchVehicles(
        userProvider.subLocationId,
        userProvider.divisionsId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitThreeBounce(
            color: Color.fromARGB(255, 249, 139, 71),
            size: 30.0,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No vehicles available');
        } else {
          lorryNumbers = snapshot.data!;
          return Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 249, 139, 71),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 241, 240, 240),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SearchableDropdown<String>(
              items:
                  lorryNumbers.map((String lorry) {
                    return DropdownMenuItem<String>(
                      value: lorry,
                      child: Text(lorry, style: const TextStyle(fontSize: 18)),
                    );
                  }).toList(),
              value: selectedLorry,
              hint: const Text('Select Truck'),
              searchHint: const Text('Search for a truck'),
              onChanged: (value) {
                setState(() {
                  selectedLorry = value;
                });
              },
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color.fromARGB(255, 249, 139, 71),
              ),
              iconDisabledColor: Colors.grey,
              iconEnabledColor: const Color.fromARGB(255, 249, 139, 71),
              style: const TextStyle(color: Colors.black, fontSize: 18),
              selectedValueWidgetFn: (item) {
                return Text(item, style: const TextStyle(fontSize: 18));
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildLocationDetailsCard(UserProvider userProvider) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 139, 71),
              const Color.fromARGB(255, 255, 183, 77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userProvider.subLocationName.isNotEmpty)
                    Flexible(
                      child: Text(
                        'Sub Location: ${userProvider.subLocationName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (userProvider.divisionsName.isNotEmpty)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Division: ${userProvider.divisionsName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScanButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt,
          size: 60,
          color: const Color.fromARGB(255, 249, 139, 71),
        ),
        const SizedBox(height: 10),
        const Text(
          "Scan the QR Code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Please scan the crate details",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: selectedLorry != null ? _startScan : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedLorry != null
                    ? const Color.fromARGB(255, 249, 139, 71)
                    : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            textStyle: const TextStyle(fontSize: 14),
          ),
          child: const Text("Start Scan"),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background_pattern.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.lighten,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDetailsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 139, 71),
              const Color.fromARGB(255, 255, 183, 77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedLorry != null)
              Flexible(
                child: Text(
                  'Truck: $selectedLorry',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null &&
                    barcode.format == BarcodeFormat.qrCode) {
                  String serialNumber = barcode.rawValue!;
                  if (!scannedCrates.contains(serialNumber)) {
                    setState(() {
                      scannedCrates.add(serialNumber);
                    });
                    await _sendToDatabase(serialNumber);
                  } else {
                    // Show duplicate message immediately without database call
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text("Duplicate crate: $serialNumber"),
                    //     backgroundColor: Colors.orange,
                    //   ),
                    // );
                  }
                }
              }
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Scanned Crates: ${scannedCrates.length}",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (serverResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    serverResponse,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          serverResponse.contains("successfully")
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: scannedCrates.length,
                  itemBuilder:
                      (context, index) => ListTile(
                        title: Text(
                          scannedCrates[index],
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _removeCrate(scannedCrates[index]),
                          tooltip: 'Remove crate',
                        ),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _doneScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 5, 168, 29),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Done Scanning",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _resetPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text("Exit", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Column(
            children: [
              if (!isScanning)
                SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildLocationDetailsCard(userProvider),
                        if (totalScannedCrates > 0)
                          _buildTotalScannedCratesCard(),
                        if (selectedLorry != null) _buildSelectedDetailsCard(),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child:
                      isScanning
                          ? _buildScanner()
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLorrySelection(userProvider),
                              const SizedBox(height: 20),
                              _buildStartScanButton(),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
