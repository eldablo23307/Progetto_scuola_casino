import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color primary = Color(0xFF1E1028);
const Color secondary = Color(0xFF593F62);
const Color accent = Color(0xFFA5C4D4);
const Color gold = Color(0xFFFFC857);
const String apiBaseUrl = 'http://127.0.0.1:5000';
const List<GameDefinition> casinoGames = [
  GameDefinition(
    title: 'Roulette',
    subtitle: 'Punta sul colore vincente',
    icon: Icons.radar_rounded,
    visual: GameVisual.roulette,
    colors: [Color(0xFFE53935), Color(0xFF111827)],
  ),
  GameDefinition(
    title: 'Ice Fishing',
    subtitle: 'Pesca bonus sotto il ghiaccio',
    icon: Icons.ac_unit_rounded,
    visual: GameVisual.iceFishing,
    colors: [Color(0xFF67E8F9), Color(0xFF1D4ED8)],
  ),
  GameDefinition(
    title: 'Slot Frutta',
    subtitle: 'Ciliegie, limoni e jackpot',
    icon: Icons.local_pizza_rounded,
    visual: GameVisual.fruitSlot,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFC857)],
  ),
  GameDefinition(
    title: 'Slot Cristalli',
    subtitle: 'Gemme rare e moltiplicatori',
    icon: Icons.diamond_rounded,
    visual: GameVisual.crystalSlot,
    colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
  ),
  GameDefinition(
    title: 'Slot Fulmini',
    subtitle: 'Giri turbo ad alta tensione',
    icon: Icons.bolt_rounded,
    visual: GameVisual.thunderSlot,
    colors: [Color(0xFF111827), Color(0xFFFACC15)],
  ),
];

enum GameVisual { roulette, iceFishing, fruitSlot, crystalSlot, thunderSlot }

class GameDefinition {
  const GameDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.visual,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final GameVisual visual;
  final List<Color> colors;
}

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
                  const BrandLogo(size: 92),
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
                        const Row(
                          children: [
                            BrandLogo(size: 42),
                            SizedBox(width: 12),
                            Text(
                              'Brawls Bets',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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
          'Giochi disponibili',
          style: TextStyle(
            color: accent.withValues(alpha: 0.86),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.builder(
            itemCount: casinoGames.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 920
                  ? 3
                  : MediaQuery.of(context).size.width > 560
                      ? 2
                      : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) => GameCard(game: casinoGames[index]),
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

class BrandLogo extends StatelessWidget {
  const BrandLogo({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gold, Color(0xFFFF7A45), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.24),
            blurRadius: size * 0.36,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.72,
          height: size * 0.72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.88),
            border: Border.all(color: Colors.white.withValues(alpha: 0.42), width: 1.2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.casino_rounded, color: gold, size: size * 0.42),
              Positioned(
                right: size * 0.12,
                bottom: size * 0.08,
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  const GameCard({required this.game, super.key});

  final GameDefinition game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            game.colors.first.withValues(alpha: 0.82),
            game.colors.last.withValues(alpha: 0.54),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: game.colors.first.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(game.icon, color: gold, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameArtwork extends StatelessWidget {
  const GameArtwork({required this.game, super.key});

  final GameDefinition game;

  @override
  Widget build(BuildContext context) {
    switch (game.visual) {
      case GameVisual.roulette:
        return const RouletteArtwork();
      case GameVisual.iceFishing:
        return const IceFishingArtwork();
      case GameVisual.fruitSlot:
        return const SlotArtwork(
          symbols: ['🍒', '🍋', '7'],
          panelColor: Color(0xFF7F1D1D),
          glowColor: Color(0xFFFFC857),
        );
      case GameVisual.crystalSlot:
        return const SlotArtwork(
          symbols: ['◆', '✦', '✧'],
          panelColor: Color(0xFF312E81),
          glowColor: Color(0xFF22D3EE),
        );
      case GameVisual.thunderSlot:
        return const SlotArtwork(
          symbols: ['⚡', '★', 'W'],
          panelColor: Color(0xFF111827),
          glowColor: Color(0xFFFACC15),
        );
    }
  }
}

class RouletteArtwork extends StatelessWidget {
  const RouletteArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -36,
          top: -34,
          child: Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.72),
              border: Border.all(color: gold, width: 10),
            ),
            child: Center(
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935).withValues(alpha: 0.92),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.74), width: 8),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: gold),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 22,
          top: 22,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              9,
              (index) => Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index.isEven ? Colors.redAccent : Colors.black87,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IceFishingArtwork extends StatelessWidget {
  const IceFishingArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 18,
          top: 20,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 8),
            ),
            child: const Center(
              child: Icon(Icons.water_rounded, color: Color(0xFF1D4ED8), size: 58),
            ),
          ),
        ),
        Positioned(
          left: 26,
          top: 18,
          child: Transform.rotate(
            angle: -0.55,
            child: Container(
              width: 7,
              height: 116,
              decoration: BoxDecoration(
                color: const Color(0xFF92400E),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
        Positioned(
          left: 94,
          top: 38,
          child: Container(width: 2, height: 72, color: Colors.white.withValues(alpha: 0.82)),
        ),
        Positioned(
          left: 62,
          top: 116,
          child: Icon(Icons.set_meal_rounded, color: gold.withValues(alpha: 0.92), size: 58),
        ),
        Positioned(
          left: -22,
          bottom: 42,
          child: Container(
            width: 180,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );
  }
}

class SlotArtwork extends StatelessWidget {
  const SlotArtwork({
    required this.symbols,
    required this.panelColor,
    required this.glowColor,
    super.key,
  });

  final List<String> symbols;
  final Color panelColor;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 18,
          top: 20,
          child: Container(
            width: 132,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: panelColor.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: glowColor.withValues(alpha: 0.76), width: 3),
              boxShadow: [
                BoxShadow(color: glowColor.withValues(alpha: 0.22), blurRadius: 30),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: symbols
                  .map(
                    (symbol) => Expanded(
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                              color: panelColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 54,
          child: Container(
            width: 16,
            height: 48,
            decoration: BoxDecoration(
              color: glowColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 26,
          child: Icon(Icons.auto_awesome_rounded, color: glowColor.withValues(alpha: 0.9), size: 42),
        ),
      ],
    );
  }
}
