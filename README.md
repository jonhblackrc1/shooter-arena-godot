# Shooter Arena — Godot 4

Port del juego **Shooter Arena** (originalmente una PWA en HTML/JS) al motor **Godot 4**, por **Black Studio**.

- Versión web/PWA original: https://jonhblackrc1.github.io/shooter-arena/
- Este repo: reescritura en Godot 4 (GDScript) para una versión más profesional (Android/PC/Web).

## Abrir el proyecto

1. Descarga **Godot 4.3+** (versión estándar) desde https://godotengine.org
2. Project Manager → **Import** → selecciona `project.godot` → **Import & Edit**.
3. Pulsa **▶ Play**.

## Estado (Fase 0 — base jugable)

- Arena horizontal, movimiento **delta-time** (independiente del framerate).
- Controles táctiles: joystick de movimiento (mitad izquierda) + joystick de apuntado/disparo (mitad derecha). WASD/flechas y mouse en escritorio.
- Enemigos que persiguen, disparo, colisiones, SCORE y HP.

## Hoja de ruta

- **Fase 1:** armas, personajes, oleadas/niveles, jefes.
- **Fase 2:** menús, tienda, ajustes, audio, efectos, splash.
- **Fase 3:** login Google + guardado en la nube + ranking global (Firestore REST).
- **Fase 4:** exportar a APK/AAB, PC y Web.
