import 'package:amora/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildDatePickerField extends StatefulWidget {
  final String label;
  final String hintText;
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;

  const BuildDatePickerField({
    super.key,
    required this.label,
    required this.hintText,
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<BuildDatePickerField> createState() => _BuildDatePickerFieldState();
}

class _BuildDatePickerFieldState extends State<BuildDatePickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.initialDate != null) {
      _controller.text =
          "${widget.initialDate!.day}/${widget.initialDate!.month}/${widget.initialDate!.year}";
    }
  }

  @override
  void didUpdateWidget(covariant BuildDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate &&
        widget.initialDate != null) {
      _controller.text =
          "${widget.initialDate!.day}/${widget.initialDate!.month}/${widget.initialDate!.year}";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral,
          ),
        ),
        8.verticalSpace,
        TextField(
          controller: _controller,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }
}
