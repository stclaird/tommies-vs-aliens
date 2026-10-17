Godot 4 top-down shooter (Robotron / Alien Syndrome style). Repo: stclaird/tommies-vs-aliens.
Mission types: room-clearing, escort/rescue, more later. Goal: reuse rooms, enemies,
weapons and systems across many levels.

## Core principles
- Four layers: Actors / Rooms / Level / Mission rules. Dependencies point down only;
  children emit signals, parents listen. Rooms don't know the mission, enemies don't know the room.
- Organise by feature, not file type (scene + script + art side by side).
  Test: adding or deleting a feature touches one folder.
- Tuning lives in exports / Resources (.tres), not constants.
- Mission types are composable Objective nodes under a MissionController, not if/else.
- Don't build abstractions before the second use.

## Agreed layout
res://
├── features/
│   ├── player/
│   ├── enemies/
│   │   ├── shared/          wandering_alien.gd + .tscn (base scene)
│   │   └── aliens/terry/    terry.tscn (inherited), terry_frames.tres, sprites/
│   ├── friendlies/          anyone to rescue/escort (nurse, wounded_tommy, civilian)
│   │   └── shared/          friendly.gd/.tscn, follower.gd
│   ├── weapons/             weapon_data.gd, projectile.gd, smle/, bren/, flamethrower/
│   ├── components/          health_component.gd, hurtbox.gd
│   ├── props/               door/, destructible_wall/, shower_wall/
│   ├── spawning/            wave_manager.gd
│   ├── missions/            mission_controller.gd, objective.gd, objectives/
│   └── ui/hud/
├── world/
│   ├── rooms/               room.tscn/.gd, barracks/, hospital/ (room scenes + art + tileset)
│   └── levels/              barracks_01.tscn, hospital_01.tscn (named by place, not mission)
├── autoload/                game_state.gd
└── shared/                  fonts, generic sfx, shaders, theme

## Key decisions
- "Friendlies" = characters on your side. Escort/rescue are ROLES from components
  (Follower, HealthComponent) + objectives, not character types.
- "Terry" = codename for one wandering alien. Behaviour is shared (wandering_alien.gd);
  each alien type is an inherited scene with its own SpriteFrames. All wanderers use the
  same animation names: walk_/stand_/shot_ + left/right, plus injured_ variants.
  shot_* animations must NOT loop.
- Levels have the same structure; they differ only in which Objectives sit under Mission.
- Giant level PNG is OK while prototyping; walls/doors/collision/spawns are separate nodes.
  Rooms can use Sprite2D region_rect into the big PNG, cropped later.

## Health and weapons design
- Terry max_health 30. HealthComponent (signals damaged, died) + Hurtbox (Area2D with
  damage_multiplier). Body hurtbox x1.0, head hurtbox x3.0.
- WeaponData resource: damage, shots_per_second, automatic, can_headshot, projectile, fire_sound.
- SMLE: 10 dmg, ~1/s → 3 body shots or 1 headshot.
- Bren: 10 dmg, ~8/s → 3 shots, kills faster via fire rate. OPEN: allow headshots or not?
- Flamethrower: 30+ dmg flame projectiles → one hit.
- Projectile collects all hurtboxes hit in one frame and applies the highest multiplier
  (head and body overlap; signal order isn't guaranteed).
- Injured Terry: switch to injured_ animations, optionally slower.

## Scaling without overengineering
- Add new content to the feature that owns it; keep its scene, script, data and art
  together. Don't create a shared abstraction for a single use.
- When a second feature needs the same behavior, extract the smallest reusable component
  or base scene. Keep feature-specific decisions in the feature, not in shared code.
- Use exported properties for per-instance tuning and Resources for reusable content
  definitions. Avoid duplicating gameplay values across scenes and scripts.
- Rooms own geometry and spawn locations. Levels compose rooms and objectives;
  objectives report progress through signals, and MissionController decides completion.
  Gameplay features must not update HUD nodes directly.
- Connect systems through typed signals and explicit data, not scene-tree paths into
  another feature. Keep node paths local to the scene that owns them.
- Add a new mission type by composing existing objectives first. Add a new objective
  when its completion rule is genuinely different; avoid branching shared systems on
  mission names or level names.
- Enemies used by a wave expose a `died` signal and `take_hit()` method. The wave manager
  depends on this contract, not on a particular alien type.

### Feature checklist
- Can this be added within one feature folder?
- Is this behavior used by a second feature, or is sharing premature?
- Are tuning values owned by the scene instance or a data Resource?
- Does the owning parent receive progress through signals instead of reaching into
  another feature's nodes?

## Refactor status
- Complete: wave_manager.gd lives in features/spawning/, accepts a list of enemy scenes
  and configurable wave sizes, and emits progress and completion signals. The barracks
  level owns the generic defeated/total counter and victory response.
- Remaining from the initial snapshot: barracks.tscn builds Player, HUD and camera limits
  (1200x600) inline. Some ext_resources lack uids (re-save in Godot before moving files).
- terry.gd still hardcodes barracks bounds, randomises its own position in _ready (would
  override spawn points), uses manual texture/frame animation, and has configurable health
  (one hit by default).


