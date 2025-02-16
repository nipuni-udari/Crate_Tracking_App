import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking/user_provider.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';

class UnloadingTab extends StatefulWidget {
  const UnloadingTab({Key? key}) : super(key: key);

  @override
  _UnloadingTabState createState() => _UnloadingTabState();
}

class _UnloadingTabState extends State<UnloadingTab> {
  List<String> scannedCrates = [];
  bool isScanning = false;
  String? selectedLorry;
  String? selectedCustomer;
  String? selectedPoNumber;
  List<String> lorryNumbers = [];
  List<String> customers = [];
  List<String> poNumbers = [];
  String serverResponse = "";

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

  Future<List<String>> fetchCustomers() async {
    final response = await http.post(
      Uri.parse('https://demo.secretary.lk/cargills_app/backend/customers.php'),
    );
    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load customers');
    }
  }

  Future<List<String>> fetchPoNumbers() async {
    final response = await http.post(
      Uri.parse(
        'https://demo.secretary.lk/cargills_app/backend/po_numbers.php',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load PO numbers');
    }
  }

  Future<void> _startScan() async {
    if (selectedLorry == null ||
        selectedCustomer == null ||
        selectedPoNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select lorry, customer and PO number first"),
        ),
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
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Total crates scanned: ${scannedCrates.length}")),
    );
  }

  Future<void> _sendToDatabase(String serialNumber) async {
    try {
      // Extract the BP code (e.g., "BP001") from the selectedCustomer string
      String bpCode = selectedCustomer!.split(' - ')[0];

      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/backend/unloading_crate_log.php',
        ),
        body: {
          'serial': serialNumber,
          'vehicle_no': selectedLorry!,
          'customer': bpCode, // Send only the BP code
          'po_number': selectedPoNumber!,
        },
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
                  const SizedBox(height: 20),
                  _buildCustomerSelection(userProvider),
                  const SizedBox(height: 20),
                  _buildPoSelection(userProvider),
                  if (selectedLorry != null &&
                      selectedCustomer != null &&
                      selectedPoNumber != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Selected Lorry: $selectedLorry',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 249, 139, 71),
                            ),
                          ),
                          Text(
                            'Customer: $selectedCustomer',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 249, 139, 71),
                            ),
                          ),
                          Text(
                            'PO Number: $selectedPoNumber',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 249, 139, 71),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildLocationDetails(userProvider),
                  const SizedBox(height: 20),
                  _buildStartScanButton(),
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
            ),
            child: SearchableDropdown<String>(
              items:
                  lorryNumbers
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              value: selectedLorry,
              hint: const Text('Select Lorry'),
              searchHint: const Text('Search lorry'),
              onChanged: (value) {
                setState(() {
                  selectedLorry = value;
                });
              },
              isExpanded: true,
            ),
          );
        }
      },
    );
  }

  Widget _buildCustomerSelection(UserProvider userProvider) {
    return FutureBuilder<List<String>>(
      future: fetchCustomers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No customers available');
        } else {
          customers = snapshot.data!;
          return Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 249, 139, 71),
                width: 2,
              ),
            ),
            child: SearchableDropdown<String>(
              items:
                  customers
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              value: selectedCustomer,
              hint: const Text('Select Customer'),
              searchHint: const Text('Search customer'),
              onChanged: (value) {
                setState(() {
                  selectedCustomer = value;
                });
              },
              isExpanded: true,
            ),
          );
        }
      },
    );
  }

  Widget _buildPoSelection(UserProvider userProvider) {
    return FutureBuilder<List<String>>(
      future: fetchPoNumbers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No PO numbers available');
        } else {
          poNumbers = snapshot.data!;
          return Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 249, 139, 71),
                width: 2,
              ),
            ),
            child: SearchableDropdown<String>(
              items:
                  poNumbers
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              value: selectedPoNumber,
              hint: const Text('Select PO Number'),
              searchHint: const Text('Search PO number'),
              onChanged: (value) {
                setState(() {
                  selectedPoNumber = value;
                });
              },
              isExpanded: true,
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
