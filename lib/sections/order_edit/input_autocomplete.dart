import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:transportumformanager/sections/order_edit/order_edit_api.dart';

class InputAutocomplete extends StatelessWidget {
  final String title;
  final String owner;
  final String field;
  final IconData icon;
  final TextEditingController controller;
  const InputAutocomplete(
      {Key key, this.title, this.owner, this.field, this.controller, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderEditAPI orderEditApi = OrderEditAPI();

    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
          autofocus: false,
          controller: controller,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
              labelText: title,
              labelStyle: TextStyle(
                  color: Colors.blue[900], fontSize: 16))),
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) return null;
        try {
          var response =
              await orderEditApi.getAutocomplete(pattern, owner, field);
          return List<dynamic>.from(response['items']);
        } catch (err) {
          return null;
        }
      },
      direction: AxisDirection.up,
      keepSuggestionsOnSuggestionSelected: false,
      hideOnError: true,
      hideOnLoading: true,
      hideOnEmpty: true,
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: icon != null ? Icon(icon) : null,
          title: Text(suggestion),
          dense: true,
        );
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion;
        //addressFromShort.text = suggestion;
        //setState(() {});
      },
    );
  }
}
