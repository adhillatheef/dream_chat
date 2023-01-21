import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String? _userEmail;
  String? _userName;
  String? _userPassword;
  File? _pickedImage;

  pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    !_isLogin
                        ? InkWell(
                            onTap: pickImage,
                            child: CircleAvatar(
                              backgroundImage: _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : null,
                              radius: 40,
                              child: _pickedImage == null
                                  ? const Icon(Icons.add_a_photo_outlined)
                                  : null,
                            ))
                        : const SizedBox(),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      onSaved: (value) {
                        setState(() {
                          _userEmail = value!;
                        });
                      },
                    ),
                    !_isLogin
                        ? TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return 'Password enter at least 4 characters';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'User Name',
                            ),
                            onSaved: (value) {
                              setState(() {
                                _userName = value!;
                              });
                            },
                          )
                        : const SizedBox(),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      onSaved: (value) {
                        setState(() {
                          _userPassword = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                        onPressed: submit,
                        child: Text(_isLogin ? 'Login' : 'Signup')),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'I already have an account'))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  submit()async{
    final isValid = formKey.currentState?.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text('Please pick an image')));
      return;
    }
    UserCredential userCredential;
    if(isValid != null){
      if(isValid){
        formKey.currentState?.save();
        try {
          if (_isLogin) {
            userCredential = await _auth.signInWithEmailAndPassword(
                email: _userEmail!, password: _userPassword!);
          } else {
            userCredential = await _auth.createUserWithEmailAndPassword(
                email: _userEmail!, password: _userPassword!);

            ///.......image upload begins here........
            final ref = FirebaseStorage.instance
                .ref()
                .child('user_images')
                .child('${userCredential.user!.uid}.jpg');
            await ref.putFile(_pickedImage!).whenComplete(() async {
              final url = await ref.getDownloadURL();
              if (userCredential.user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set({
                  'userName': _userName,
                  'email': _userEmail,
                  'image_url': url,
                });
              }
            });
          }
        } on FirebaseAuthException catch (error) {
          String? errorMessage =
              'An error occurred. Please check your credentials.';
          if (error.message != null) {
            errorMessage = error.message;
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(errorMessage!),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } catch (error) {
          debugPrint(error.toString());
        }
      }
    }

  }
}
