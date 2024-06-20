import 'package:flutter/material.dart' show BorderRadius, BuildContext, Center, Colors, ElevatedButton, Icon, IconData, MainAxisAlignment, RoundedRectangleBorder, Row, SizedBox, State, StatefulWidget, VoidCallback, Widget;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/core/models/UserModel.dart';

class GenderSelectionRow extends StatefulWidget {
  final Gender selectedGender;
  final Function(Gender) onGenderSelected;

  const GenderSelectionRow({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  _GenderSelectionRowState createState() => _GenderSelectionRowState();
}

class _GenderSelectionRowState extends State<GenderSelectionRow> {
  late Gender _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.selectedGender;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _genderButton(
          gender: Gender.Male,
          icon: FontAwesomeIcons.mars,
          isSelected: _selectedGender == Gender.Male,
          onPressed: () {
            setState(() {
              _selectedGender = Gender.Male;
            });
            widget.onGenderSelected(Gender.Male);
          },
        ),
        _genderButton(
          gender: Gender.Female,
          icon: FontAwesomeIcons.venus,
          isSelected: _selectedGender == Gender.Female,
          onPressed: () {
            setState(() {
              _selectedGender = Gender.Female;
            });
            widget.onGenderSelected(Gender.Female);
          },
        ),
      ],
    );
  }

  Widget _genderButton({
    required Gender gender,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    const selectedColor = Colors.blue; // Color for selected button
    const defaultColor = Colors.grey; // Color for default button

    return SizedBox(
      width: 80.0,
      height: 80.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? selectedColor : defaultColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 40.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
