import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color primary = Color(0xFF1E1028);
const Color secondary = Color(0xFF593F62);
const Color accent = Color(0xFFA5C4D4);
const Color gold = Color(0xFFFFC857);
const String apiBaseUrl = 'http://127.0.0.1:5000';

void main() {
  runApp(const MyApp());
}

class UserSession {
  const UserSession({
    required this.playerId,
    required this.name,
    required this.balance,
  });

  final int playerId;
  final String name;
  final double balance;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      playerId: (json['id_giocatore'] as num).toInt(),
      name: json['nome'] as String,
      balance: (json['bilancio'] as num).toDouble(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brawls Bets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: primary,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/MainApp': (context) => const MainApp(),
        '/Register': (context) => const Register(),
      },
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(
      title: 'Brawls Bets',
      subtitle: 'Accedi al tuo tavolo da gioco',
      child: LoginForm(),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, secondary],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.12),
                      border: Border.all(color: accent.withValues(alpha: 0.35)),
                    ),
                    child: const Icon(
                      Icons.casino_rounded,
                      color: gold,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.82),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<UserSession> sendData(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Credenziali non valide');
    }

    return UserSession.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final session = await sendData(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/MainApp', arguments: session);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Accesso non riuscito. Controlla email e password.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        StyledTextField(
          controller: emailController,
          hintText: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        StyledTextField(
          controller: passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Login',
          isLoading: isLoading,
          onPressed: login,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/Register'),
          child: const Text('Crea un nuovo account'),
        ),
      ],
    );
  }
}

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(
      title: 'Brawls Bets',
      subtitle: 'Registrati e ricevi subito il tuo saldo iniziale',
      child: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isSimulatedAccount = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<UserSession> sendData(
    String email,
    String password,
    String name,
    String surname,
    String address,
  ) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
        'account_type': isSimulatedAccount,
        'address': address,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Registrazione non riuscita');
    }

    return UserSession.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final session = await sendData(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
        surnameController.text.trim(),
        addressController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/MainApp', arguments: session);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Registrazione non riuscita. Verifica i dati inseriti.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        StyledTextField(
          controller: emailController,
          hintText: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        StyledTextField(
          controller: passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        StyledTextField(
          controller: nameController,
          hintText: 'Nome',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        StyledTextField(
          controller: surnameController,
          hintText: 'Cognome',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: gold,
          title: const Text('Account simulato'),
          subtitle: Text(
            'Saldo demo da 5000 crediti',
            style: TextStyle(color: accent.withValues(alpha: 0.75)),
          ),
          value: isSimulatedAccount,
          onChanged: (value) {
            setState(() {
              isSimulatedAccount = value;
            });
          },
        ),
        if (!isSimulatedAccount) ...[
          const SizedBox(height: 12),
          StyledTextField(
            controller: addressController,
            hintText: 'Wallet Address',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Registrati',
          isLoading: isLoading,
          onPressed: register,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hai già un account? Login'),
        ),
      ],
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class StyledTextField extends StatelessWidget {
  const StyledTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: accent),
        hintText: hintText,
        hintStyle: TextStyle(color: accent.withValues(alpha: 0.72)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: gold, width: 1.4),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<UserSession> userFuture;
  UserSession? initialSession;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserSession) {
      initialSession = args;
      userFuture = fetchUser(args.playerId);
    } else {
      userFuture = Future<UserSession>.error('Utente non trovato');
    }
  }

  Future<UserSession> fetchUser(int playerId) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/MainApp?id_giocatore=$playerId'),
    );

    if (response.statusCode != 200) {
      if (initialSession != null) {
        return initialSession!;
      }
      throw Exception('Dati utente non disponibili');
    }

    return UserSession.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, secondary],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<UserSession>(
            future: userFuture,
            initialData: initialSession,
            builder: (context, snapshot) {
              if (snapshot.hasError && snapshot.data == null) {
                return Center(
                  child: Text(
                    'Sessione non valida',
                    style: TextStyle(color: accent.withValues(alpha: 0.9)),
                  ),
                );
              }

              final session = snapshot.data;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Brawls Bets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (session == null)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Expanded(child: Dashboard(session: session)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({required this.session, super.key});

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bentornato,',
                style: TextStyle(color: accent.withValues(alpha: 0.82), fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                session.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  InfoPill(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Bilancio',
                    value: '${session.balance.toStringAsFixed(2)} crediti',
                  ),
                  InfoPill(
                    icon: Icons.confirmation_number_outlined,
                    label: 'ID Giocatore',
                    value: session.playerId.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Scegli una modalità',
          style: TextStyle(
            color: accent.withValues(alpha: 0.86),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 720 ? 3 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: const [
              GameCard(icon: Icons.casino_rounded, title: 'Slot'),
              GameCard(icon: Icons.style_rounded, title: 'Poker'),
              GameCard(icon: Icons.radar_rounded, title: 'Roulette'),
              GameCard(icon: Icons.emoji_events_rounded, title: 'Tornei'),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: accent.withValues(alpha: 0.72))),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  const GameCard({required this.icon, required this.title, super.key});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: gold, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
