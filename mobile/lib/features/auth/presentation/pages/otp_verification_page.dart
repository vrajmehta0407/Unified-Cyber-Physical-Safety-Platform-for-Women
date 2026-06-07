import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/otp_input_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  final String? mobile;
  const OtpVerificationPage({super.key, this.mobile});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mobile != null) {
      _mobileController.text = widget.mobile!;
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final mobile = _mobileController.text.trim();
    final otp = _otpController.text.trim();
    if (Validators.mobile(mobile) != null || Validators.otp(otp) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid mobile and 6-digit OTP')),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthOtpVerifyRequested(mobile: mobile, otp: otp));
  }

  void _sendOtp() {
    final mobile = _mobileController.text.trim();
    if (Validators.mobile(mobile) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid mobile number')),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthOtpResendRequested(mobile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthOtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent! Check backend logs in dev mode.')),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('Enter the 6-digit OTP sent to your mobile', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AuthTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.mobile,
                ),
                const SizedBox(height: 24),
                OtpInputWidget(controller: _otpController, onCompleted: (_) => _verify()),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _verify,
                    child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify & Login'),
                  ),
                ),
                TextButton(onPressed: loading ? null : _sendOtp, child: const Text('Resend OTP')),
              ],
            ),
          );
        },
      ),
    );
  }
}
