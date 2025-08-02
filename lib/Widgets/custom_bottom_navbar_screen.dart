import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:salon_booking/find_haircut_screen.dart';
import 'package:salon_booking/home_screen.dart';
import 'package:salon_booking/map_screen.dart';
import 'package:salon_booking/profile_screen.dart';

class CustomBottomNavbarScreen extends StatefulWidget {
  const CustomBottomNavbarScreen({super.key});

  @override
  State<CustomBottomNavbarScreen> createState() =>
      _CustomBottomNavbarScreenState();
}

class _CustomBottomNavbarScreenState extends State<CustomBottomNavbarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    MapScreen(),
    FindHaircutScreen(),
    ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'selectedIcon': Icons.home,
      'unselectedIcon': Icons.home_outlined,
      'label': 'Home',
    },
    {
      'selectedIcon': Icons.pin_drop,
      'unselectedIcon': Icons.pin_drop_outlined,
      'label': 'Location',
    },
    {
      'selectedIcon': Icons.face,
      'unselectedIcon': Icons.face_outlined,
      'label': 'Find Cut',
    },
    {
      'selectedIcon': Icons.person,
      'unselectedIcon': Icons.person_outline,
      'label': 'Person',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.r)],
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            bool isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = index);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
                decoration:
                    isSelected
                        ? BoxDecoration(
                          color: const Color(0xff1E2676),
                          borderRadius: BorderRadius.circular(12.r),
                        )
                        : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? _navItems[index]['selectedIcon']
                          : _navItems[index]['unselectedIcon'],
                      color: isSelected ? Colors.white : Colors.black,
                    ),

                    SizedBox(height: 4.h),
                    Text(
                      _navItems[index]['label'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
