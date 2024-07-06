import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/core/models/UserModel.dart';

class GenderSelectionRow extends StatefulWidget {
  final List<Gender> selectedGenders;
  final Function(List<Gender>) onGendersSelected;
  final bool allowMultipleSelection;
  final double size;

  const GenderSelectionRow({
    super.key,
    required this.selectedGenders,
    required this.onGendersSelected,
    this.allowMultipleSelection = false,
    this.size = 80.0,
  });

  @override
  _GenderSelectionRowState createState() => _GenderSelectionRowState();
}

class _GenderSelectionRowState extends State<GenderSelectionRow> {
  late List<Gender> _selectedGenders;

  @override
  void initState() {
    super.initState();
    _selectedGenders = widget.selectedGenders;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _genderButton(
          gender: Gender.Male,
          icon: FontAwesomeIcons.mars,
          isSelected: _selectedGenders.contains(Gender.Male),
          size: widget.size,
          onPressed: () {
            setState(() {
              if (widget.allowMultipleSelection) {
                if (_selectedGenders.contains(Gender.Male)) {
                  _selectedGenders.remove(Gender.Male);
                } else {
                  _selectedGenders.add(Gender.Male);
                }
              } else {
                _selectedGenders = [Gender.Male];
              }
            });
            widget.onGendersSelected(_selectedGenders);
          },
        ),
        const SizedBox(width: 10),
        _genderButton(
          gender: Gender.Female,
          icon: FontAwesomeIcons.venus,
          isSelected: _selectedGenders.contains(Gender.Female),
          size: widget.size,
          onPressed: () {
            setState(() {
              if (widget.allowMultipleSelection) {
                if (_selectedGenders.contains(Gender.Female)) {
                  _selectedGenders.remove(Gender.Female);
                } else {
                  _selectedGenders.add(Gender.Female);
                }
              } else {
                _selectedGenders = [Gender.Female];
              }
            });
            widget.onGendersSelected(_selectedGenders);
          },
        ),
      ],
    );
  }

  Widget _genderButton({
    required Gender gender,
    required IconData icon,
    required bool isSelected,
    required double size,
    required VoidCallback onPressed,
  }) {
    Color buttonColor = isSelected ? Colors.transparent : Colors.grey;
    LinearGradient? gradient = isSelected
        ? const LinearGradient(
      colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
