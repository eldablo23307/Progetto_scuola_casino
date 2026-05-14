import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color primary = Color(0xFF1E1028);
const Color secondary = Color(0xFF593F62);
const Color accent = Color(0xFFA5C4D4);
const Color gold = Color(0xFFFFC857);
const String apiBaseUrl = 'http://127.0.0.1:5000';
const List<GameChoice> rouletteChoices = [
  GameChoice(label: 'Rosso', value: 'red'),
  GameChoice(label: 'Nero', value: 'black'),
  GameChoice(label: 'Verde', value: 'green'),
  GameChoice(label: 'Pari', value: 'even'),
  GameChoice(label: 'Dispari', value: 'odd'),
  GameChoice(label: '1-18', value: 'low'),
  GameChoice(label: '19-36', value: 'high'),
  GameChoice(label: '1ª dozzina', value: 'dozen_1'),
  GameChoice(label: '2ª dozzina', value: 'dozen_2'),
  GameChoice(label: '3ª dozzina', value: 'dozen_3'),
  GameChoice(label: 'Colonna 1', value: 'column_1'),
  GameChoice(label: 'Colonna 2', value: 'column_2'),
  GameChoice(label: 'Colonna 3', value: 'column_3'),
  GameChoice(label: '0', value: 'number_0'),
  GameChoice(label: '1', value: 'number_1'),
  GameChoice(label: '2', value: 'number_2'),
  GameChoice(label: '3', value: 'number_3'),
  GameChoice(label: '4', value: 'number_4'),
  GameChoice(label: '5', value: 'number_5'),
  GameChoice(label: '6', value: 'number_6'),
  GameChoice(label: '7', value: 'number_7'),
  GameChoice(label: '8', value: 'number_8'),
  GameChoice(label: '9', value: 'number_9'),
  GameChoice(label: '10', value: 'number_10'),
  GameChoice(label: '11', value: 'number_11'),
  GameChoice(label: '12', value: 'number_12'),
  GameChoice(label: '13', value: 'number_13'),
  GameChoice(label: '14', value: 'number_14'),
  GameChoice(label: '15', value: 'number_15'),
  GameChoice(label: '16', value: 'number_16'),
  GameChoice(label: '17', value: 'number_17'),
  GameChoice(label: '18', value: 'number_18'),
  GameChoice(label: '19', value: 'number_19'),
  GameChoice(label: '20', value: 'number_20'),
  GameChoice(label: '21', value: 'number_21'),
  GameChoice(label: '22', value: 'number_22'),
  GameChoice(label: '23', value: 'number_23'),
  GameChoice(label: '24', value: 'number_24'),
  GameChoice(label: '25', value: 'number_25'),
  GameChoice(label: '26', value: 'number_26'),
  GameChoice(label: '27', value: 'number_27'),
  GameChoice(label: '28', value: 'number_28'),
  GameChoice(label: '29', value: 'number_29'),
  GameChoice(label: '30', value: 'number_30'),
  GameChoice(label: '31', value: 'number_31'),
  GameChoice(label: '32', value: 'number_32'),
  GameChoice(label: '33', value: 'number_33'),
  GameChoice(label: '34', value: 'number_34'),
  GameChoice(label: '35', value: 'number_35'),
  GameChoice(label: '36', value: 'number_36'),
];

const List<GameDefinition> casinoGames = [
  GameDefinition(
    title: 'Roulette',
    subtitle: 'Punta su colori, numeri, pari/dispari o gruppi',
    icon: Icons.radar_rounded,
    visual: GameVisual.roulette,
    apiPath: '/games/roulette/play',
    imageUrl: 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?auto=format&fit=crop&w=900&q=80',
    choices: rouletteChoices,
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
  GameDefinition(
    title: 'Gate of Olympus',
    subtitle: 'Cascate divine, scatter e moltiplicatori epici',
    icon: Icons.bolt_rounded,
    visual: GameVisual.olympusSlot,
    apiPath: '/games/slots/olympus/play',
    imageUrl: 'https://images.unsplash.com/photo-1603565816030-6b389eeb23cb?auto=format&fit=crop&w=900&q=80',
    colors: [Color(0xFF6D28D9), Color(0xFFFACC15)],
  ),
  GameDefinition(
    title: 'Blackjack',
    subtitle: 'Sfida il banco e avvicinati a 21',
    icon: Icons.style_rounded,
    visual: GameVisual.blackjack,
    apiPath: '/games/blackjack/play',
    imageUrl: 'https://images.unsplash.com/photo-1511193311914-0346f16efe90?auto=format&fit=crop&w=900&q=80',
    choices: [
      GameChoice(label: 'Stai', value: 'stand'),
      GameChoice(label: 'Carta', value: 'hit'),
    ],
    colors: [Color(0xFF065F46), Color(0xFF111827)],
  ),
];

enum GameVisual { roulette, iceFishing, fruitSlot, crystalSlot, thunderSlot, olympusSlot, blackjack }

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
                      color: accent.withOpacity(0.82),
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
          Text(errorMessage ?? '', style: const TextStyle(color: Colors.redAccent)),
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
          activeThumbColor: gold,
          title: const Text('Account simulato'),
          subtitle: Text(
            'Saldo demo da 5000 crediti',
            style: TextStyle(color: accent.withOpacity(0.75)),
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
          Text(errorMessage ?? '', style: const TextStyle(color: Colors.redAccent)),
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
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
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
        hintStyle: TextStyle(color: accent.withOpacity(0.72)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accent.withOpacity(0.28)),
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
        return initialSession as UserSession;
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
                    style: TextStyle(color: accent.withOpacity(0.9)),
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
                accent.withOpacity(0.22),
                Colors.white.withOpacity(0.08),
              ],
            ),
            border: Border.all(color: accent.withOpacity(0.26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bentornato,',
                style: TextStyle(color: accent.withOpacity(0.82), fontSize: 16),
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
            color: accent.withOpacity(0.86),
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
        color: primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: accent.withOpacity(0.72))),
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
            color: gold.withOpacity(0.24),
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
            color: primary.withOpacity(0.88),
            border: Border.all(color: Colors.white.withOpacity(0.42), width: 1.2),
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
            game.colors.first.withOpacity(0.82),
            game.colors.last.withOpacity(0.54),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: game.colors.first.withOpacity(0.18),
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
                errorBuilder: (context, error, stackTrace) => GameArtwork(game: game),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withOpacity(0.18),
                      game.colors.last.withOpacity(0.42),
                      primary.withOpacity(0.78),
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
                      color: primary.withOpacity(0.58),
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
                      color: Colors.white.withOpacity(0.82),
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
      duration: _animationDuration(widget.game.visual),
    );
    session = widget.session;
    if (widget.game.choices.isNotEmpty) {
      selectedChoice = widget.game.choices.first.value;
    }
  }

  Duration _animationDuration(GameVisual visual) {
    switch (visual) {
      case GameVisual.fruitSlot:
      case GameVisual.crystalSlot:
      case GameVisual.thunderSlot:
        return const Duration(milliseconds: 5200);
      case GameVisual.olympusSlot:
        return const Duration(milliseconds: 6800);
      case GameVisual.iceFishing:
        return const Duration(milliseconds: 2600);
      case GameVisual.roulette:
      case GameVisual.blackjack:
        return const Duration(milliseconds: 1800);
    }
  }

  bool _isSlotVisual(GameVisual visual) {
    return visual == GameVisual.fruitSlot || visual == GameVisual.crystalSlot || visual == GameVisual.thunderSlot || visual == GameVisual.olympusSlot;
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
      };
      if (widget.game.needsChoice) {
        body['choice'] = selectedChoice ?? '';
      }
      final responseFuture = http.post(
        Uri.parse('$apiBaseUrl${widget.game.apiPath}'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );
      final response = _isSlotVisual(widget.game.visual)
          ? (await Future.wait<dynamic>([
              responseFuture,
              Future<void>.delayed(_animationDuration(widget.game.visual)),
            ]))
              .first as http.Response
          : await responseFuture;

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
              colors: [primary, widget.game.colors.last.withOpacity(0.74)],
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
      height: 620,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [BoxShadow(color: game.colors.first.withOpacity(0.22), blurRadius: 36)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => GameArtwork(game: game),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.18), primary.withOpacity(0.9)],
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
                right: 22,
                top: 22,
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
                    style: TextStyle(color: accent.withOpacity(0.86), fontSize: 16, fontWeight: FontWeight.w700),
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
    final currentOutcome = outcome;
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
              game.visual == GameVisual.iceFishing
                  ? 'Punta sul settore della ruota'
                  : game.visual == GameVisual.roulette
                      ? 'Scegli colore, numero o gruppo'
                      : game.visual == GameVisual.blackjack
                          ? 'Scegli la tua azione'
                          : 'Scegli una giocata',
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
          Text(errorMessage ?? '', style: const TextStyle(color: Colors.redAccent)),
        ],
        if (currentOutcome != null) ...[
          const SizedBox(height: 20),
          OutcomeCard(outcome: currentOutcome),
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
        color: primary.withOpacity(0.56),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (positive ? gold : Colors.redAccent).withOpacity(0.42)),
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
          Text(_details(outcome.result), style: TextStyle(color: accent.withOpacity(0.82))),
        ],
      ),
    );
  }

  String _details(Map<String, dynamic> result) {
    if (result.containsKey('grid')) {
      final events = (result['events'] as List?)?.length ?? 0;
      return "Griglia Olympus: ${(result['grid'] as List).map((row) => (row as List).join(' ')).join(' / ')} - Eventi: $events";
    }
    if (result.containsKey('playerHand')) {
      return "Giocatore: ${(result['playerHand'] as List).join(' ')} (${result['playerScore']}) - Banco: ${(result['dealerHand'] as List).join(' ')} (${result['dealerScore']})";
    }
    if (result.containsKey('reels')) {
      final events = (result['events'] as List?)?.length ?? 0;
      return "Rulli: ${(result['reels'] as List).join('  ')}${events > 0 ? ' - Eventi: $events' : ''}";
    }
    if (result.containsKey('number')) {
      return "Numero: ${result['number']} - Colore: ${result['color']} - "
          "Giocata: ${result['choiceLabel'] ?? result['choice']}";
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
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accent.withOpacity(0.72), fontSize: 12)),
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
      width: 270,
      height: 270,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final easedStop = Curves.easeOutCubic.transform(animation.value);
          final pulse = 1 + (math.sin(animation.value * math.pi * 4).abs() * (isPlaying ? 0.13 : 0.05));
          final turns = isPlaying ? animation.value * math.pi * 24 : _iceWheelRotationForSegment(segment) + ((1 - easedStop) * math.pi * 8);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF67E8F9).withOpacity(0.34), blurRadius: 36, spreadRadius: 4),
                    BoxShadow(color: gold.withOpacity(0.18), blurRadius: 56, spreadRadius: 10),
                  ],
                ),
              ),
              Transform.scale(
                scale: pulse,
                child: Transform.rotate(
                  angle: turns,
                  child: CustomPaint(size: const Size.square(252), painter: IceWheelPainter(segment)),
                ),
              ),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.92),
                  border: Border.all(color: gold, width: 4),
                  boxShadow: [BoxShadow(color: gold.withOpacity(0.38), blurRadius: 22)],
                ),
                child: const Icon(Icons.ac_unit_rounded, color: gold, size: 42),
              ),
              const Positioned(top: -5, child: Icon(Icons.arrow_drop_down_rounded, color: gold, size: 56)),
            ],
          );
        },
      ),
    );
  }

  double _iceWheelRotationForSegment(String? segment) {
    if (segment == null) return 0;
    const keys = ['1x', '2x', '5x', '10x', 'coin_flip', 'pachinko', 'ice_bonus'];
    final index = keys.indexOf(segment);
    if (index < 0) return 0;
    final sweep = math.pi * 2 / keys.length;
    return -((index * sweep) + (sweep / 2));
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
      final selected = keys[i] == selectedSegment;
      final paint = Paint()..color = colors[i].withOpacity(selected ? 1 : 0.88);
      canvas.drawArc(rect, -math.pi / 2 + (i * sweep), sweep, true, paint);
      canvas.drawArc(
        rect.deflate(4),
        -math.pi / 2 + (i * sweep),
        sweep,
        true,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 5 : 2
          ..color = Colors.white.withOpacity(selected ? 0.95 : 0.34),
      );
      final labelAngle = -math.pi / 2 + (i * sweep) + sweep / 2;
      final labelOffset = Offset(center.dx + math.cos(labelAngle) * radius * 0.64, center.dy + math.sin(labelAngle) * radius * 0.64);
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.white,
          fontSize: selected ? 17 : 15,
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    canvas.drawCircle(center, radius - 2, Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = Colors.white.withOpacity(0.82));
    canvas.drawCircle(center, radius - 18, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = primary.withOpacity(0.48));
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
          outcome: outcome,
          isPlaying: isPlaying,
          animation: animation,
        );
      case GameVisual.fruitSlot:
      case GameVisual.crystalSlot:
      case GameVisual.thunderSlot:
      case GameVisual.olympusSlot:
        return AnimatedSlotStage(
          game: game,
          outcome: outcome,
          isPlaying: isPlaying,
          animation: animation,
        );
      case GameVisual.blackjack:
        return AnimatedBlackjackStage(
          game: game,
          outcome: outcome,
          isPlaying: isPlaying,
          animation: animation,
        );
    }
  }
}

const List<int> europeanRouletteNumbers = [
  0,
  32,
  15,
  19,
  4,
  21,
  2,
  25,
  17,
  34,
  6,
  27,
  13,
  36,
  11,
  30,
  8,
  23,
  10,
  5,
  24,
  16,
  33,
  1,
  20,
  14,
  31,
  9,
  22,
  18,
  29,
  7,
  28,
  12,
  35,
  3,
  26,
];

const Set<int> europeanRouletteRedNumbers = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36};

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
        final number = (outcome?.result['number'] as num?)?.toInt();
        final landedColor = (outcome?.result['color'] as String?) ?? '';
        final wheelRotation = isPlaying ? progress * math.pi * 18 : _rotationForNumber(number) + progress * math.pi * 2;
        final ballAngle = isPlaying ? (progress * math.pi * -24) - math.pi / 2 : -math.pi / 2;
        final ballRadius = isPlaying ? 156.0 - (progress * 28) : 126.0;
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned.fill(
              child: CustomPaint(
                painter: CasinoParticlePainter(
                  progress: progress,
                  color: landedColor == 'green' ? const Color(0xFF16A34A) : landedColor == 'red' ? Colors.redAccent : Colors.white,
                  intense: outcome != null && !isPlaying,
                ),
              ),
            ),
            Positioned(
              right: 34,
              top: 38,
              child: SizedBox(
                width: 370,
                height: 370,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 370,
                      height: 370,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: gold.withOpacity(0.28), blurRadius: 46, spreadRadius: 4),
                          BoxShadow(color: Colors.black.withOpacity(0.48), blurRadius: 30, offset: const Offset(0, 18)),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: wheelRotation,
                      child: const CustomPaint(size: Size.square(350), painter: RouletteWheelPainter()),
                    ),
                    Positioned(
                      left: 185 + (math.cos(ballAngle) * ballRadius) - 10,
                      top: 185 + (math.sin(ballAngle) * ballRadius) - 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.95), blurRadius: 18, spreadRadius: 2)],
                        ),
                      ),
                    ),
                    const Positioned(top: -7, child: Icon(Icons.arrow_drop_down_rounded, color: gold, size: 58)),
                    if (outcome != null && !isPlaying)
                      ResultBadge(text: '$number'),
                  ],
                ),
              ),
            ),
            if (outcome != null && !isPlaying)
              Positioned(
                left: 34,
                top: 52,
                child: ResultSpotlight(
                  title: 'Risultato roulette',
                  value: '$number ${_italianRouletteColor(landedColor)}',
                  color: landedColor == 'green' ? const Color(0xFF16A34A) : landedColor == 'red' ? Colors.redAccent : Colors.black87,
                ),
              ),
          ],
        );
      },
    );
  }

  double _rotationForNumber(int? number) {
    if (number == null) return 0;
    final index = europeanRouletteNumbers.indexOf(number);
    if (index < 0) return 0;
    return -(index * (math.pi * 2 / europeanRouletteNumbers.length));
  }

  String _italianRouletteColor(String color) {
    switch (color) {
      case 'red':
        return 'rosso';
      case 'black':
        return 'nero';
      case 'green':
        return 'verde';
      default:
        return '';
    }
  }
}

class RouletteWheelPainter extends CustomPainter {
  const RouletteWheelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = math.pi * 2 / europeanRouletteNumbers.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    for (var i = 0; i < europeanRouletteNumbers.length; i++) {
      final number = europeanRouletteNumbers[i];
      final color = number == 0 ? const Color(0xFF16A34A) : europeanRouletteRedNumbers.contains(number) ? const Color(0xFFDC2626) : const Color(0xFF111827);
      final start = -math.pi / 2 + (i * sweep) - (sweep / 2);
      canvas.drawArc(rect, start, sweep, true, Paint()..color = color);
      canvas.drawArc(rect.deflate(2), start, sweep, true, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = Colors.white.withOpacity(0.55));

      final labelAngle = -math.pi / 2 + (i * sweep);
      final labelOffset = Offset(center.dx + math.cos(labelAngle) * radius * 0.82, center.dy + math.sin(labelAngle) * radius * 0.82);
      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(labelAngle + math.pi / 2);
      textPainter.text = TextSpan(
        text: '$number',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 3)]),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(center, radius - 2, Paint()..style = PaintingStyle.stroke..strokeWidth = 9..color = gold);
    canvas.drawCircle(center, radius * 0.68, Paint()..style = PaintingStyle.stroke..strokeWidth = 7..color = const Color(0xFFF8E7B4));
    canvas.drawCircle(center, radius * 0.46, Paint()..color = const Color(0xFF7C2D12));
    canvas.drawCircle(center, radius * 0.28, Paint()..color = gold);
    canvas.drawCircle(center, radius * 0.14, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant RouletteWheelPainter oldDelegate) => false;
}

class AnimatedIceFishingStage extends StatelessWidget {
  const AnimatedIceFishingStage({
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
        final bob = math.sin(progress * math.pi * 2) * (isPlaying ? 24 : 8);
        final segment = outcome?.result['segment'] as String?;
        final bonus = outcome?.result['bonus'] as Map<String, dynamic>?;
        final isSpecial = segment == 'coin_flip' || segment == 'pachinko' || segment == 'ice_bonus';
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned.fill(
              child: CustomPaint(
                painter: CasinoParticlePainter(
                  progress: progress,
                  color: isSpecial ? gold : const Color(0xFF67E8F9),
                  intense: outcome != null && !isPlaying,
                ),
              ),
            ),
            for (var i = 0; i < 30; i++)
              Positioned(
                left: 18.0 + (i * 53 % 560),
                top: ((progress * (isPlaying ? 280 : 95)) + i * 31) % 620,
                child: Transform.rotate(
                  angle: progress * math.pi * 2 + i,
                  child: Icon(Icons.ac_unit_rounded, color: Colors.white.withOpacity(0.22 + (i % 4) * 0.06), size: 14 + (i % 5) * 4),
                ),
              ),
            Positioned(
              left: 76,
              top: 48 + bob,
              child: Transform.rotate(
                angle: -0.52 + math.sin(progress * math.pi * 2) * 0.14,
                child: Container(
                  width: 13,
                  height: 172,
                  decoration: BoxDecoration(
                    color: const Color(0xFF92400E),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [BoxShadow(color: gold.withOpacity(0.38), blurRadius: 18)],
                  ),
                ),
              ),
            ),
            Positioned(left: 138, top: 166 + (bob * 0.58), child: Container(width: 2, height: 130, color: Colors.white.withOpacity(0.76))),
            Positioned(
              left: 92,
              top: 286 + (bob * 0.28),
              child: Transform.scale(
                scale: 1 + math.sin(progress * math.pi * 2).abs() * (isPlaying ? 0.18 : 0.08),
                child: Icon(Icons.set_meal_rounded, color: const Color(0xFF67E8F9).withOpacity(0.98), size: 88),
              ),
            ),
            Positioned(
              left: 220,
              right: 58,
              bottom: 92,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.28), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFF67E8F9).withOpacity(0.22), blurRadius: 28)],
                ),
              ),
            ),
            if (outcome != null && !isPlaying)
              Positioned(
                left: 34,
                top: 52,
                child: ResultSpotlight(
                  title: isSpecial ? 'Bonus speciale!' : 'Settore pescato',
                  value: bonus == null ? '${outcome?.result['segmentLabel']}' : '${bonus['label']} • ${bonus['multiplier']}x',
                  color: isSpecial ? gold : const Color(0xFF67E8F9),
                ),
              ),
            if (outcome != null && !isPlaying && isSpecial)
              Positioned(
                left: 270,
                top: 118,
                child: IceSpecialEffect(segment: segment ?? '', bonus: bonus, progress: progress),
              ),
          ],
        );
      },
    );
  }
}

class IceSpecialEffect extends StatelessWidget {
  const IceSpecialEffect({required this.segment, required this.bonus, required this.progress, super.key});

  final String segment;
  final Map<String, dynamic>? bonus;
  final double progress;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    switch (segment) {
      case 'coin_flip':
        icon = Icons.currency_exchange_rounded;
        title = 'COIN FLIP';
        break;
      case 'pachinko':
        icon = Icons.sports_baseball_rounded;
        title = 'PACHINKO';
        break;
      default:
        icon = Icons.phishing_rounded;
        title = 'ICE BONUS';
    }
    final bonusData = bonus;
    return Transform.scale(
      scale: 1 + math.sin(progress * math.pi * 2).abs() * 0.08,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [gold.withOpacity(0.96), const Color(0xFF67E8F9).withOpacity(0.9)]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.82), width: 3),
          boxShadow: [BoxShadow(color: gold.withOpacity(0.42), blurRadius: 36, spreadRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primary, size: 58),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            if (bonusData != null) ...[
              const SizedBox(height: 6),
              Text('${bonusData['multiplier']}x', style: const TextStyle(color: primary, fontSize: 38, fontWeight: FontWeight.w900)),
            ],
          ],
        ),
      ),
    );
  }
}

class AnimatedBlackjackStage extends StatelessWidget {
  const AnimatedBlackjackStage({required this.game, required this.outcome, required this.isPlaying, required this.animation, super.key});

  final GameDefinition game;
  final GameOutcome? outcome;
  final bool isPlaying;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final player = (outcome?.result['playerHand'] as List?)?.map((card) => card.toString()).toList() ?? ['A', '?'];
    final dealer = (outcome?.result['dealerHand'] as List?)?.map((card) => card.toString()).toList() ?? ['?', 'K'];
    final win = (outcome?.profit ?? 0) > 0;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final dealOffset = isPlaying ? math.sin(progress * math.pi * 10) * 24 : 0.0;
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned.fill(child: CustomPaint(painter: CasinoParticlePainter(progress: progress, color: win ? gold : const Color(0xFF10B981), intense: win || isPlaying))),
            Positioned(
              right: 62,
              top: 72,
              child: _BlackjackHand(title: 'Banco', cards: dealer, score: outcome?.result['dealerScore'], offset: -dealOffset, color: const Color(0xFF111827)),
            ),
            Positioned(
              left: 70,
              bottom: 120,
              child: _BlackjackHand(title: 'Giocatore', cards: player, score: outcome?.result['playerScore'], offset: dealOffset, color: const Color(0xFF065F46)),
            ),
            if (outcome != null && !isPlaying)
              Positioned(
                left: 34,
                top: 52,
                child: ResultSpotlight(
                  title: win ? 'Mano vincente!' : 'Mano conclusa',
                  value: '${outcome?.result['playerScore']} vs ${outcome?.result['dealerScore']}',
                  color: win ? gold : const Color(0xFF10B981),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BlackjackHand extends StatelessWidget {
  const _BlackjackHand({required this.title, required this.cards, required this.score, required this.offset, required this.color});

  final String title;
  final List<String> cards;
  final Object? score;
  final double offset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title${score == null ? '' : ' • $score'}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(cards.length, (index) {
            return Transform.translate(
              offset: Offset(offset + index * -8, math.sin(index + offset) * 3),
              child: Transform.rotate(
                angle: (index - 1) * 0.08,
                child: Container(
                  width: 78,
                  height: 112,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: gold, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.32), blurRadius: 18, offset: const Offset(0, 10))],
                  ),
                  child: Center(child: Text(cards[index], style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w900))),
                ),
              ),
            );
          }),
        ),
      ],
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
        return ['CH', 'LM', '7'];
      case GameVisual.crystalSlot:
        return ['DI', 'RY', 'CR'];
      case GameVisual.thunderSlot:
        return ['BOLT', 'STAR', 'W'];
      case GameVisual.olympusSlot:
        return ['BOLT', 'CROWN', 'GEM', 'VASE', 'EAGLE', 'SHIELD', 'ORB'];
      case GameVisual.blackjack:
        return ['A', 'K', 'Q'];
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
      case GameVisual.olympusSlot:
        return const Color(0xFF3B0764);
      case GameVisual.blackjack:
        return const Color(0xFF064E3B);
      case GameVisual.roulette:
      case GameVisual.iceFishing:
        return primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reels = (outcome?.result['reels'] as List?)?.map((value) => value.toString()).toList() ?? fallbackSymbols;
    final grid = (outcome?.result['grid'] as List?)?.map((row) => (row as List).map((value) => value.toString()).toList()).toList();
    final events = (outcome?.result['events'] as List?) ?? const [];
    final tier = outcome?.result['winTier'] as String? ?? 'none';
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final win = (outcome?.profit ?? 0) > 0;
        final glow = win ? gold : game.colors.first;
        final shake = win ? math.sin(progress * math.pi * 18) * 5 : 0.0;
        return Stack(
          children: [
            Positioned.fill(child: GameArtwork(game: game)),
            Positioned.fill(
              child: CustomPaint(
                painter: CasinoParticlePainter(progress: progress, color: glow, intense: win || isPlaying),
              ),
            ),
            if (win)
              Positioned.fill(
                child: CustomPaint(
                  painter: WinBurstPainter(progress: progress, color: tier == 'mythic' ? const Color(0xFFF472B6) : gold),
                ),
              ),
            Center(
              child: Transform.translate(
                offset: Offset(shake, game.visual == GameVisual.olympusSlot ? -16 : 0),
                child: Container(
                  width: game.visual == GameVisual.olympusSlot ? 430 : 340,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [panelColor.withValues(alpha: 0.94), game.colors.last.withValues(alpha: 0.58)]),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: glow.withValues(alpha: win ? 0.98 : 0.76), width: win ? 6 : 4),
                    boxShadow: [
                      BoxShadow(color: glow.withValues(alpha: win ? 0.55 : 0.28), blurRadius: win ? 58 : 34, spreadRadius: win ? 8 : 0),
                    ],
                  ),
                  child: _slotContent(
                    grid: grid,
                    reels: reels,
                    fallbackSymbols: fallbackSymbols,
                    isPlaying: isPlaying,
                    animation: animation,
                    panelColor: panelColor,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 120,
              child: Transform.rotate(
                angle: math.sin(progress * math.pi * (isPlaying ? 8 : 2)) * (isPlaying ? 0.55 : 0.22),
                child: Container(
                  width: 18,
                  height: 88,
                  decoration: BoxDecoration(color: glow, borderRadius: BorderRadius.circular(99), boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.5), blurRadius: 20)]),
                ),
              ),
            ),
            if (outcome != null && !isPlaying)
              Positioned(
                left: 34,
                top: 52,
                child: ResultSpotlight(
                  title: win ? _winTitle(tier) : 'Rulli fermati',
                  value: _slotResultValue(reels, events),
                  color: win ? glow : game.colors.first,
                ),
              ),
            if (outcome != null && !isPlaying && win)
              Positioned(
                left: 54,
                bottom: 130,
                child: WinEventBadges(events: events, tier: tier, progress: progress),
              ),
          ],
        );
      },
    );
  }

  Widget _slotContent({required List<List<String>>? grid, required List<String> reels, required List<String> fallbackSymbols, required bool isPlaying, required Animation<double> animation, required Color panelColor}) {
    if (game.visual == GameVisual.olympusSlot) {
      return _OlympusGrid(grid: grid, fallbackSymbols: fallbackSymbols, isPlaying: isPlaying, animation: animation, panelColor: panelColor);
    }
    return _ClassicSlotReels(reels: reels, fallbackSymbols: fallbackSymbols, isPlaying: isPlaying, animation: animation, panelColor: panelColor);
  }

  String _slotResultValue(List<String> reels, List events) {
    if (game.visual == GameVisual.olympusSlot) {
      final multiplier = outcome?.result['multiplier'] ?? 0;
      return '${multiplier}x • ${events.length} eventi';
    }
    return reels.join('  ');
  }

  String _winTitle(String tier) {
    switch (tier) {
      case 'mythic':
        return 'VINCITA MITICA!';
      case 'mega':
        return 'MEGA WIN!';
      case 'jackpot':
        return 'JACKPOT!';
      default:
        return 'Combinazione vincente';
    }
  }
}

class _ScrollingSymbolFace extends StatelessWidget {
  const _ScrollingSymbolFace({
    required this.symbol,
    required this.fallbackSymbols,
    required this.isPlaying,
    required this.animation,
    required this.panelColor,
    required this.symbolIndex,
    required this.height,
    required this.largeFontSize,
    required this.longFontSize,
    required this.scrollCycles,
  });

  final String symbol;
  final List<String> fallbackSymbols;
  final bool isPlaying;
  final Animation<double> animation;
  final Color panelColor;
  final int symbolIndex;
  final double height;
  final double largeFontSize;
  final double longFontSize;
  final int scrollCycles;

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) {
      return _symbolText(symbol);
    }

    final symbols = fallbackSymbols.isEmpty ? [symbol] : fallbackSymbols;
    final position = animation.value * symbols.length * scrollCycles + symbolIndex * 0.65;
    final baseIndex = position.floor();
    final fraction = position - baseIndex;
    final itemHeight = height * 0.58;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(7, (visibleIndex) {
          final slotOffset = visibleIndex - 3;
          final currentSymbol = symbols[(baseIndex + slotOffset) % symbols.length];
          final distanceFromCenter = (slotOffset - fraction).abs();
          return Transform.translate(
            offset: Offset(0, (slotOffset - fraction) * itemHeight),
            child: Opacity(
              opacity: (1 - distanceFromCenter * 0.22).clamp(0.18, 1).toDouble(),
              child: Transform.scale(
                scale: (1 - distanceFromCenter * 0.08).clamp(0.72, 1).toDouble(),
                child: _symbolText(currentSymbol),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _symbolText(String value) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, maxLines: 1, style: TextStyle(color: panelColor, fontSize: value.length > 2 ? longFontSize : largeFontSize, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class _ClassicSlotReels extends StatelessWidget {
  const _ClassicSlotReels({required this.reels, required this.fallbackSymbols, required this.isPlaying, required this.animation, required this.panelColor});

  final List<String> reels;
  final List<String> fallbackSymbols;
  final bool isPlaying;
  final Animation<double> animation;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final spinOffset = isPlaying ? math.sin((animation.value * math.pi * 4) + index) * 18 : math.sin(animation.value * math.pi * 2 + index) * 3;
        final symbol = isPlaying ? fallbackSymbols[(index + (animation.value * 5).floor()) % fallbackSymbols.length] : reels[index];
        return Expanded(
          child: Transform.translate(
            offset: Offset(0, spinOffset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.98), Colors.white.withValues(alpha: 0.74)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.22), blurRadius: 18)],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(symbol, maxLines: 1, style: TextStyle(color: panelColor, fontSize: symbol.length > 2 ? 24 : 46, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OlympusGrid extends StatelessWidget {
  const _OlympusGrid({required this.grid, required this.fallbackSymbols, required this.isPlaying, required this.animation, required this.panelColor});

  final List<List<String>>? grid;
  final List<String> fallbackSymbols;
  final bool isPlaying;
  final Animation<double> animation;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    final visibleGrid = grid ?? List.generate(3, (row) => List.generate(5, (column) => fallbackSymbols[(row + column) % fallbackSymbols.length]));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (row) {
        return Row(
          children: List.generate(5, (column) {
            final index = row * 5 + column;
            final spin = isPlaying ? math.sin(animation.value * math.pi * 4 + index) * 12 : 0.0;
            final symbol = isPlaying ? fallbackSymbols[(index + (animation.value * 6).floor()) % fallbackSymbols.length] : visibleGrid[row][column];
            return Expanded(
              child: Transform.translate(
                offset: Offset(0, spin),
                child: Container(
                  height: 74,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withValues(alpha: 0.42)),
                    boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.16), blurRadius: 12)],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(symbol, maxLines: 1, style: TextStyle(color: panelColor, fontSize: symbol.length > 2 ? 18 : 30, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class WinEventBadges extends StatelessWidget {
  const WinEventBadges({required this.events, required this.tier, required this.progress, super.key});

  final List events;
  final String tier;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final labels = events.isEmpty ? <String>['WIN'] : events.take(4).map<String>((event) => event is Map ? '${event['multiplier']}x ${event['type']}' : event.toString()).toList();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(labels.length, (index) {
        final color = tier == 'mythic' ? const Color(0xFFF472B6) : index.isEven ? gold : const Color(0xFF67E8F9);
        return Transform.scale(
          scale: 1 + math.sin(progress * math.pi * 2 + index).abs() * 0.12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82), width: 2),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 24)],
            ),
            child: Text(labels[index].toUpperCase(), style: const TextStyle(color: primary, fontWeight: FontWeight.w900)),
          ),
        );
      }),
    );
  }
}

class WinBurstPainter extends CustomPainter {
  WinBurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    for (var i = 0; i < 18; i++) {
      final angle = (math.pi * 2 / 18) * i + progress * math.pi;
      final length = maxRadius * (0.22 + ((i % 4) * 0.08)) * (0.65 + progress * 0.35);
      final start = center + Offset(math.cos(angle), math.sin(angle)) * 34;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * length;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color.withValues(alpha: 0.18 + (i % 3) * 0.08)
          ..strokeWidth = 3 + (i % 4)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WinBurstPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
}

class CasinoParticlePainter extends CustomPainter {
  CasinoParticlePainter({required this.progress, required this.color, required this.intense});

  final double progress;
  final Color color;
  final bool intense;

  @override
  void paint(Canvas canvas, Size size) {
    final count = intense ? 42 : 18;
    final width = math.max(size.width, 1.0);
    final height = math.max(size.height, 1.0);
    for (var i = 0; i < count; i++) {
      final orbit = (i * 41.0) % width;
      final x = (orbit + progress * (intense ? 260 : 120)) % width;
      final wave = math.sin(progress * math.pi * 2 + i * 0.7);
      final y = ((i * 67.0) % height) + wave * (intense ? 28 : 12);
      final radius = intense ? 2.5 + (i % 5) * 1.3 : 1.8 + (i % 3);
      final alpha = intense ? 0.18 + (i % 4) * 0.08 : 0.12 + (i % 3) * 0.05;
      canvas.drawCircle(Offset(x, y % height), radius, Paint()..color = color.withOpacity(alpha));
    }
  }

  @override
  bool shouldRepaint(covariant CasinoParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.intense != intense;
  }
}

class ResultSpotlight extends StatelessWidget {
  const ResultSpotlight({required this.title, required this.value, required this.color, super.key});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.84),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withOpacity(0.76), width: 3),
        boxShadow: [BoxShadow(color: color.withOpacity(0.34), blurRadius: 34, spreadRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title.toUpperCase(), style: TextStyle(color: accent.withOpacity(0.92), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
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
        color: primary.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 4),
        boxShadow: [BoxShadow(color: gold.withOpacity(0.42), blurRadius: 24)],
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
          symbols: ['CH', 'LM', '7'],
          panelColor: Color(0xFF7F1D1D),
          glowColor: Color(0xFFFFC857),
        );
      case GameVisual.crystalSlot:
        return const SlotArtwork(
          symbols: ['DI', 'RY', 'CR'],
          panelColor: Color(0xFF312E81),
          glowColor: Color(0xFF22D3EE),
        );
      case GameVisual.thunderSlot:
        return const SlotArtwork(
          symbols: ['BOLT', 'STAR', 'W'],
          panelColor: Color(0xFF111827),
          glowColor: Color(0xFFFACC15),
        );
      case GameVisual.olympusSlot:
        return const SlotArtwork(
          symbols: ['BOLT', 'CROWN', 'GEM'],
          panelColor: Color(0xFF3B0764),
          glowColor: Color(0xFFFACC15),
        );
      case GameVisual.blackjack:
        return const BlackjackArtwork();
    }
  }
}

class BlackjackArtwork extends StatelessWidget {
  const BlackjackArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [const Color(0xFF047857).withValues(alpha: 0.72), const Color(0xFF022C22).withValues(alpha: 0.92)]),
            ),
          ),
        ),
        Positioned(
          right: 34,
          top: 34,
          child: Icon(Icons.style_rounded, color: gold.withValues(alpha: 0.5), size: 150),
        ),
        Positioned(
          left: 42,
          bottom: 70,
          child: Container(
            width: 320,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: gold.withValues(alpha: 0.42), width: 5),
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
        ),
      ],
    );
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
              color: primary.withOpacity(0.72),
              border: Border.all(color: gold, width: 10),
            ),
            child: Center(
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935).withOpacity(0.92),
                  border: Border.all(color: Colors.white.withOpacity(0.74), width: 8),
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
                  border: Border.all(color: Colors.white.withOpacity(0.34)),
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
              color: Colors.white.withOpacity(0.22),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 8),
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
          child: Container(width: 2, height: 72, color: Colors.white.withOpacity(0.82)),
        ),
        Positioned(
          left: 62,
          top: 116,
          child: Icon(Icons.set_meal_rounded, color: gold.withOpacity(0.92), size: 58),
        ),
        Positioned(
          left: -22,
          bottom: 42,
          child: Container(
            width: 180,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.24),
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
              color: panelColor.withOpacity(0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: glowColor.withOpacity(0.76), width: 3),
              boxShadow: [
                BoxShadow(color: glowColor.withOpacity(0.22), blurRadius: 30),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: symbols
                  .map(
                    (symbol) => Expanded(
                      child: Container(
                        height: 88,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
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
          child: Icon(Icons.auto_awesome_rounded, color: glowColor.withOpacity(0.9), size: 42),
        ),
      ],
    );
  }
}
