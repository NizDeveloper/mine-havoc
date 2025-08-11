# Minehavoc

## Descripción del juego
**Minehavoc** es un juego de mundo abierto en 2D ambientado en una mina subterránea. El jugador explora cavernas, recolectan recursos y combaten con enemigos. 
Características principales:
- Sistema de minería
- Combate PVE (Player vs Entitie)
- Mundo abierto niveles
- Sistema de guardado de partida

## Assets
Todos los recursos visuales y de sonido fueron obtenidos de creadores en [itch.io](https://itch.io/), 
incluyendo:
- Sprites para el jugador
- Tilesets para cavernas y entornos subterráneos
- Sprites de enemigos y criaturas
- Efectos de sonido (minería, combate, ambiente)
- Música temática

## Scripts principales

### 1. `player.gd`
**Funcionalidad:**
- Manejo de movimiento y física del personaje
- Sistema de animaciones para diferentes acciones
- Gestión de salud y barra de vida
- Mecánicas de minería y combate
- Interacción con minerales y enemigos
- Sistema de puntuación al recolectar recursos
- Implementación de guardado y carga de partida
- Cambio entre escenas/niveles

### 2. `slime.gd`
**Funcionalidad:**
- Detección y persecución del jugador
- Gestión de salud del enemigo
- Animaciones de movimiento y muerte

### 3. `global.gd`
**Funcionalidad:**
- Almacenamiento temporal de datos entre escenas
- Soporte para sistema de guardado/carga persistente
- Administración de datos pendientes de cargar

### 4. `mineral.gd`
**Funcionalidad:**
- Detección de la presencia del jugador
- Activación de la capacidad de minar en el jugador
- Asignación de sí mismo como objetivo minable actual

## 🎥 Videos demostrativos

[![Gameplay Inicial](https://img.youtube.com/vi/TU_ID_VIDEO_1/0.jpg)](https://youtu.be/TU_ID_VIDEO_1)  
*Exploración inicial y primeros recursos*

[![Combate en las minas](https://img.youtube.com/vi/TU_ID_VIDEO_2/0.jpg)](https://youtu.be/TU_ID_VIDEO_2)  
*Sistema de combate contra enemigos*

## 💡 Comentarios sobre el desarrollo

### Desafíos técnicos y soluciones:
1. **Sistema de guardado/recuperación:**
Implementado con serialización JSON y archivos. Manejo de cambios de escena con datos pendientes (Cuando cambiaba de escena los datos no se cargaban correctamente). Guardado de posición, salud, puntuación y escena actual

2. **Interacciones jugador-entorno:**
Uso de áreas (Area2D) para detectar minerales y enemigos. Señales para activar/desactivar capacidades (minar, atacar). Gestión de estados de acción (minería, ataque) que bloquean movimiento

3. **Comportamiento de enemigos:**
Movimiento básico hacia el jugador cuando está en rango. Detección de colisiones para daño al jugador.Mecánica de muerte con animación y eliminación

### Lecciones aprendidas:
- La gestión de estados del jugador (minar, atacar, daño) requiere control estricto de variables booleanas
- Las áreas (Area2D) son eficaces para interacciones no físicas
- El sistema de guardado debe planificarse desde el inicio para evitar cambios mayores


## ¿Cómo jugar?
1. Descarga el proyecto
2. Abre en Godot Engine 4.2+
3. Controles:
   - WASD: Movimiento
   - R: Alternar entre caminar y correr
   - M: Minar minerales (cuando estás cerca)
   - N: Atacar
   - C: Cargar partida
   - V: Guardar partida
