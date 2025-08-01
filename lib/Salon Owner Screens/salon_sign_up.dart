import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_up_controller.dart';
import 'package:salon_booking/Salon%20Owner%20Screens/salon_login.dart';
import 'package:salon_booking/login_screen.dart';

class SalonSignUp extends StatefulWidget {
  const SalonSignUp({super.key});

  @override
  State<SalonSignUp> createState() => _SalonSignUpState();
}

class _SalonSignUpState extends State<SalonSignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Top black and bottom white halves
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Color(0xffB5362D),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50.h),
                        Text(
                          'Sgin up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          width: 400.w, // Adjust width as needed
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            'New to SwiftTrim? Join us now to unlock personalized grooming experiences and exclusive offers',
                            maxLines: 3,
                            overflow:
                                TextOverflow
                                    .ellipsis, // Adds ... if text overflows
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 250.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "have account?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SalonLogin(),
                                    ),
                                  );
                                },
                                child: Text(
                                  " Sing In",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Center, big box overlapping the split
          Center(
            child: Container(
              height: 460.h,
              width: 320.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16.r,
                    spreadRadius: 4.r,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.h),
                  child: Form(
                    key: _formKey,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            border:
                                InputBorder.none, // removes the default border
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ), // underline when not focused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ), // underline when focused
                            ),
                            hintText: 'Name',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                            ), // optional: adjusts spacing
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }

                            return null;
                          },
                        ),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border:
                                InputBorder.none, // removes the default border
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ), // underline when not focused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.w,
                              ), // underline when focused
                            ),
                            hintText: 'Email',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                            ), // optional: adjusts spacing
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }

                            // basic email validation
                            if (!RegExp(
                              r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                            border:
                                InputBorder.none, // removes the default border
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ), // underline when not focused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.w,
                              ), // underline when focused
                            ),
                            hintText: 'Phone number',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                            ), // optional: adjusts spacing
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your number';
                            }

                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border:
                                InputBorder.none, // removes the default border
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ), // underline when not focused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.w,
                              ), // underline when focused
                            ),
                            hintText: 'password',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                            ), // optional: adjusts spacing
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 6) {
                              return 'password must be at least 6 charecter';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            border:
                                InputBorder.none, // removes the default border
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ), // underline when not focused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.w,
                              ), // underline when focused
                            ),
                            hintText: 'Confirm password',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                            ), // optional: adjusts spacing
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "password does'nt match";
                            }

                            return null;
                          },
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value ?? false;
                                });
                              },
                            ),
                            Text("Remember me"),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        InkWell(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              final signUpCtrl =
                                  context.read<SignUpController>();
                              await signUpCtrl.onRegistration(
                                email: _emailController.text,
                                password: _passwordController.text,
                                context: context,
                              );
                              // Check: If registration failed, don't proceed
                              if (FirebaseAuth.instance.currentUser != null) {
                                await signUpCtrl.onAddProfile(
                                  name: _nameController.text,
                                  role: "owner",
                                  phn: _phoneNumberController.text,
                                  context: context,
                                );
                              }
                            }
                          },
                          child:
                              context.watch<SignUpController>().isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Container(
                                    height: 45.h,
                                    width: 250.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),

                                      color: Color(0xffB5362D),
                                    ),

                                    child: Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
