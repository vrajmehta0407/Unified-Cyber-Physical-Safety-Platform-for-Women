import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = state is AuthAuthenticated ? state.user.name : 'Guest';
          return ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(userName),
                subtitle: state is AuthAuthenticated ? Text(state.user.mobile) : null,
              ),
              const Divider(),
              ListTile(leading: const Icon(Icons.language), title: const Text('Language'), subtitle: const Text('English'), onTap: () {}),
              ListTile(leading: const Icon(Icons.contacts), title: const Text('Emergency Guardians'), onTap: () => context.push('/guardians')),
              ListTile(leading: const Icon(Icons.watch), title: const Text('Connected Devices'), onTap: () => context.push('/devices')),
              ListTile(leading: const Icon(Icons.notifications), title: const Text('Notifications')),
              ListTile(leading: const Icon(Icons.privacy_tip), title: const Text('Privacy & Security')),
              ListTile(leading: const Icon(Icons.verified), title: const Text('Blockchain Verification'), onTap: () => context.push('/blockchain')),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text('Logout', style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
