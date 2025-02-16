import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking/user_provider.dart';

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
  int totalScannedCrates = 0; // Add this variable

  Future<List<String>> fetchVehicles(
    String subLocationId,
    String divisionId,
  ) async {
    final response = await http.post(
      Uri.parse(
        'https://demo.secretary.lk/cargills_app/backend/vehicle_details.php',
      ),
      body: {'sub_location_id': subLocationId, 'division_id': divisionId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<void> _startScan() async {
    if (selectedLorry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a lorry first")),
      );
      return;
    }

    var status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        isScanning = true;
        scannedCrates.clear();
        serverResponse = "";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera permission is required to scan QR codes"),
        ),
      );
    }
  }

  void _doneScanning() {
    setState(() {
      isScanning = false;
      totalScannedCrates = scannedCrates.length; // Store the count
      scannedCrates.clear(); // Clear the list for the next scan
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Total crates scanned: $totalScannedCrates")),
    );
  }

  Future<void> _sendToDatabase(String serialNumber) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/backend/loading_crate_log.php',
        ),
        body: {'serial': serialNumber, 'vehicle_no': selectedLorry!},
      );

      final responseData = json.decode(response.body);
      setState(() {
        if (response.statusCode == 200 && responseData["status"] == "success") {
          serverResponse = "Crate $serialNumber saved successfully!";
        } else {
          serverResponse = "Failed to save crate: ${responseData["message"]}";
        }
      });
    } catch (e) {
      setState(() {
        serverResponse = "Error: ${e.toString()}";
      });
    }
  }

  Widget _buildTotalScannedCrates() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 249, 139, 71),
              const Color.fromARGB(255, 255, 183, 77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "Loaded Crates = $totalScannedCrates",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Center(
      child:
          isScanning
              ? _buildScanner()
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLorrySelection(userProvider),
                  if (selectedLorry != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Selected Lorry: $selectedLorry',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 249, 139, 71),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildLocationDetails(userProvider),
                  const SizedBox(height: 20),
                  _buildStartScanButton(),
                  if (totalScannedCrates >
                      0) // Show the count if crates were scanned
                    _buildTotalScannedCrates(),
                ],
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
          return const CircularProgressIndicator();
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
            child: DropdownButton<String>(
              value: selectedLorry,
              hint: const Text('Select Lorry'),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color.fromARGB(255, 249, 139, 71),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 18),
              underline: const SizedBox(),
              items:
                  lorryNumbers.map((lorry) {
                    return DropdownMenuItem<String>(
                      value: lorry,
                      child: Text(lorry, style: const TextStyle(fontSize: 18)),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLorry = value;
                });
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildLocationDetails(UserProvider userProvider) {
    return Column(
      children: [
        if (userProvider.subLocationId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Sub Location: ${userProvider.subLocationId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 249, 139, 71),
              ),
            ),
          ),
        if (userProvider.divisionsId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Division: ${userProvider.divisionsId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 249, 139, 71),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStartScanButton() {
    return ElevatedButton(
      onPressed: selectedLorry != null ? _startScan : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedLorry != null
                ? const Color.fromARGB(255, 249, 139, 71)
                : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text("Start Scan"),
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
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (serverResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    serverResponse,
                    style: TextStyle(
                      fontSize: 16,
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
                      (context, index) =>
                          ListTile(title: Text(scannedCrates[index])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _doneScanning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text("Done Scanning"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
