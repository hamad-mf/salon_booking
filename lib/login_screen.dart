import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_in_controller.dart';
import 'package:salon_booking/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isChecked = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
                  color: Color(0xff1E2676),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          width: 400, // Adjust width as needed
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'If you are a returning user, access your account and continue your grooming journey seamlessly',
                            maxLines: 3,
                            overflow:
                                TextOverflow
                                    .ellipsis, // Adds ... if text overflows
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child:
                    context.watch<SignInController>().isLoadingG
                        ? Center(child: CircularProgressIndicator())
                        : InkWell(
                          onTap: () {
                            context.read<SignInController>().signInWithGoogle(
                              context,
                            );
                          },
                          child: Container(
                            color: Colors.white,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // SizedBox(height: 100),
                                  // Text(
                                  //   'Login with',
                                  //   style: TextStyle(
                                  //     color: Colors.black,
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  // SizedBox(height: 10),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //     horizontal: 10,
                                  //     vertical: 5,
                                  //   ),
                                  //   height: 35,
                                  //   width: 200,
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(12),
                                  //     color: Color(0xffE8E9E9),
                                  //   ),

                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.center,
                                  //     children: [
                                  //       Image.asset('assets/google_logo.png'),
                                  //       Text(
                                  //         "Sign in with google",
                                  //         style: TextStyle(
                                  //           color: Colors.black,
                                  //           fontWeight: FontWeight.w500,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  SizedBox(height: 70),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "New user?",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => SignUpScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          " Create account",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
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
              height: 270,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                width: 2,
                              ), // underline when focused
                            ),
                            hintText: 'Email',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                            ), // optional: adjusts spacing
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter you email';
                            }
                            // Basic email format validation
                            if (!RegExp(
                              r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
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
                                width: 2,
                              ), // underline when focused
                            ),
                            hintText: 'Password',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                            ), // optional: adjusts spacing
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
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
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<SignInController>().onLogin(
                                email: _emailController.text,
                                password: _passwordController.text,
                                context: context,
                              );
                              _emailController.clear();
                              _passwordController.clear();
                            }
                          },
                          child:
                              context.watch<SignInController>().isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Container(
                                    height: 45,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),

                                      color: Color(0xff1E2676),
                                    ),

                                    child: Center(
                                      child: Text(
                                        "Log in",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                        SizedBox(height: 10),
                        Center(child: Text("Forgot your password")),
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
