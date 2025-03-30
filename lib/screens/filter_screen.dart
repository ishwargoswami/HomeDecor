import 'package:flutter/material.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foodybite/util/const.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String _selectedRoom = "All";
  String _selectedStyle = "All";
  RangeValues _priceRange = RangeValues(0, 1000);
  List<String> _rooms = ["All", "Living Room", "Bedroom", "Kitchen", "Bathroom", "Office", "Dining Room", "Outdoor", "Other"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DecorProvider>(context, listen: false);
      setState(() {
        _selectedRoom = provider.selectedRoom;
        _selectedStyle = provider.selectedStyle;
        _priceRange = RangeValues(provider.minPrice, provider.maxPrice);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DecorProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter Items"),
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedRoom = "All";
                _selectedStyle = "All";
                _priceRange = RangeValues(0, 1000);
              });
            },
            child: Text(
              "Reset",
              style: TextStyle(color: Constants.lightAccent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Room"),
            SizedBox(height: 8.0),
            _buildRoomFilter(),
            SizedBox(height: 24.0),
            
            _buildSectionTitle("Style"),
            SizedBox(height: 8.0),
            _buildStyleFilter(provider),
            SizedBox(height: 24.0),
            
            _buildSectionTitle("Price Range"),
            SizedBox(height: 8.0),
            _buildPriceSlider(),
            SizedBox(height: 40.0),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Constants.lightAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Apply filters
                  provider.setRoomFilter(_selectedRoom);
                  provider.setStyleFilter(_selectedStyle);
                  provider.setPriceRange(_priceRange.start, _priceRange.end);
                  Navigator.pop(context);
                },
                child: Text(
                  "APPLY FILTERS",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRoomFilter() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _rooms.map((room) {
        return FilterChip(
          label: Text(room),
          selected: _selectedRoom == room,
          onSelected: (selected) {
            setState(() {
              _selectedRoom = selected ? room : "All";
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Constants.lightAccent.withOpacity(0.25),
          checkmarkColor: Constants.lightAccent,
          labelStyle: TextStyle(
            color: _selectedRoom == room ? Constants.lightAccent : Colors.black87,
            fontWeight: _selectedRoom == room ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStyleFilter(DecorProvider provider) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: ["All", ...provider.styles].map((style) {
        return FilterChip(
          label: Text(style),
          selected: _selectedStyle == style,
          onSelected: (selected) {
            setState(() {
              _selectedStyle = selected ? style : "All";
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Constants.lightAccent.withOpacity(0.25),
          checkmarkColor: Constants.lightAccent,
          labelStyle: TextStyle(
            color: _selectedStyle == style ? Constants.lightAccent : Colors.black87,
            fontWeight: _selectedStyle == style ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000,
          divisions: 10,
          activeColor: Constants.lightAccent,
          inactiveColor: Colors.grey[300],
          labels: RangeLabels(
            "\$${_priceRange.start.toStringAsFixed(0)}",
            "\$${_priceRange.end.toStringAsFixed(0)}",
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\$${_priceRange.start.toStringAsFixed(0)}"),
              Text("\$${_priceRange.end.toStringAsFixed(0)}"),
            ],
          ),
        ),
      ],
    );
  }
} 