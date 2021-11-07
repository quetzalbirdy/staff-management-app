import 'package:flutter/material.dart';
import 'package:wolf_jobs/globals.dart' as global;

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<int>) onSelectionChanged;
  final List<int> selectedItems;
  MultiSelectChip(
      this.selectedItems,
      this.reportList,
      {this.onSelectionChanged} 
      );  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {

  List<int> selectedChoices = List();  

  @override
  void initState() {    
    super.initState();   
    setState(() {
      selectedChoices = widget.selectedItems;
    });
  }  

   Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
  // String selectedChoice = "";  
  _buildChoiceList() {
    List<Widget> choices = List();    
    widget.reportList.asMap().forEach((index, item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)),),
          label: Text(item, style: TextStyle(fontSize: 16, fontFamily: 'Gotik'),),
          selectedColor: hexToColor(global.brand_color_secondary_action),
          selected: selectedChoices.contains(index),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(index)
                  ? selectedChoices.remove(index)
                  : selectedChoices.add(index);
              widget.onSelectionChanged(selectedChoices); 
            });
            print(selectedChoices);
          },
        ),
      ));
    });    
    return choices;
  }  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(        
        alignment: WrapAlignment.center,
        children: _buildChoiceList(),
      ),
    );
  }
}