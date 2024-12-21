import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  int currentFloor = 0; // Start on the 0th floor
  bool isMovingUp = false;
  bool isMovingDown = false;
  String doorStatus = 'Closed'; // Initial door status
  int weight = 88;
  int? targetFloor; // Track the target floor
  late AnimationController _controller;
  late Animation<double> _arrowAnimationUp;
  late Animation<double> _arrowAnimationDown;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of the movement
    );
    _arrowAnimationUp = Tween<double>(begin: 0.0, end: 30.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _arrowAnimationDown = Tween<double>(begin: 0.0, end: 30.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> moveToFloor(int target) async {
    if (currentFloor == target) return;

    setState(() {
      targetFloor = target; // Set the target floor
      doorStatus = 'Closed'; // Door should be closed while moving
      if (target > currentFloor) {
        isMovingUp = true;
        isMovingDown = false;
      } else {
        isMovingUp = false;
        isMovingDown = true;
      }
    });

    if (isMovingUp) {
      for (int floor = currentFloor + 1; floor <= target; floor++) {
        await _updateFloorWithDelay(floor, true); // Show up arrow
      }
    } else {
      for (int floor = currentFloor - 1; floor >= target; floor--) {
        await _updateFloorWithDelay(floor, false); // Show down arrow
      }
    }

    setState(() {
      currentFloor = target;
      isMovingUp = false;
      isMovingDown = false;
      doorStatus = 'Open'; // Open the door when elevator reaches the target floor
      targetFloor = null; // Clear the target floor
    });

    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      doorStatus = 'Closed'; // Close the door after a delay
    });
  }

  Future<void> _updateFloorWithDelay(int floor, bool isUpward) async {
    setState(() {
      currentFloor = floor;
      isMovingUp = isUpward;
      isMovingDown = !isUpward;
    });

    _controller.forward().then((_) => _controller.reverse());
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to handle the SOS emergency
  void _triggerEmergencySOS() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Emergency SOS'),
          content: const Text('An emergency SOS request has been triggered!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowExtraButton =
        doorStatus == 'Closed' &&
            !isMovingUp &&
            !isMovingDown &&
            isCurrentFloorButtonDisabled();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real-Time Tracking Section
              _buildRealTimeTracking(),
              const SizedBox(height: 40),  // Increased spacing
              // Elevator Call Section
              _buildElevatorCall(),
              // Show Extra Button if conditions are met
              if (shouldShowExtraButton)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          doorStatus = 'Open'; // Open the door
                        });
                        await Future.delayed(const Duration(seconds: 5));
                        setState(() {
                          doorStatus = 'Closed';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Open Doors'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      // Emergency SOS Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerEmergencySOS,
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning, size: 30),
      ),
    );
  }

  Widget _buildRealTimeTracking() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24.0),  // Increased padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elevator Status',
            style: TextStyle(
              fontSize: 26,  // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Floor:', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Text(
                    _getFloorLabel(currentFloor),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isMovingUp)
                    AnimatedBuilder(
                      animation: _arrowAnimationUp,
                      builder: (context, child) {
                        return Icon(Icons.arrow_upward, color: Colors.green, size: _arrowAnimationUp.value);
                      },
                    ),
                  if (isMovingDown)
                    AnimatedBuilder(
                      animation: _arrowAnimationDown,
                      builder: (context, child) {
                        return Icon(Icons.arrow_downward, color: Colors.red, size: _arrowAnimationDown.value);
                      },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),  // Increased space
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Door Status:', style: TextStyle(fontSize: 18)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  doorStatus,
                  key: ValueKey<String>(doorStatus),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: doorStatus == 'Open' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weight:', style: TextStyle(fontSize: 18)),
              Text(
                '$weight Kg',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElevatorCall() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24.0),  // Increased padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elevator Call',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonWidth = (constraints.maxWidth - 40) / 3;
              return Column(
                children: [
                  _buildFloorButtons(0, 2, buttonWidth),
                  const SizedBox(height: 16),
                  _buildFloorButtons(3, 5, buttonWidth),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloorButtons(int start, int end, double buttonWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(end - start + 1, (index) {
        final floor = start + index;
        return SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: (currentFloor == floor || isMovingUp || isMovingDown || targetFloor == floor)
                ? null
                : () => moveToFloor(floor),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentFloor == floor ? Colors.grey : Colors.orangeAccent,
              foregroundColor: Colors.white,
              side: BorderSide(
                color: (isMovingUp || isMovingDown) && currentFloor == floor
                    ? Colors.white // White border for current moving floor
                    : Colors.transparent, // No border for other floors
                width: 2, // Border width
              ),
            ),
            child: Text('${_getFloorLabel(floor)}'),
          ),
        );
      }),
    );
  }

  String _getFloorLabel(int index) {
    return index.toString();
  }

  bool isCurrentFloorButtonDisabled() {
    return currentFloor >= 0 && currentFloor <= 5;
  }
}
