import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;

  // ignore: use_super_parameters
  const SearchWidget({required this.onSearch, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _cityController = TextEditingController();

  void _search() {
    widget.onSearch(_cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: 'Enter city name',
            ),
          ),
        ),
        IconButton(
          onPressed: _search,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}
