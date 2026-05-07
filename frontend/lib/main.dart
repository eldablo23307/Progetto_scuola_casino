import 'dart:convert';
import 'dart:math' as math;

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
    apiPath: '/games/roulette/play',
    imageUrl: 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?auto=format&fit=crop&w=900&q=80',
    choices: [
      GameChoice(label: 'Rosso', value: 'red'),
      GameChoice(label: 'Nero', value: 'black'),
      GameChoice(label: 'Verde', value: 'green'),
    ],
    colors: [Color(0xFFE53935), Color(0xFF111827)],
  ),
  GameDefinition(
    title: 'Ice Fishing',
    subtitle: 'Ruota, bonus e pesca sotto il ghiaccio',
    icon: Icons.ac_unit_rounded,
    visual: GameVisual.iceFishing,
    apiPath: '/games/ice-fishing/play',
    imageUrl: 'https://images.unsplash.com/photo-1517783999520-f068d7431a60?auto=format&fit=crop&w=900&q=80',
    choices: [
      GameChoice(label: '1x', value: '1x'),
      GameChoice(label: '2x', value: '2x'),
      GameChoice(label: '5x', value: '5x'),
      GameChoice(label: '10x', value: '10x'),
      GameChoice(label: 'Coin Flip', value: 'coin_flip'),
      GameChoice(label: 'Pachinko', value: 'pachinko'),
      GameChoice(label: 'Ice Bonus', value: 'ice_bonus'),
    ],
    colors: [Color(0xFF67E8F9), Color(0xFF1D4ED8)],
  ),
  GameDefinition(
    title: 'Slot Frutta',
    subtitle: 'Ciliegie, limoni e jackpot',
    icon: Icons.local_pizza_rounded,
    visual: GameVisual.fruitSlot,
    apiPath: '/games/slots/fruit/play',
    imageUrl: 'https://images.unsplash.com/photo-1576804845416-d8565f0601c9?auto=format&fit=crop&w=900&q=80',
    colors: [Color(0xFFFF6B6B), Color(0xFFFFC857)],
  ),
  GameDefinition(
    title: 'Slot Cristalli',
    subtitle: 'Gemme rare e moltiplicatori',
    icon: Icons.diamond_rounded,
    visual: GameVisual.crystalSlot,
    apiPath: '/games/slots/crystal/play',
    imageUrl: 'https://images.unsplash.com/photo-1519638399535-1b036603ac77?auto=format&fit=crop&w=900&q=80',
    colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
  ),
  GameDefinition(
    title: 'Slot Fulmini',
    subtitle: 'Giri turbo ad alta tensione',
    icon: Icons.bolt_rounded,
    visual: GameVisual.thunderSlot,
    apiPath: '/games/slots/thunder/play',
    imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    colors: [Color(0xFF111827), Color(0xFFFACC15)],
  ),
];

enum GameVisual { roulette, iceFishing, fruitSlot, crystalSlot, thunderSlot }

class GameChoice {
  const GameChoice({required this.label, required this.value});

  final String label;
  final String value;
}

class GameDefinition {
  const GameDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.visual,
    required this.apiPath,
    required this.imageUrl,
    required this.colors,
    this.choices = const [],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final GameVisual visual;
  final String apiPath;
  final String imageUrl;
  final List<Color> colors;
  final List<GameChoice> choices;

  bool get needsChoice => choices.isNotEmpty;
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

  UserSession copyWith({double? balance}) {
    return UserSession(
      playerId: playerId,
      name: name,
      balance: balance ?? this.balance,
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
  bool hasLoadedArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hasLoadedArguments) return;
    hasLoadedArguments = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserSession) {
      initialSession = args;
      userFuture = fetchUser(args.playerId);
    } else {
      userFuture = Future<UserSession>.error('Utente non trovato');
    }
  }

  void updateSession(UserSession session) {
    setState(() {
      initialSession = session;
      userFuture = Future<UserSession>.value(session);
    });
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
                      Expanded(child: Dashboard(session: session, onSessionChanged: updateSession)),
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
  const Dashboard({required this.session, required this.onSessionChanged, super.key});

  final UserSession session;
  final ValueChanged<UserSession> onSessionChanged;

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
            itemBuilder: (context, index) => GameCard(game: casinoGames[index], session: session, onSessionChanged: onSessionChanged),
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
  const GameCard({required this.game, required this.session, required this.onSessionChanged, super.key});

  final GameDefinition game;
  final UserSession session;
  final ValueChanged<UserSession> onSessionChanged;

  Future<void> openGame(BuildContext context) async {
    final updatedSession = await Navigator.of(context).push<UserSession>(
      MaterialPageRoute(
        builder: (_) => GamePlayPage(game: game, session: session),
      ),
    );
    if (updatedSession != null) {
      onSessionChanged(updatedSession);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openGame(context),
      child: Container(
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
            Positioned.fill(
              child: Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => GameArtwork(game: game),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withValues(alpha: 0.18),
                      game.colors.last.withValues(alpha: 0.42),
                      primary.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
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
    ),
    );
  }
}


class GameOutcome {
  const GameOutcome({
    required this.game,
    required this.bet,
    required this.payout,
    required this.profit,
    required this.balance,
    required this.message,
    required this.result,
  });

  final String game;
  final double bet;
  final double payout;
  final double profit;
  final double balance;
  final String message;
  final Map<String, dynamic> result;

  factory GameOutcome.fromJson(Map<String, dynamic> json) {
    return GameOutcome(
      game: json['game'] as String,
      bet: (json['bet'] as num).toDouble(),
      payout: (json['payout'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      message: json['message'] as String,
      result: (json['result'] as Map<String, dynamic>?) ?? {},
    );
  }
}

class GamePlayPage extends StatefulWidget {
  const GamePlayPage({required this.game, required this.session, super.key});

  final GameDefinition game;
  final UserSession session;

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> with SingleTickerProviderStateMixin {
  final TextEditingController betController = TextEditingController(text: '50');
  late UserSession session;
  String? selectedChoice;
  bool isPlaying = false;
  String? errorMessage;
  GameOutcome? outcome;
  late final AnimationController playAnimationController;

  @override
  void initState() {
    super.initState();
    playAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    session = widget.session;
    if (widget.game.choices.isNotEmpty) {
      selectedChoice = widget.game.choices.first.value;
    }
  }

  @override
  void dispose() {
    playAnimationController.dispose();
    betController.dispose();
    super.dispose();
  }

  Future<void> play() async {
    final bet = double.tryParse(betController.text.replaceAll(',', '.'));
    if (bet == null || bet <= 0) {
      setState(() => errorMessage = 'Inserisci una puntata valida.');
      return;
    }

    setState(() {
      isPlaying = true;
      errorMessage = null;
      outcome = null;
    });
    playAnimationController.repeat();

    try {
      final body = <String, Object>{
        'id_giocatore': session.playerId,
        'bet': bet,
        if (widget.game.needsChoice) 'choice': selectedChoice ?? '',
      };
      final response = await http.post(
        Uri.parse('$apiBaseUrl${widget.game.apiPath}'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Giocata non riuscita');
      }

      final played = GameOutcome.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      setState(() {
        outcome = played;
        session = session.copyWith(balance: played.balance);
      });
    } catch (_) {
      setState(() {
        errorMessage = 'Giocata non riuscita: controlla saldo, puntata e backend.';
      });
    } finally {
      playAnimationController.stop();
      if (mounted) {
        playAnimationController.forward(from: 0);
        setState(() => isPlaying = false);
      }
    }
  }

  void closeWithSession() {
    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) closeWithSession();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, widget.game.colors.last.withValues(alpha: 0.74)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: closeWithSession,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.game.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 860;
                      final gamePanel = GameHeroPanel(
                        game: widget.game,
                        outcome: outcome,
                        isPlaying: isPlaying,
                        animation: playAnimationController,
                      );
                      final controls = GameControls(
                        game: widget.game,
                        session: session,
                        betController: betController,
                        selectedChoice: selectedChoice,
                        outcome: outcome,
                        errorMessage: errorMessage,
                        isPlaying: isPlaying,
                        onChoiceSelected: (choice) => setState(() => selectedChoice = choice),
                        onPlay: play,
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: gamePanel),
                            const SizedBox(width: 22),
                            Expanded(flex: 4, child: controls),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          gamePanel,
                          const SizedBox(height: 18),
                          controls,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameHeroPanel extends StatelessWidget {
  const GameHeroPanel({
    required this.game,
    required this.outcome,
    required this.isPlaying,
    required this.animation,
    super.key,
  });

  final GameDefinition game;
  final GameOutcome? outcome;
  final bool isPlaying;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [BoxShadow(color: game.colors.first.withValues(alpha: 0.22), blurRadius: 36)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => GameArtwork(game: game),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.18), primary.withValues(alpha: 0.9)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedGameStage(
                game: game,
                outcome: outcome,
                isPlaying: isPlaying,
                animation: animation,
              ),
            ),
            if (game.visual == GameVisual.iceFishing)
              Positioned(
                right: 26,
                top: 28,
                child: IceWheel(
                  outcome: outcome,
                  isPlaying: isPlaying,
                  animation: animation,
                ),
              ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.subtitle,
                    style: TextStyle(color: accent.withValues(alpha: 0.86), fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    outcome?.message ?? 'Scegli la puntata e premi Gioca.',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
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

class GameControls extends StatelessWidget {
  const GameControls({
    required this.game,
    required this.session,
    required this.betController,
    required this.selectedChoice,
    required this.outcome,
    required this.errorMessage,
    required this.isPlaying,
    required this.onChoiceSelected,
    required this.onPlay,
    super.key,
  });

  final GameDefinition game;
  final UserSession session;
  final TextEditingController betController;
  final String? selectedChoice;
  final GameOutcome? outcome;
  final String? errorMessage;
  final bool isPlaying;
  final ValueChanged<String> onChoiceSelected;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        InfoPill(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Saldo attuale',
          value: '${session.balance.toStringAsFixed(2)} crediti',
        ),
        const SizedBox(height: 18),
        StyledTextField(
          controller: betController,
          hintText: 'Puntata',
          icon: Icons.paid_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (game.choices.isNotEmpty) ...[
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              game.visual == GameVisual.iceFishing ? 'Punta sul settore della ruota' : 'Scegli una giocata',
              style: TextStyle(color: accent.withValues(alpha: 0.82), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.choices.map((choice) {
              final selected = choice.value == selectedChoice;
              return ChoiceChip(
                selected: selected,
                label: Text(choice.label),
                selectedColor: gold,
                labelStyle: TextStyle(color: selected ? primary : Colors.white, fontWeight: FontWeight.w800),
                onSelected: (_) => onChoiceSelected(choice.value),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 22),
        PrimaryButton(label: 'Gioca', isLoading: isPlaying, onPressed: onPlay),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        if (outcome != null) ...[
          const SizedBox(height: 20),
          OutcomeCard(outcome: outcome!),
        ],
      ],
    );
  }
}

class OutcomeCard extends StatelessWidget {
  const OutcomeCard({required this.outcome, super.key});

  final GameOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final positive = outcome.profit >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (positive ? gold : Colors.redAccent).withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(outcome.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MiniStat(label: 'Puntata', value: outcome.bet.toStringAsFixed(2)),
              MiniStat(label: 'Vincita', value: outcome.payout.toStringAsFixed(2)),
              MiniStat(label: 'Profitto', value: outcome.profit.toStringAsFixed(2), highlight: positive),
            ],
          ),
          const SizedBox(height: 12),
          Text(_details(outcome.result), style: TextStyle(color: accent.withValues(alpha: 0.82))),
        ],
      ),
    );
  }

  String _details(Map<String, dynamic> result) {
    if (result.containsKey('reels')) {
      return "Rulli: ${(result['reels'] as List).join('  ')}";
    }
    if (result.containsKey('number')) {
      return "Numero: ${result['number']} - Colore: ${result['color']}";
    }
    if (result.containsKey('segmentLabel')) {
      final bonus = result['bonus'] as Map<String, dynamic>?;
      return bonus == null
          ? "Settore: ${result['segmentLabel']} - Moltiplicatore: ${result['multiplier']}x"
          : "Settore: ${result['segmentLabel']} - ${bonus['label']} (${bonus['multiplier']}x)";
    }
    return 'Risultato registrato.';
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({required this.label, required this.value, this.highlight = false, super.key});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accent.withValues(alpha: 0.72), fontSize: 12)),
          Text(value, style: TextStyle(color: highlight ? gold : Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class IceWheel extends StatelessWidget {
  const IceWheel({
    required this.outcome,
    required this.isPlaying,
    required this.animation,
    super.key,
  });

  final GameOutcome? outcome;
  final bool isPlaying;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final segment = outcome?.result['segment'] as String?;
    return SizedBox(
      width: 210,
      height: 210,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final turns = isPlaying ? animation.value * math.pi * 10 : animation.value * math.pi * 2;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: turns,
                child: CustomPaint(size: const Size.square(210), painter: IceWheelPainter(segment)),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.9),
                  border: Border.all(color: gold, width: 3),
                ),
                child: const Icon(Icons.ac_unit_rounded, color: gold, size: 34),
              ),
              const Positioned(top: 0, child: Icon(Icons.arrow_drop_down_rounded, color: gold, size: 44)),
            ],
          );
        },
      ),
    );
  }
}

class IceWheelPainter extends CustomPainter {
  IceWheelPainter(this.selectedSegment);

  final String? selectedSegment;
  final List<String> labels = const ['1x', '2x', '5x', '10x', 'Flip', 'Pach', 'Bonus'];
  final List<String> keys = const ['1x', '2x', '5x', '10x', 'coin_flip', 'pachinko', 'ice_bonus'];
  final List<Color> colors = const [
    Color(0xFFBAE6FD),
    Color(0xFF38BDF8),
    Color(0xFF2563EB),
    Color(0xFF1E3A8A),
    Color(0xFFFACC15),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = math.pi * 2 / labels.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    for (var i = 0; i < labels.length; i++) {
      final paint = Paint()..color = colors[i].withValues(alpha: keys[i] == selectedSegment ? 1 : 0.86);
      canvas.drawArc(rect, -math.pi / 2 + (i * sweep), sweep, true, paint);
      final labelAngle = -math.pi / 2 + (i * sweep) + sweep / 2;
      final labelOffset = Offset(center.dx + math.cos(labelAngle) * radius * 0.66, center.dy + math.sin(labelAngle) * radius * 0.66);
      textPainter.text = TextSpan(text: labels[i], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900));
      textPainter.layout();
      textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    canvas.drawCircle(center, radius - 2, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = Colors.white.withValues(alpha: 0.76));
  }

  @override
  bool shouldRepaint(covariant IceWheelPainter oldDelegate) => oldDelegate.selectedSegment != selectedSegment;
}


class AnimatedGameStage extends StatelessWidget {
  const AnimatedGameStage({
    required this.game,
    required this.outcome,
    required this.isPlaying,
    required this.animation,
    super.key,
  });

  final GameDefinition game;
  final GameOutcome? outcome;
  final bool isPlaying;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    switch (game.visual) {
      case GameVisual.roulette:
        return AnimatedRouletteStage(
          game: game,
          outcome: outcome,
          isPlaying: isPlaying,
          animation: animation,
        );
      case GameVisual.iceFishing:
        return AnimatedIceFishingStage(
          game: game,
          isPlaying: isPlaying,
          animation: animation,
        );
      case GameVisual.fruitSlot:
      case GameVisual.crystalSlot:
      case GameVisual.thunderSlot:
        return AnimatedSlotStage(
          game: game,
          outcome: outcome,
          isPlaying: isPlaying,
          animation: animation,
        );
    }
  }
}

class AnimatedRouletteStage extends StatelessWidget {
  const AnimatedRouletteStage({
    required this.game,
    required this.outcome,
    required this.isPlaying,
    required this.animation,
    super.key,
  });

  final GameDefinition game;
  final GameOutcome? outcome;
  final bool isPlaying;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final ballAngle = (progress * math.pi * (isPlaying ? 16 : 2)) - math.pi / 2;
        final ballRadius = isPlaying ? 96.0 : 76.0;
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned(
              right: 18,
              top: 18,
              child: Transform.rotate(
                angle: progress * math.pi * (isPlaying ? 14 : 2),
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withValues(alpha: 0.92), width: 8),
                    gradient: SweepGradient(
                      colors: [
                        Colors.redAccent,
                        Colors.black87,
                        Colors.redAccent,
                        Colors.black87,
                        const Color(0xFF16A34A),
                        Colors.redAccent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 18 + 115 + (math.cos(ballAngle) * ballRadius) - 8,
              top: 18 + 115 + (math.sin(ballAngle) * ballRadius) - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.9), blurRadius: 14)],
                ),
              ),
            ),
            if (outcome != null)
              Positioned(
                right: 92,
                top: 94,
                child: ResultBadge(text: '${outcome!.result['number']}'),
              ),
          ],
        );
      },
    );
  }
}

class AnimatedIceFishingStage extends StatelessWidget {
  const AnimatedIceFishingStage({
    required this.game,
    required this.isPlaying,
    required this.animation,
    super.key,
  });

  final GameDefinition game;
  final bool isPlaying;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final bob = math.sin(animation.value * math.pi * 2) * (isPlaying ? 16 : 5);
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            for (var i = 0; i < 18; i++)
              Positioned(
                left: 18.0 + (i * 43 % 340),
                top: ((animation.value * 180) + i * 31) % 520,
                child: Icon(Icons.ac_unit_rounded, color: Colors.white.withValues(alpha: 0.34), size: 12 + (i % 4) * 3),
              ),
            Positioned(
              left: 88,
              top: 34 + bob,
              child: Transform.rotate(
                angle: -0.42 + math.sin(animation.value * math.pi * 2) * 0.08,
                child: Container(
                  width: 9,
                  height: 128,
                  decoration: BoxDecoration(
                    color: const Color(0xFF92400E),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.28), blurRadius: 12)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 178,
              top: 156 + (bob * 0.7),
              child: Icon(Icons.set_meal_rounded, color: const Color(0xFF67E8F9).withValues(alpha: 0.95), size: 58),
            ),
          ],
        );
      },
    );
  }
}

class AnimatedSlotStage extends StatelessWidget {
  const AnimatedSlotStage({
    required this.game,
    required this.outcome,
    required this.isPlaying,
    required this.animation,
    super.key,
  });

  final GameDefinition game;
  final GameOutcome? outcome;
  final bool isPlaying;
  final Animation<double> animation;

  List<String> get fallbackSymbols {
    switch (game.visual) {
      case GameVisual.fruitSlot:
        return ['🍒', '🍋', '7'];
      case GameVisual.crystalSlot:
        return ['◆', '✦', '✧'];
      case GameVisual.thunderSlot:
        return ['⚡', '★', 'W'];
      case GameVisual.roulette:
      case GameVisual.iceFishing:
        return ['?', '?', '?'];
    }
  }

  Color get panelColor {
    switch (game.visual) {
      case GameVisual.fruitSlot:
        return const Color(0xFF7F1D1D);
      case GameVisual.crystalSlot:
        return const Color(0xFF312E81);
      case GameVisual.thunderSlot:
        return const Color(0xFF111827);
      case GameVisual.roulette:
      case GameVisual.iceFishing:
        return primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reels = (outcome?.result['reels'] as List?)?.map((value) => value.toString()).toList() ?? fallbackSymbols;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned(
              right: 34,
              top: 46,
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: gold.withValues(alpha: 0.76), width: 4),
                  boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.26), blurRadius: 34)],
                ),
                child: Row(
                  children: List.generate(3, (index) {
                    final spinOffset = isPlaying ? math.sin((animation.value * math.pi * 8) + index) * 18 : 0.0;
                    final symbol = isPlaying ? fallbackSymbols[(index + (animation.value * 10).floor()) % fallbackSymbols.length] : reels[index];
                    return Expanded(
                      child: Transform.translate(
                        offset: Offset(0, spinOffset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          height: 118,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              symbol,
                              style: TextStyle(color: panelColor, fontSize: 36, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: 96,
              child: Transform.rotate(
                angle: isPlaying ? math.sin(animation.value * math.pi * 2) * 0.32 : 0,
                child: Container(
                  width: 18,
                  height: 70,
                  decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(99)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ResultBadge extends StatelessWidget {
  const ResultBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 4),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.42), blurRadius: 24)],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class GamePlayPage extends StatefulWidget {
  const GamePlayPage({required this.game, required this.session, super.key});

  final GameDefinition game;
  final UserSession session;

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  final TextEditingController betController = TextEditingController(text: '50');
  late UserSession session;
  String? selectedChoice;
  bool isPlaying = false;
  String? errorMessage;
  GameOutcome? outcome;

  @override
  void initState() {
    super.initState();
    session = widget.session;
    if (widget.game.choices.isNotEmpty) {
      selectedChoice = widget.game.choices.first.value;
    }
  }

  @override
  void dispose() {
    betController.dispose();
    super.dispose();
  }

  Future<void> play() async {
    final bet = double.tryParse(betController.text.replaceAll(',', '.'));
    if (bet == null || bet <= 0) {
      setState(() => errorMessage = 'Inserisci una puntata valida.');
      return;
    }

    setState(() {
      isPlaying = true;
      errorMessage = null;
    });

    try {
      final body = <String, Object>{
        'id_giocatore': session.playerId,
        'bet': bet,
        if (widget.game.needsChoice) 'choice': selectedChoice ?? '',
      };
      final response = await http.post(
        Uri.parse('$apiBaseUrl${widget.game.apiPath}'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Giocata non riuscita');
      }

      final played = GameOutcome.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      setState(() {
        outcome = played;
        session = session.copyWith(balance: played.balance);
      });
    } catch (_) {
      setState(() {
        errorMessage = 'Giocata non riuscita: controlla saldo, puntata e backend.';
      });
    } finally {
      if (mounted) {
        setState(() => isPlaying = false);
      }
    }
  }

  void closeWithSession() {
    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) closeWithSession();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, widget.game.colors.last.withValues(alpha: 0.74)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: closeWithSession,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.game.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 860;
                      final gamePanel = GameHeroPanel(game: widget.game, outcome: outcome);
                      final controls = GameControls(
                        game: widget.game,
                        session: session,
                        betController: betController,
                        selectedChoice: selectedChoice,
                        outcome: outcome,
                        errorMessage: errorMessage,
                        isPlaying: isPlaying,
                        onChoiceSelected: (choice) => setState(() => selectedChoice = choice),
                        onPlay: play,
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: gamePanel),
                            const SizedBox(width: 22),
                            Expanded(flex: 4, child: controls),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          gamePanel,
                          const SizedBox(height: 18),
                          controls,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameHeroPanel extends StatelessWidget {
  const GameHeroPanel({required this.game, required this.outcome, super.key});

  final GameDefinition game;
  final GameOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [BoxShadow(color: game.colors.first.withValues(alpha: 0.22), blurRadius: 36)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => GameArtwork(game: game),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.18), primary.withValues(alpha: 0.9)],
                  ),
                ),
              ),
            ),
            Positioned.fill(child: GameArtwork(game: game)),
            if (game.visual == GameVisual.iceFishing)
              Positioned(
                right: 26,
                top: 28,
                child: IceWheel(outcome: outcome),
              ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.subtitle,
                    style: TextStyle(color: accent.withValues(alpha: 0.86), fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    outcome?.message ?? 'Scegli la puntata e premi Gioca.',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
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

class GameControls extends StatelessWidget {
  const GameControls({
    required this.game,
    required this.session,
    required this.betController,
    required this.selectedChoice,
    required this.outcome,
    required this.errorMessage,
    required this.isPlaying,
    required this.onChoiceSelected,
    required this.onPlay,
    super.key,
  });

  final GameDefinition game;
  final UserSession session;
  final TextEditingController betController;
  final String? selectedChoice;
  final GameOutcome? outcome;
  final String? errorMessage;
  final bool isPlaying;
  final ValueChanged<String> onChoiceSelected;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      children: [
        InfoPill(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Saldo attuale',
          value: '${session.balance.toStringAsFixed(2)} crediti',
        ),
        const SizedBox(height: 18),
        StyledTextField(
          controller: betController,
          hintText: 'Puntata',
          icon: Icons.paid_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (game.choices.isNotEmpty) ...[
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              game.visual == GameVisual.iceFishing ? 'Punta sul settore della ruota' : 'Scegli una giocata',
              style: TextStyle(color: accent.withValues(alpha: 0.82), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.choices.map((choice) {
              final selected = choice.value == selectedChoice;
              return ChoiceChip(
                selected: selected,
                label: Text(choice.label),
                selectedColor: gold,
                labelStyle: TextStyle(color: selected ? primary : Colors.white, fontWeight: FontWeight.w800),
                onSelected: (_) => onChoiceSelected(choice.value),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 22),
        PrimaryButton(label: 'Gioca', isLoading: isPlaying, onPressed: onPlay),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        if (outcome != null) ...[
          const SizedBox(height: 20),
          OutcomeCard(outcome: outcome!),
        ],
      ],
    );
  }
}

class OutcomeCard extends StatelessWidget {
  const OutcomeCard({required this.outcome, super.key});

  final GameOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final positive = outcome.profit >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (positive ? gold : Colors.redAccent).withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(outcome.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MiniStat(label: 'Puntata', value: outcome.bet.toStringAsFixed(2)),
              MiniStat(label: 'Vincita', value: outcome.payout.toStringAsFixed(2)),
              MiniStat(label: 'Profitto', value: outcome.profit.toStringAsFixed(2), highlight: positive),
            ],
          ),
          const SizedBox(height: 12),
          Text(_details(outcome.result), style: TextStyle(color: accent.withValues(alpha: 0.82))),
        ],
      ),
    );
  }

  String _details(Map<String, dynamic> result) {
    if (result.containsKey('reels')) {
      return "Rulli: ${(result['reels'] as List).join('  ')}";
    }
    if (result.containsKey('number')) {
      return "Numero: ${result['number']} - Colore: ${result['color']}";
    }
    if (result.containsKey('segmentLabel')) {
      final bonus = result['bonus'] as Map<String, dynamic>?;
      return bonus == null
          ? "Settore: ${result['segmentLabel']} - Moltiplicatore: ${result['multiplier']}x"
          : "Settore: ${result['segmentLabel']} - ${bonus['label']} (${bonus['multiplier']}x)";
    }
    return 'Risultato registrato.';
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({required this.label, required this.value, this.highlight = false, super.key});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accent.withValues(alpha: 0.72), fontSize: 12)),
          Text(value, style: TextStyle(color: highlight ? gold : Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class IceWheel extends StatelessWidget {
  const IceWheel({required this.outcome, super.key});

  final GameOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final segment = outcome?.result['segment'] as String?;
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size.square(210), painter: IceWheelPainter(segment)),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.9),
              border: Border.all(color: gold, width: 3),
            ),
            child: const Icon(Icons.ac_unit_rounded, color: gold, size: 34),
          ),
          const Positioned(top: 0, child: Icon(Icons.arrow_drop_down_rounded, color: gold, size: 44)),
        ],
      ),
    );
  }
}

class IceWheelPainter extends CustomPainter {
  IceWheelPainter(this.selectedSegment);

  final String? selectedSegment;
  final List<String> labels = const ['1x', '2x', '5x', '10x', 'Flip', 'Pach', 'Bonus'];
  final List<String> keys = const ['1x', '2x', '5x', '10x', 'coin_flip', 'pachinko', 'ice_bonus'];
  final List<Color> colors = const [
    Color(0xFFBAE6FD),
    Color(0xFF38BDF8),
    Color(0xFF2563EB),
    Color(0xFF1E3A8A),
    Color(0xFFFACC15),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = math.pi * 2 / labels.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    for (var i = 0; i < labels.length; i++) {
      final paint = Paint()..color = colors[i].withValues(alpha: keys[i] == selectedSegment ? 1 : 0.86);
      canvas.drawArc(rect, -math.pi / 2 + (i * sweep), sweep, true, paint);
      final labelAngle = -math.pi / 2 + (i * sweep) + sweep / 2;
      final labelOffset = Offset(center.dx + math.cos(labelAngle) * radius * 0.66, center.dy + math.sin(labelAngle) * radius * 0.66);
      textPainter.text = TextSpan(text: labels[i], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900));
      textPainter.layout();
      textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    canvas.drawCircle(center, radius - 2, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = Colors.white.withValues(alpha: 0.76));
  }

  @override
  bool shouldRepaint(covariant IceWheelPainter oldDelegate) => oldDelegate.selectedSegment != selectedSegment;
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
