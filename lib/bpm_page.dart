import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';

class BPMPage extends StatefulWidget {
  const BPMPage({super.key});

  @override
  State<BPMPage> createState() => _BPMPageState();
}

class _BPMPageState extends State<BPMPage> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.79.194:8765'), // Update to your correct IP and port
  );

  String bpm = "Waiting for BPM data...";
  List<double> bpmData = [];  // Store historical BPM data for graph
  bool isMonitoring = false;  // Track if monitoring is active
  bool isDisposed = false;    // Track if the widget is disposed

  @override
  void initState() {
    super.initState();
    _startDataListener();
  }

  void _startDataListener() {
    // Listen to WebSocket stream for incoming BPM data
    channel.stream.listen((data) {
      if (!isMonitoring || isDisposed) return; // Skip if monitoring stopped or widget disposed
      try {
        final parsedData = jsonDecode(data);
        if (parsedData.containsKey('BPM')) {
          double bpmValue = parsedData['BPM'].toDouble();
          if (!isDisposed) {
            setState(() {
              bpm = bpmValue.toStringAsFixed(3);  // Format BPM to 3 decimal places
              bpmData.add(bpmValue);  // Add data to graph
              if (bpmData.length > 20) bpmData.removeAt(0);  // Limit graph length
            });
          }
        }
      } catch (e) {
        if (!isDisposed) {
          setState(() {
            bpm = "Error receiving data";
          });
        }
      }
    }, onError: (error) {
      if (!isDisposed) {
        setState(() {
          bpm = "Connection error";
        });
      }
    }, onDone: () {
      if (!isDisposed) {
        setState(() {
          bpm = "Connection closed";
        });
      }
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    if (isMonitoring) _stopBPMMonitoring();  // Stop monitoring on exit
    channel.sink.close();  // Close WebSocket connection
    super.dispose();
  }

  void _startBPMMonitoring() {
    if (!isDisposed) {
      channel.sink.add(jsonEncode({"command": "START_MONITORING", "page": "BPM"}));
      setState(() {
        isMonitoring = true;
        bpm = "Starting BPM measurement...";
      });
    }
  }

  void _stopBPMMonitoring() {
    if (!isDisposed) {
      channel.sink.add(jsonEncode({"command": "STOP_MONITORING", "page": "BPM"}));
      setState(() {
        isMonitoring = false;  // Immediately stop updating the graph data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BPM Monitor')),
      body: SingleChildScrollView(  // Wrap in SingleChildScrollView to prevent overflow
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display current BPM value
            SizedBox(height: 20),
            Text('Current BPM:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(
              bpm,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 30),

            // Title for BPM history graph
            Text('BPM History', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),

            // BPM graph using fl_chart
            Container(
              height: 200,
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: bpmData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                    ),
                  ],
                  minY: 0, // Set minimum y-axis value to 0
                  maxY: bpmData.isNotEmpty
                      ? bpmData.reduce((a, b) => a > b ? a : b) + 10
                      : 200,  // Set default max y-axis to 200
                ),
              ),
            ),
            SizedBox(height: 35),

            // Buttons for starting and stopping monitoring
            ElevatedButton(
              onPressed: isMonitoring ? null : _startBPMMonitoring,
              child: Text('Start Measuring BPM'),
            ),
            ElevatedButton(
              onPressed: isMonitoring ? _stopBPMMonitoring : null,
              child: Text('Stop Measuring'),
            ),
          ],
        ),
      ),
    );
  }
}
