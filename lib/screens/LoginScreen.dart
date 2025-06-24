import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talentfarm/screens/SignupScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneNoController = TextEditingController();
  final pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isChecked=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFC852),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFC852),
        title: const Text('Login', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                // Full Name
                TextFormField(
                  controller: phoneNoController,
                  decoration: const InputDecoration(
                    labelText: 'Phone No',
                    border: OutlineInputBorder(),

                    filled: true,
                    fillColor: Colors.white, // ⬜ Field background
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your Phone no' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'Pin',
                    border: OutlineInputBorder(),

                    filled: true,
                    fillColor: Colors.white, // ⬜ Field background
                  ),
                  validator: (value) {
                    if (!isChecked && value!.isEmpty) {
                      return 'Enter your Pin';
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
                          if (isChecked) {

                          };
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isChecked = !isChecked;
                            if (isChecked) {

                            };
                          });

                        },
                        child:  Text(
                          'Pin Less Authentication',
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),

                    filled: true,
                    fillColor: Colors.white, // ⬜ Field background
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter your OTP' : null,
                ),
                SizedBox(height: 50,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //enter logic
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(height: 16,),
                Divider(
                  color: Colors.white,
                  thickness: 3,
                ),
                SizedBox(height: 16,),
                Text('First time user!!',style: TextStyle(color: Colors.black,fontSize: 18),),
                SizedBox(height: 16,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.to(()=>SignupScreen());
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
