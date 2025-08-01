import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booking/utils/color_constants.dart';


class SearchField extends StatefulWidget {
  final double height;
  final Widget prefix;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? hintText;

  const SearchField({
    required this.height,
    this.prefix = const Icon(Icons.search, color: Colors.grey),
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.hintText = "Search",
    super.key,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.h,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
          helperStyle: TextStyle(),
          prefixIcon: widget.prefix,
          filled: true,
          fillColor: isFocused ? const Color(0xFFf5f5f5) : Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: isFocused
                  ? Color(0xff92A5B5)
                  : ColorConstants.containerBorder
                      // ignore: deprecated_member_use
                      .withOpacity(0.9), // adjust opacity
              width: 2, // border width
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: isFocused
                  ? Color(0xff92A5B5)
                  : ColorConstants.containerBorder
                      // ignore: deprecated_member_use
                      .withOpacity(0.9), // adjust opacity
              width: 2, // border width
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0.w),
            borderSide: BorderSide(
              // ignore: deprecated_member_use
              color: ColorConstants.containerBorder.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }
}