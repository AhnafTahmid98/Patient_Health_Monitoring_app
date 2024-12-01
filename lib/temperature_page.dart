import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.79.194:8765'), // Ensure this is the correct IP and port
  );

  String temperature = "Waiting for Temperature data...";
  List<double> temperatureData = [];  // Store historical temperature data for graph
  bool isMonitoring = false;  // Track if monitoring is active
  bool isDisposed = false;    // Track if the widget is disposed

  @override
  void initState() {
    super.initState();
    _startDataListener();
  }

  void _startDataListener() {
    // Listen to WebSocket stream and update only if monitoring is active
    channel.stream.listen((data) {
      if (!isMonitoring || isDisposed) return; // Skip if monitoring stopped or widget disposed
      try {
        final parsedData = jsonDecode(data);
        if (parsedData.containsKey('Temperature')) {
          setState(() {
            double tempValue = parsedData['Temperature'].toDouble();
            temperature = tempValue.toStringAsFixed(3);  // Format Temperature to 3 decimal places
            temperatureData.add(tempValue);  // Add data to graph
            if (temperatureData.length > 20) temperatureData.removeAt(0);  // Limit graph length
          });
        }
      } catch (e) {
        if (!isDisposed) {
          setState(() {
            temperature = "Error receiving data";
          });
        }
      }
    }, onError: (error) {
      if (!isDisposed) {
        setState(() {
          temperature = "Connection error";
        });
      }
    }, onDone: () {
      if (!isDisposed) {
        setState(() {
          temperature = "Connection closed";
        });
      }
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    if (isMonitoring) _stopTemperatureMonitoring();  // Stop monitoring on exit
    channel.sink.close();  // Close WebSocket connection
    super.dispose();
  }

  void _startTemperatureMonitoring() {
    channel.sink.add(jsonEncode({"command": "START_MONITORING", "page": "Temperature"}));
    setState(() {
      isMonitoring = true;
      temperature = "Starting Temperature measurement...";
    });
  }

  void _stopTemperatureMonitoring() {
    channel.sink.add(jsonEncode({"command": "STOP_MONITORING", "page": "Temperature"}));
    setState(() {
      isMonitoring = false; // Immediately stop updating the graph data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Temperature Monitor')),
      body: SingleChildScrollView(  // Wrap in SingleChildScrollView to prevent overflow
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display current BPM value
            SizedBox(height: 20),
            Text('Current Temperature:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(
              temperature,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 30),

            // Title for BPM history graph
            Text('Temperature History', style: TextStyle(fontSize: 24)),
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
                      spots: temperatureData
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
                  maxY: temperatureData.isNotEmpty
                      ? temperatureData.reduce((a, b) => a > b ? a : b) + 10
                      : 40,  // Set default max y-axis to 200
                ),
              ),
            ),
            SizedBox(height: 35),

            // Buttons for starting and stopping monitoring
            ElevatedButton(
              onPressed: isMonitoring ? null : _startTemperatureMonitoring,
              child: Text('Start Measuring Temperature'),
            ),
            ElevatedButton(
              onPressed: isMonitoring ? _stopTemperatureMonitoring : null,
              child: Text('Stop Measuring'),
            ),
          ],
        ),
      ),
    );
  }
}
