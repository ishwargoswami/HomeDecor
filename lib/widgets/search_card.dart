import 'package:flutter/material.dart';

class SearchCard extends StatelessWidget {
  final TextEditingController _searchControl = new TextEditingController();
  final String hintText;
  final Function(String)? onChanged;

  SearchCard({
    this.hintText = "Search..",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: TextField(
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            hintText: hintText,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.black54,
              ),
              onPressed: () {
                _searchControl.clear();
                if (onChanged != null) {
                  onChanged!('');
                }
              },
            ),
            hintStyle: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
            ),
          ),
          maxLines: 1,
          controller: _searchControl,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: onChanged,
        ),
      ),
    );
  }
}
