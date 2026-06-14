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
  final String? devOtp;
  const OtpVerificationPage({super.key, this.mobile, this.devOtp});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  String? _displayedDevOtp;

  @override
  void initState() {
    super.initState();
    if (widget.mobile != null) {
      _mobileController.text = widget.mobile!;
    }
    _displayedDevOtp = widget.devOtp;
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
            setState(() => _displayedDevOtp = state.devOtp);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.devOtp != null
                    ? 'OTP sent via SMS to your phone! Code: ${state.devOtp}'
                    : 'OTP sent via SMS!'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'OTP has been sent via SMS to your mobile number.\nPlease check your messages.',
                  textAlign: TextAlign.center,
                ),
                // ── SMS OTP Banner ──────────────────────────────────
                if (_displayedDevOtp != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800.withOpacity(0.15),
                      border: Border.all(color: Colors.green.shade600),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sms_outlined, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SMS Verification Code',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _displayedDevOtp!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Also sent to your phone via SMS',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.green, size: 20),
                          tooltip: 'Copy OTP',
                          onPressed: () {
                            _otpController.text = _displayedDevOtp!;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                // ────────────────────────────────────────────────────
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
                TextButton.icon(
                  onPressed: loading ? null : _sendOtp,
                  icon: const Icon(Icons.sms_outlined, size: 18),
                  label: const Text('Resend OTP via SMS'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
