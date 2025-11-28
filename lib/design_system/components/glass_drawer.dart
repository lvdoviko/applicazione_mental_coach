import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routing/app_router.dart';

class GlassDrawer extends StatelessWidget {
  const GlassDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Usiamo ClipRRect per arrotondare i bordi destri del pannello
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        // IL SEGRETO: Sfocatura dello sfondo (Avatar e Stanza si intravedono)
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75, // Occupa il 75%
          decoration: BoxDecoration(
            // Gradiente scuro semi-trasparente
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D1322).withOpacity(0.70), // Più trasparente!
                const Color(0xFF000000).withOpacity(0.85), 
              ],
            ),
            // Bordo sottile a destra per definire il vetro
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER UTENTE PULITO
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Utente con Glow
                      Container(
                        padding: const EdgeInsets.all(2), // Bordo più sottile
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Bordo bianco semi-trasparente, molto chic
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1), 
                          boxShadow: [
                            // Ombra molto più morbida e diffusa
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withOpacity(0.25), 
                              blurRadius: 20, 
                              spreadRadius: 5
                            )
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                          // O usa backgroundImage: NetworkImage(...)
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nome
                      Text(
                        "Ciao, Ludovico",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8), // Un po' più di spazio dal nome
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          // Sfondo leggermente più luminoso per contrastare col blu scuro
                          color: Colors.white.withOpacity(0.08), 
                          borderRadius: BorderRadius.circular(20), // Molto rotondo (Pillola)
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2), 
                            width: 1
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                          children: [
                            // Un piccolo puntino o icona per dare status
                            const Icon(Icons.star_outline, color: Colors.white60, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "FREE PLAN",
                              style: GoogleFonts.nunito(
                                color: Colors.white70, 
                                fontSize: 11, 
                                fontWeight: FontWeight.w700, // Più bold per leggibilità
                                letterSpacing: 0.5, // Spaziatura lettere elegante
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 20),

                // 2. VOCI MENU ELEGANTI
                _buildMenuItem(
                  context, 
                  Icons.dashboard_outlined, 
                  "Dashboard", 
                  true,
                  () => context.go(AppRoute.dashboard.path),
                ),
                _buildMenuItem(
                  context, 
                  Icons.face, 
                  "Edit Avatar", 
                  false,
                  () => context.push(AppRoute.avatar.path),
                ),
                _buildMenuItem(
                  context, 
                  Icons.settings_outlined, 
                  "Settings", 
                  false,
                  () => context.push(AppRoute.settings.path),
                ),
                
                const Spacer(),
                
                // 3. FOOTER
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    "Kaix v1.0.0",
                    style: GoogleFonts.nunito(color: Colors.white30, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: isActive 
        ? BoxDecoration(
            // Gradiente che svanisce
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A90E2).withOpacity(0.2), // Blu a sinistra
                const Color(0xFF4A90E2).withOpacity(0.0), // Trasparente a destra
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            // Bordo sinistro per indicare "Attivo"
            border: const Border(left: BorderSide(color: Color(0xFF4A90E2), width: 3)),
          )
        : null,
      child: ListTile(
        leading: Icon(
          icon, 
          color: isActive ? const Color(0xFF4A90E2) : Colors.white70,
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Chiude il drawer
          onTap();
        },
      ),
    );
  }
}
