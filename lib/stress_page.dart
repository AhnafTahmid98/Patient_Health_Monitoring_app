import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';

class StressPage extends StatefulWidget {
  const StressPage({super.key});

  @override
  State<StressPage> createState() => _StressPageState();
}

class _StressPageState extends State<StressPage> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.79.194:8765'), // Update with your Raspberry Pi's IP and port
  );

  String stressLevel = "Waiting for stress data...";
  List<double> gsrData = []; // Store historical GSR data for graph
  bool isMonitoring = false; // Track if monitoring is active
  bool isDisposed = false;   // Track if widget is disposed

  @override
  void initState() {
    super.initState();
    _startDataListener();
  }

  void _startDataListener() {
    // Listen to WebSocket stream for incoming GSR data
    channel.stream.listen((data) {
      if (!isMonitoring || isDisposed) return; // Skip if monitoring stopped or widget disposed
      try {
        final parsedData = jsonDecode(data);
        if (parsedData.containsKey('Stress')) {
          String gsrStatus = parsedData['Stress'];
          if (!isDisposed) {
            setState(() {
              stressLevel = gsrStatus; // Update displayed stress level
              double gsrValue = _convertStatusToValue(gsrStatus); // Convert status to numeric value for graph
              gsrData.add(gsrValue); // Add data to graph
              if (gsrData.length > 20) gsrData.removeAt(0); // Limit graph length
            });
          }
        }
      } catch (e) {
        if (!isDisposed) {
          setState(() {
            stressLevel = "Error receiving data";
          });
        }
      }
    }, onError: (error) {
      if (!isDisposed) {
        setState(() {
          stressLevel = "Connection error";
        });
      }
    }, onDone: () {
      if (!isDisposed) {
        setState(() {
          stressLevel = "Connection closed";
        });
      }
    });
  }

  double _convertStatusToValue(String status) {
    // Assign numerical values to statuses for graph representation
    switch (status) {
      case "Relaxed":
        return 1.0;
      case "Normal":
        return 2.0;
      case "Elevated":
        return 3.0;
      case "High":
        return 4.0;
      default:
        return 0.0; // "No contact" or unrecognized states
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    if (isMonitoring) _stopStressMonitoring(); // Stop monitoring on exit
    channel.sink.close(); // Close WebSocket connection
    super.dispose();
  }

  void _startStressMonitoring() {
    if (!isDisposed) {
      channel.sink.add(jsonEncode({"command": "START_MONITORING", "page": "GSR"}));
      setState(() {
        isMonitoring = true;
        stressLevel = "Starting stress measurement...";
      });
    }
  }

  void _stopStressMonitoring() {
    if (!isDisposed) {
      channel.sink.add(jsonEncode({"command": "STOP_MONITORING", "page": "GSR"}));
      setState(() {
        isMonitoring = false; // Immediately stop updating the graph data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('StressPage'), // Add a unique Key for testing
      appBar: AppBar(title: Text('Stress Level Monitor')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text('Current Stress Level:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(
              stressLevel,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            // Title for Stress history graph
            Text('Stress Level History', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),

            // Stress Level graph using fl_chart
            Container(
              height: 200,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: gsrData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 1:
                              return Text('Relaxed');
                            case 2:
                              return Text('Normal');
                            case 3:
                              return Text('Elevated');
                            case 4:
                              return Text('High');
                            default:
                              return Text('');
                          }
                        },
                        reservedSize: 70,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false, // Hide x-axis labels
                      ),
                    ),
                  ),
                  minY: 0,
                  maxY: 4,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isMonitoring ? null : _startStressMonitoring,
              child: Text('Start Measuring Stress'),
            ),
            ElevatedButton(
              onPressed: isMonitoring ? _stopStressMonitoring : null,
              child: Text('Stop Measuring'),
            ),
          ],
        ),
      ),
    );
  }
}
