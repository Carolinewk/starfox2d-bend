# app_starfox_2d.bend
# ====================
# A pure Bend browser shooter inspired by the JavaScript Starfox 2D prototype.

import /U32/show as show_u32

# Types
# -----

type Pos {
  pos{x: U32, y: U32}
}

type DirX {
  left{}
  stay{}
  right{}
}

type Enemy {
  enemy{
    id: U32,
    x: U32,
    y: U32,
    hp: U32,
    fire: U32,
    dir: DirX,
    span: U32,
    step: U32,
    kind: U32
  }
}

type PlayerShot {
  pshot{x: U32, y: U32, dir: DirX, damage: U32}
}

type EnemyShot {
  eshot{x: U32, y: U32, dir: DirX, boss: U32}
}

type Ring {
  ring{x: U32, y: U32, spin: U32}
}

type Gate {
  no_gate{}
  gate{x: U32, y: U32, gap: U32, min_gap: U32, close: U32, hit: U32}
}

type Boss {
  no_boss{}
  boss{x: U32, y: U32, hp: U32, max_hp: U32, fire: U32, dir: DirX, drift: U32}
}

type ShotPack {
  shot_pack{shots: List(PlayerShot), seed: U32}
}

type ChoicePack {
  choice_pack{a: U32, b: U32, c: U32, seed: U32}
}

type StarfoxEvent {
  tick{}
  move_tick{}
  move_left{}
  move_right{}
  move_up{}
  move_down{}
  fire{}
  restart{}
  choose_1{}
  choose_2{}
  choose_3{}
  ignore{}
}

type Game {
  game{
    mode: U32,
    reason: U32,
    seed: U32,
    tick_no: U32,
    next_id: U32,
    score: U32,
    best: U32,
    sector: U32,
    level: U32,
    xp: U32,
    xp_next: U32,
    pending_upgrades: U32,
    choice_a: U32,
    choice_b: U32,
    choice_c: U32,
    toast_kind: U32,
    toast_value: U32,
    toast_ttl: U32,
    player_x: U32,
    player_y: U32,
    player_hp: U32,
    player_max_hp: U32,
    player_damage: U32,
    player_speed: U32,
    move_h: U32,
    move_v: U32,
    move_h_ttl: U32,
    move_v_ttl: U32,
    fire_cd: U32,
    fire_rate: U32,
    bullet_step: U32,
    spread: U32,
    pierce: U32,
    shield: U32,
    invuln: U32,
    enemy_timer: U32,
    ring_timer: U32,
    gate_timer: U32,
    boss_timer: U32,
    kills: U32,
    bosses: U32,
    hull_up: U32,
    damage_up: U32,
    thruster_up: U32,
    loader_up: U32,
    wing_up: U32,
    pierce_up: U32,
    shield_up: U32,
    rail_up: U32,
    repair_up: U32,
    shots: List(PlayerShot),
    enemy_shots: List(EnemyShot),
    enemies: List(Enemy),
    rings: List(Ring),
    gate: Gate,
    boss: Boss
  }
}

# Board
# -----

board_w : U32 =
  60

board_h : U32 =
  44

tick_ms : U32 =
  120

move_tick_ms : U32 =
  50

move_hold_ticks : U32 =
  5

player_start_hp : U32 =
  100

player_hull_cap : U32 =
  120

player_w : U32 =
  5

player_h : U32 =
  4

enemy_w : U32 =
  3

enemy_h : U32 =
  2

boss_w : U32 =
  11

boss_h : U32 =
  5

player_min_x : U32 =
  1

player_max_x : U32 =
  board_w - player_w - 1

player_min_y : U32 =
  board_h / 2

player_max_y : U32 =
  board_h - player_h - 1

boss_target_y : U32 =
  3

boss_spawn_ticks : U32 =
  500

level_xp_base : U32 =
  90

level_xp_step : U32 =
  40

def player_start_x() -> U32:
  (board_w - player_w) / 2

def player_start_y() -> U32:
  board_h - player_h - 3

# Theme
# -----

def starfox_css() -> String:
  ":root{--bg:#07111e;--bg-soft:#0c1727;--panel:#0e1b2d;--panel-soft:rgba(14,27,45,0.94);--border:#e6be59;--border-soft:rgba(230,190,89,0.45);--text-main:#eef5ff;--text-soft:#9fb0c8;--accent:#7be3ff;--danger:#ff9464;--ok:#85f0cf;}"
  ++ "*{box-sizing:border-box;}"
  ++ "body{margin:0;min-height:100svh;font-family:'Trebuchet MS',Verdana,sans-serif;color:var(--text-main);background:linear-gradient(180deg,#0c1828 0%,#07111e 100%);}"
  ++ ".page{min-height:100svh;padding:8px 12px;display:flex;align-items:stretch;justify-content:flex-start;}"
  ++ ".layout{width:100%;min-height:calc(100svh - 16px);display:grid;grid-template-columns:minmax(220px,250px) minmax(0,1fr);gap:12px;align-items:start;}"
  ++ ".leaderboard,.screen-frame,.control-deck{background:var(--panel-soft);border:2px solid var(--border);box-shadow:0 26px 80px rgba(0,0,0,0.34);}.shell.upgrade .leaderboard,.shell.upgrade .screen-frame,.shell.upgrade .control-deck{border-color:#ffd67c;}.shell.over .leaderboard,.shell.over .screen-frame,.shell.over .control-deck{border-color:#ff9b72;}"
  ++ ".leaderboard{padding:12px;display:grid;align-content:start;gap:12px;}.panel-label{margin:0;text-transform:uppercase;letter-spacing:0.16em;font-size:0.72rem;color:var(--accent);}.leaderboard-list{margin:0;padding:0;list-style:none;display:grid;gap:8px;}.leaderboard-item,.leaderboard-empty{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:10px 12px;border:1px solid var(--border-soft);background:rgba(7,17,30,0.92);}.leaderboard-rank{color:var(--accent);text-transform:uppercase;letter-spacing:0.12em;font-size:0.68rem;}.leaderboard-score{color:var(--text-main);font-family:'Lucida Console','Courier New',monospace;font-size:0.9rem;text-align:right;}.sidebar_cards{display:grid;gap:10px;}"
  ++ ".card{padding:12px;border:1px solid var(--border-soft);background:rgba(7,17,30,0.92);display:grid;gap:8px;}.card_title{font-size:0.7rem;letter-spacing:0.16em;text-transform:uppercase;color:#7be3ff;}.card_body{font-size:0.84rem;line-height:1.55;color:#c0cfdd;}.buildline{display:flex;justify-content:space-between;gap:10px;color:#e8f0f8;font-family:'Lucida Console','Courier New',monospace;font-size:0.8rem;}.buildline span:last-child{color:#ffe29a;}"
  ++ ".cabinet{display:grid;justify-self:center;justify-items:stretch;align-content:start;gap:10px;width:max-content;max-width:100%;}.screen-frame{width:max-content;max-width:100%;padding:10px;display:grid;gap:10px;}.frame-top{display:flex;align-items:stretch;gap:8px;}.mission-strip{flex:1;display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px;}.hud-chip{display:grid;gap:6px;padding:9px 10px;border:1px solid var(--border-soft);background:rgba(7,17,30,0.92);}.hud-chip span{color:var(--text-soft);text-transform:uppercase;letter-spacing:0.14em;font-size:0.62rem;}.hud-value{color:var(--text-main);font-family:'Lucida Console','Courier New',monospace;font-size:0.92rem;line-height:1.2;}.hud-value.accent{color:var(--accent);}.hud-value.warn{color:#ffe29a;}.hud-value.danger{color:#ffb49c;}.system-pill{width:52px;min-width:52px;border:1px solid var(--border-soft);background:rgba(7,17,30,0.92);display:grid;place-items:center;font-family:'Lucida Console','Courier New',monospace;font-size:0.66rem;letter-spacing:0.16em;text-transform:uppercase;color:var(--accent);}.shell.upgrade .system-pill{color:#ffe29a;}.shell.over .system-pill{color:#ffb49c;}"
  ++ ".health-panel{display:grid;gap:8px;}.health-meta{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;}.health-tag{color:var(--accent);text-transform:uppercase;letter-spacing:0.14em;font-size:0.68rem;font-family:'Lucida Console','Courier New',monospace;}.health-readout{color:#fff4cd;font-family:'Lucida Console','Courier New',monospace;font-size:0.9rem;}.health-track{height:18px;padding:2px;border:1px solid var(--border-soft);background:rgba(7,17,30,0.92);overflow:hidden;}.health-fill{height:100%;background:linear-gradient(90deg,#85f0cf 0%,#ffe29a 58%,#ff9464 100%);box-shadow:0 0 16px rgba(123,227,255,0.24);}"
  ++ ".screen-surface{position:relative;display:inline-flex;max-width:100%;overflow:hidden;border:1px solid rgba(255,255,255,0.06);background:linear-gradient(180deg,#05070d 0%,#07111e 100%);}.screen-surface::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 50% 0%,rgba(123,227,255,0.16),transparent 34%),linear-gradient(180deg,rgba(255,255,255,0.04),transparent 28%);pointer-events:none;z-index:1;}.board_wrap{position:relative;z-index:2;display:inline-flex;padding:8px;border-radius:16px;background:rgba(4,8,14,0.92);box-shadow:inset 0 0 28px rgba(0,0,0,0.42);}.board{display:inline-flex;flex-direction:column;gap:1px;}.row{display:flex;gap:1px;}.cell{width:clamp(13px,1.15vw,14px);height:clamp(13px,1.15vw,14px);border-radius:3px;background:#08121a;}"
  ++ ".cell.wall{background:linear-gradient(180deg,#32465b,#1a2733);}.cell.lane{background:linear-gradient(180deg,#0f1d29,#0a151d);}.cell.star{background:radial-gradient(circle,#b8eeff 0 22%,transparent 24%),#08121a;}.cell.nebula{background:linear-gradient(180deg,#11253a,#08121a);}.cell.player-wing{background:linear-gradient(180deg,#75ecff,#1b9eb3);}.cell.player-core{background:linear-gradient(180deg,#fff7c3,#4ff0d7 42%,#0b9b88);box-shadow:0 0 12px rgba(79,240,215,0.24);}.cell.player-cockpit{background:linear-gradient(180deg,#f6fbff,#89b6ff);}.cell.player-thruster{background:linear-gradient(180deg,#ffd67a,#ff7c3d);}.cell.enemy-a{background:linear-gradient(180deg,#ffd471,#ef7f41);box-shadow:0 0 12px rgba(239,127,65,0.24);}.cell.enemy-b{background:linear-gradient(180deg,#86f4ff,#2f9fd6);box-shadow:0 0 12px rgba(47,159,214,0.22);}.cell.boss-core{background:linear-gradient(180deg,#fff0a5,#ff9e3d 42%,#a63447);box-shadow:0 0 16px rgba(255,158,61,0.24);}.cell.boss-wing{background:linear-gradient(180deg,#b07dff,#5b6be0 44%,#26315d);}.cell.ring{background:radial-gradient(circle at 50% 50%,transparent 0 28%,#fff4ba 30% 46%,#ffcb68 52% 72%,transparent 74%),#08121a;}.cell.shot{background:radial-gradient(circle at 50% 50%,#fcffff 0 24%,#8ce5ff 28% 54%,rgba(140,229,255,0.2) 62%,transparent 70%),#08121a;border-radius:999px;box-shadow:0 0 10px rgba(140,229,255,0.32);}.cell.enemy-shot{background:radial-gradient(circle at 50% 50%,#fff3bf 0 24%,#ffb35a 30% 56%,rgba(255,122,54,0.24) 64%,transparent 72%),#08121a;border-radius:999px;box-shadow:0 0 10px rgba(255,148,74,0.3);}.cell.enemy-shot.boss{background:radial-gradient(circle at 50% 50%,#fff0c2 0 24%,#ff9442 30% 56%,rgba(146,33,58,0.34) 64%,transparent 72%),#08121a;border-radius:999px;box-shadow:0 0 12px rgba(255,108,72,0.34);}.cell.gate{background:linear-gradient(180deg,#30436d,#213252);}.cell.gate-edge{background:linear-gradient(180deg,#ffd36a,#ff8d36);}.cell.shield{background:radial-gradient(circle,#dffbff 0 24%,#87ecff 28%,#167fa4 100%);}"
  ++ ".scanlines{position:absolute;inset:0;background:repeating-linear-gradient(180deg,rgba(255,255,255,0.035) 0,rgba(255,255,255,0.035) 2px,transparent 2px,transparent 5px);mix-blend-mode:screen;opacity:0.3;pointer-events:none;z-index:3;}.screen_overlay{position:absolute;inset:0;padding:12px;display:grid;place-items:center;z-index:4;pointer-events:none;}.overlay_empty{display:none;}.overlay{max-width:min(100%,420px);padding:16px;border-radius:22px;background:rgba(7,17,30,0.95);border:1px solid rgba(230,190,89,0.32);box-shadow:0 22px 50px rgba(0,0,0,0.48);display:grid;gap:12px;pointer-events:auto;}.overlay_title{font-size:1.5rem;line-height:1;color:#fff6d4;font-family:Impact,Haettenschweiler,'Arial Narrow Bold',sans-serif;letter-spacing:0.05em;text-align:center;}.overlay_sub{font-size:0.82rem;line-height:1.55;color:#a6c0cb;text-align:center;}.choices{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;}.choice{border:1px solid var(--border-soft);padding:14px;background:rgba(7,17,30,0.92);color:var(--text-main);text-align:left;display:grid;gap:8px;cursor:pointer;}.choice_num{font-size:0.68rem;letter-spacing:0.16em;text-transform:uppercase;color:#ffe29a;}.choice_title{font-size:1rem;line-height:1;color:#fff6d4;font-family:Impact,Haettenschweiler,'Arial Narrow Bold',sans-serif;}.choice_copy{font-size:0.78rem;line-height:1.5;color:#abc3cf;}"
  ++ ".cabinet-footer{display:flex;justify-content:space-between;gap:10px;align-items:center;flex-wrap:wrap;}.toast{min-height:18px;font-size:0.72rem;line-height:1.5;color:#ffe29a;letter-spacing:0.08em;text-transform:uppercase;}.legend{font-size:0.72rem;line-height:1.5;color:var(--text-soft);text-align:left;}"
  ++ ".control-deck{width:100%;max-width:100%;padding:8px 10px;display:grid;gap:8px;}.controls{display:flex;gap:8px;flex-wrap:wrap;justify-content:center;}.btn{min-width:84px;padding:10px 12px;border:1px solid var(--border-soft);background:rgba(7,17,30,0.92);color:var(--text-main);font-family:'Lucida Console','Courier New',monospace;font-size:0.78rem;letter-spacing:0.08em;text-transform:uppercase;cursor:pointer;}.left,.right{color:#8ddfff;border-color:rgba(123,227,255,0.4);}.up,.down{color:#a5f4dd;border-color:rgba(133,240,207,0.36);}.fire{color:#ffe29a;border-color:rgba(255,214,124,0.52);}.reset{color:#ffba9a;border-color:rgba(255,148,100,0.42);}.hint{font-size:0.74rem;line-height:1.45;color:var(--text-soft);text-align:center;}"
  ++ "@media (max-width: 1120px){body{overflow:auto;}.page{overflow:auto;}.layout{grid-template-columns:1fr;}.leaderboard{max-width:none;}.frame-top{align-items:start;}.cabinet{width:max-content;}}"
  ++ "@media (max-width: 560px){.page{padding:6px;}.layout{min-height:auto;gap:10px;}.leaderboard,.screen-frame,.control-deck{padding:8px;}.mission-strip{grid-template-columns:1fr;}.system-pill{width:42px;min-width:42px;}.screen_overlay{padding:8px;}.choices{grid-template-columns:1fr;}.btn{flex:1 1 108px;}}"

# Small helpers
# -------------

def txt(value: String) -> HTML(StarfoxEvent):
  text{value}

def empty_htmls() -> List(HTML(StarfoxEvent)):
  []

def cons_html(head: HTML(StarfoxEvent), tail: List(HTML(StarfoxEvent))) -> List(HTML(StarfoxEvent)):
  head<>tail

def empty_player_shots() -> List(PlayerShot):
  []

def empty_enemy_shots() -> List(EnemyShot):
  []

def empty_enemies() -> List(Enemy):
  []

def empty_rings() -> List(Ring):
  []

def gate_none() -> Gate:
  no_gate{}

def boss_none() -> Boss:
  no_boss{}

def mk_gate_state(x: U32, y: U32, gap: U32, min_gap: U32, close: U32, hit: U32) -> Gate:
  gate{x, y, gap, min_gap, close, hit}

def mk_boss_state(x: U32, y: U32, hp: U32, max_hp: U32, fire: U32, dir: DirX, drift: U32) -> Boss:
  boss{x, y, hp, max_hp, fire, dir, drift}

def choice_pack_a(pack: ChoicePack) -> U32:
  match pack:
    case choice_pack{a, b, c, seed}:
      a

def choice_pack_b(pack: ChoicePack) -> U32:
  match pack:
    case choice_pack{a, b, c, seed}:
      b

def choice_pack_c(pack: ChoicePack) -> U32:
  match pack:
    case choice_pack{a, b, c, seed}:
      c

def choice_pack_seed(pack: ChoicePack) -> U32:
  match pack:
    case choice_pack{a, b, c, seed}:
      seed

def mk_pos(x: U32, y: U32) -> Pos:
  pos{x, y}

def pos_x(p: Pos) -> U32:
  match p:
    case pos{x, y}:
      x

def pos_y(p: Pos) -> U32:
  match p:
    case pos{x, y}:
      y

def u32_dec(n: U32) -> U32:
  match n === 0:
    case 0:
      n - 1
    case _:
      0

def u32_sub_sat(a: U32, b: U32) -> U32:
  match a <= b:
    case 0:
      a - b
    case _:
      0

def u32_min(a: U32, b: U32) -> U32:
  match a < b:
    case 0:
      b
    case _:
      a

def u32_max(a: U32, b: U32) -> U32:
  match a < b:
    case 0:
      a
    case _:
      b

def abs_diff(a: U32, b: U32) -> U32:
  match a < b:
    case 0:
      a - b
    case _:
      b - a

def clamp(value: U32, min: U32, max: U32) -> U32:
  u32_max(min, u32_min(max, value))

def pick_string(flag: U32, off: String, on: String) -> String:
  match flag:
    case 0:
      off
    case _:
      on

def empty_string() -> String:
  ""

def add_score(score: U32, delta: U32) -> U32:
  score + delta

def sub_score(score: U32, delta: U32) -> U32:
  u32_sub_sat(score, delta)

def xp_need(level: U32) -> U32:
  level_xp_base + ((level - 1) * level_xp_step)

def rng_next(seed: U32) -> U32:
  (seed * 1664525) + 1013904223

def rng_mod(seed: U32, bound: U32) -> U32:
  match bound === 0:
    case 0:
      rng_next(seed) % bound
    case _:
      0

def dir_dx(dir: DirX, x: U32) -> U32:
  match dir:
    case left{}:
      u32_sub_sat(x, 1)
    case stay{}:
      x
    case right{}:
      x + 1

def dir_left() -> DirX:
  left{}

def dir_right() -> DirX:
  right{}

def dir_stay() -> DirX:
  stay{}

def dir_flip(dir: DirX) -> DirX:
  match dir:
    case left{}:
      dir_right()
    case right{}:
      dir_left()
    case stay{}:
      dir_stay()

def gate_exists(g: Gate) -> U32:
  match g:
    case no_gate{}:
      0
    case gate{x, y, gap, min_gap, close, hit}:
      1

def boss_exists(b: Boss) -> U32:
  match b:
    case no_boss{}:
      0
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      1

def mode_is_running(mode: U32) -> U32:
  mode === 1

def mode_is_upgrade(mode: U32) -> U32:
  mode === 2

def mode_is_over(mode: U32) -> U32:
  mode === 3

def player_immortal() -> U32:
  0

# Game construction
# -----------------

def mission_ready() -> U32:
  1

def toast_engage() -> U32:
  2

def toast_ring() -> U32:
  3

def toast_gate() -> U32:
  4

def toast_gate_clear() -> U32:
  5

def toast_gate_crush() -> U32:
  6

def toast_shield() -> U32:
  7

def toast_escape() -> U32:
  8

def toast_boss_in() -> U32:
  9

def toast_boss_down() -> U32:
  10

def toast_upgrade_prompt() -> U32:
  11

def toast_upgrade_online() -> U32:
  12

def toast_hull_breach() -> U32:
  13

def toast_boss_barrage() -> U32:
  14

def toast_boss_impact() -> U32:
  15

def toast_enemy_down() -> U32:
  16

def mk_game(
  mode: U32,
  reason: U32,
  seed: U32,
  tick_no: U32,
  next_id: U32,
  score: U32,
  best: U32,
  sector: U32,
  level: U32,
  xp: U32,
  xp_next: U32,
  pending_upgrades: U32,
  choice_a: U32,
  choice_b: U32,
  choice_c: U32,
  toast_kind: U32,
  toast_value: U32,
  toast_ttl: U32,
  player_x: U32,
  player_y: U32,
  player_hp: U32,
  player_max_hp: U32,
  player_damage: U32,
  player_speed: U32,
  move_h: U32,
  move_v: U32,
  move_h_ttl: U32,
  move_v_ttl: U32,
  fire_cd: U32,
  fire_rate: U32,
  bullet_step: U32,
  spread: U32,
  pierce: U32,
  shield: U32,
  invuln: U32,
  enemy_timer: U32,
  ring_timer: U32,
  gate_timer: U32,
  boss_timer: U32,
  kills: U32,
  bosses: U32,
  hull_up: U32,
  damage_up: U32,
  thruster_up: U32,
  loader_up: U32,
  wing_up: U32,
  pierce_up: U32,
  shield_up: U32,
  rail_up: U32,
  repair_up: U32,
  shots: List(PlayerShot),
  enemy_shots: List(EnemyShot),
  enemies: List(Enemy),
  rings: List(Ring),
  gate: Gate,
  boss: Boss
) -> Game:
  game{
    mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
    pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
    player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
    move_h, move_v, move_h_ttl, move_v_ttl,
    fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
    enemy_timer, ring_timer, gate_timer, boss_timer,
    kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
    shots, enemy_shots, enemies, rings, gate, boss
  }

def game_reset(best: U32) -> Game:
  mk_game(
    0, 0, 7, 0, 1, 0, best, 1, 1, 0, xp_need(1), 0, 8, 0, 0,
    mission_ready(), 0, 999,
    player_start_x(), player_start_y(), player_start_hp, player_start_hp, 1, 1, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0,
    12, 34, 128, boss_spawn_ticks,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    empty_player_shots(), empty_enemy_shots(), empty_enemies(), empty_rings(), gate_none(), boss_none()
  )

def game_init() -> Game:
  game_reset(0)

def game_start_from(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_engage(), 0, 10,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

# Input
# -----

def evt_tick() -> StarfoxEvent:
  tick{}

def evt_move_tick() -> StarfoxEvent:
  move_tick{}

def evt_move_left() -> StarfoxEvent:
  move_left{}

def evt_move_right() -> StarfoxEvent:
  move_right{}

def evt_move_up() -> StarfoxEvent:
  move_up{}

def evt_move_down() -> StarfoxEvent:
  move_down{}

def evt_fire() -> StarfoxEvent:
  fire{}

def evt_restart() -> StarfoxEvent:
  restart{}

def evt_choice_1() -> StarfoxEvent:
  choose_1{}

def evt_choice_2() -> StarfoxEvent:
  choose_2{}

def evt_choice_3() -> StarfoxEvent:
  choose_3{}

def evt_ignore() -> StarfoxEvent:
  ignore{}

def key_is_left(key: U32) -> U32:
  (key === 37) | (key === 65)

def key_is_up(key: U32) -> U32:
  (key === 38) | (key === 87)

def key_is_right(key: U32) -> U32:
  (key === 39) | (key === 68)

def key_is_down(key: U32) -> U32:
  (key === 40) | (key === 83)

def key_is_fire(key: U32) -> U32:
  (key === 32) | (key === 13) | (key === 70)

def key_is_restart(key: U32) -> U32:
  key === 82

def key_is_1(key: U32) -> U32:
  (key === 49) | (key === 97)

def key_is_2(key: U32) -> U32:
  (key === 50) | (key === 98)

def key_is_3(key: U32) -> U32:
  (key === 51) | (key === 99)

def starfox_key_evt(key: U32) -> StarfoxEvent:
  match key_is_1(key):
    case 0:
      starfox_key_evt_2(key)
    case _:
      evt_choice_1()

def starfox_key_evt_2(key: U32) -> StarfoxEvent:
  match key_is_2(key):
    case 0:
      starfox_key_evt_3(key)
    case _:
      evt_choice_2()

def starfox_key_evt_3(key: U32) -> StarfoxEvent:
  match key_is_3(key):
    case 0:
      starfox_key_evt_left(key)
    case _:
      evt_choice_3()

def starfox_key_evt_left(key: U32) -> StarfoxEvent:
  match key_is_left(key):
    case 0:
      starfox_key_evt_up(key)
    case _:
      evt_move_left()

def starfox_key_evt_up(key: U32) -> StarfoxEvent:
  match key_is_up(key):
    case 0:
      starfox_key_evt_right(key)
    case _:
      evt_move_up()

def starfox_key_evt_right(key: U32) -> StarfoxEvent:
  match key_is_right(key):
    case 0:
      starfox_key_evt_down(key)
    case _:
      evt_move_right()

def starfox_key_evt_down(key: U32) -> StarfoxEvent:
  match key_is_down(key):
    case 0:
      starfox_key_evt_fire(key)
    case _:
      evt_move_down()

def starfox_key_evt_fire(key: U32) -> StarfoxEvent:
  match key_is_fire(key):
    case 0:
      starfox_key_evt_restart(key)
    case _:
      evt_fire()

def starfox_key_evt_restart(key: U32) -> StarfoxEvent:
  match key_is_restart(key):
    case 0:
      evt_ignore()
    case _:
      evt_restart()

# Movement
# --------

def step_left_n(x: U32, n: U32) -> U32:
  match n === 0:
    case 0:
      step_left_n(u32_sub_sat(x, 1), n - 1)
    case _:
      x

def step_right_n(x: U32, n: U32) -> U32:
  match n === 0:
    case 0:
      step_right_n(x + 1, n - 1)
    case _:
      x

def step_up_n(y: U32, n: U32) -> U32:
  match n === 0:
    case 0:
      step_up_n(u32_sub_sat(y, 1), n - 1)
    case _:
      y

def step_down_n(y: U32, n: U32) -> U32:
  match n === 0:
    case 0:
      step_down_n(y + 1, n - 1)
    case _:
      y

def move_player_left(x: U32, speed: U32) -> U32:
  clamp(step_left_n(x, speed), player_min_x, player_max_x)

def move_player_right(x: U32, speed: U32) -> U32:
  clamp(step_right_n(x, speed), player_min_x, player_max_x)

def move_player_up(y: U32, speed: U32) -> U32:
  clamp(step_up_n(y, speed), player_min_y, player_max_y)

def move_player_down(y: U32, speed: U32) -> U32:
  clamp(step_down_n(y, speed), player_min_y, player_max_y)

# Entities
# --------

def enemy_x(enemy_: Enemy) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      x

def enemy_y(enemy_: Enemy) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      y

def enemy_hp(enemy_: Enemy) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      hp

def enemy_id(enemy_: Enemy) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      id

def enemy_kind(enemy_: Enemy) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      kind

def boss_hp(boss_: Boss) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      hp

def boss_max_hp(boss_: Boss) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      max_hp

def player_center_x(player_x: U32) -> U32:
  player_x + 2

def player_center_y(player_y: U32) -> U32:
  player_y + 1

def player_hitbox_has(player_x: U32, player_y: U32, x: U32, y: U32) -> U32:
  ((player_x + 1) <= x) & (x <= (player_x + 3)) & (player_y <= y) & (y <= (player_y + 2))

def enemy_hitbox_has(enemy_: Enemy, x: U32, y: U32) -> U32:
  match enemy_:
    case enemy{id, ex, ey, hp, fire, dir, span, step, kind}:
      (ex <= x) & (x <= (ex + 2)) & (ey <= y) & (y <= (ey + 1))

def boss_hitbox_has(boss_: Boss, x: U32, y: U32) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{bx, by, hp, max_hp, fire, dir, drift}:
      (bx <= x) & (x <= (bx + 10)) & (by <= y) & (y <= (by + 4))

def ring_has_cell(ring_: Ring, x: U32, y: U32) -> U32:
  match ring_:
    case ring{rx, ry, spin}:
      dx = abs_diff(x, rx);
      dy = abs_diff(y, ry);
      ((dx === 0) & (dy === 2))
      | ((dx === 2) & (dy === 0))
      | ((dx === 1) & (dy === 2))
      | ((dx === 2) & (dy === 1))
      | ((dx === 1) & (dy === 0))
      | ((dx === 0) & (dy === 1))

def ring_collect(ring_: Ring, px: U32, py: U32) -> U32:
  match ring_:
    case ring{rx, ry, spin}:
      (abs_diff(player_center_x(px), rx) <= 1) & (abs_diff(player_center_y(py), ry) <= 1)

def gate_has_cell(gate_: Gate, x: U32, y: U32) -> U32:
  match gate_:
    case no_gate{}:
      0
    case gate{gx, gy, gap, min_gap, close, hit}:
      top = gy;
      bot = gy + 1;
      gap_left = gx;
      gap_right = gx + gap - 1;
      in_row = (y === top) | (y === bot);
      match in_row:
        case 0:
          0
        case _:
          (x < gap_left) | (gap_right < x)

def gate_edge_cell(gate_: Gate, x: U32, y: U32) -> U32:
  match gate_:
    case no_gate{}:
      0
    case gate{gx, gy, gap, min_gap, close, hit}:
      top = gy;
      bot = gy + 1;
      gap_left = gx;
      gap_right = gx + gap - 1;
      in_row = (y === top) | (y === bot);
      match in_row:
        case 0:
          0
        case _:
          (x === u32_sub_sat(gap_left, 1)) | (x === (gap_right + 1))

def gate_hits_player(gate_: Gate, px: U32, py: U32) -> U32:
  match gate_:
    case no_gate{}:
      0
    case gate{gx, gy, gap, min_gap, close, hit}:
      player_left = px + 1;
      player_right = px + 3;
      gate_top = gy;
      gate_bottom = gy + 1;
      gap_left = gx;
      gap_right = gx + gap - 1;
      overlap_y = (py <= gate_bottom) & (gate_top <= (py + 2));
      match overlap_y:
        case 0:
          0
        case _:
          (player_left < gap_left) | (gap_right < player_right)

def player_has_cell(player_x: U32, player_y: U32, x: U32, y: U32) -> U32:
  row = u32_sub_sat(y, player_y);
  col = u32_sub_sat(x, player_x);
  match (player_y <= y) & (y <= (player_y + 3)) & (player_x <= x) & (x <= (player_x + 4)):
    case 0:
      0
    case _:
      player_shape_has(row, col)

def player_shape_has(row: U32, col: U32) -> U32:
  ((row === 0) & (col === 2))
  | ((row === 1) & ((col === 1) | ((col === 2) | (col === 3))))
  | ((row === 2) & ((col === 0) | ((col === 1) | ((col === 2) | ((col === 3) | (col === 4))))))
  | ((row === 3) & ((col === 1) | (col === 3)))

def player_cell_cls(player_x: U32, player_y: U32, x: U32, y: U32) -> String:
  row = u32_sub_sat(y, player_y);
  col = u32_sub_sat(x, player_x);
  pick_string(
    (row === 0) & (col === 2),
    pick_string(
      row === 3,
      pick_string(col === 2, "cell player-wing", "cell player-core"),
      "cell player-thruster"
    ),
    "cell player-cockpit"
  )

def enemy_has_cell(enemy_: Enemy, x: U32, y: U32) -> U32:
  match enemy_:
    case enemy{id, ex, ey, hp, fire, dir, span, step, kind}:
      row = u32_sub_sat(y, ey);
      col = u32_sub_sat(x, ex);
      ((ey <= y) & (y <= (ey + 1)) & (ex <= x) & (x <= (ex + 2)))
      & enemy_shape_has(row, col)

def enemy_shape_has(row: U32, col: U32) -> U32:
  ((row === 0) & (col === 1))
  | ((row === 1) & ((col === 0) | ((col === 1) | (col === 2))))

def enemy_cell_cls(enemy_: Enemy) -> String:
  pick_string(enemy_kind(enemy_) === 0, "cell enemy-b", "cell enemy-a")

def boss_has_cell(boss_: Boss, x: U32, y: U32) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{bx, by, hp, max_hp, fire, dir, drift}:
      row = u32_sub_sat(y, by);
      col = u32_sub_sat(x, bx);
      ((by <= y) & (y <= (by + 4)) & (bx <= x) & (x <= (bx + 10)))
      & boss_shape_has(row, col)

def boss_shape_has(row: U32, col: U32) -> U32:
  ((row === 0) & ((2 <= col) & (col <= 8)))
  | ((row === 1) & ((1 <= col) & (col <= 9)))
  | ((row === 2) & ((0 <= col) & (col <= 10)))
  | ((row === 3) & ((2 <= col) & (col <= 8)))
  | ((row === 4) & ((3 <= col) & (col <= 7)))

def boss_cell_cls(row: U32, col: U32) -> String:
  pick_string((row === 2) & (3 <= col) & (col <= 7), "cell boss-wing", "cell boss-core")

def bg_is_wall(x: U32, y: U32) -> U32:
  (x === 0) | (x === (board_w - 1))

def bg_is_star(x: U32, y: U32, tick_no: U32) -> U32:
  (((x * 17) + (y * 29) + tick_no) % 23) === 0

def bg_is_nebula(x: U32, y: U32, tick_no: U32) -> U32:
  (((x * 11) + (y * 7) + (tick_no / 2)) % 19) === 0

def bg_is_lane(x: U32, y: U32, tick_no: U32) -> U32:
  (((y + tick_no) % 5) === 0) | ((((x * 2) + y + tick_no) % 17) === 0)

def bg_cell_cls(x: U32, y: U32, tick_no: U32) -> String:
  pick_string(
    bg_is_wall(x, y),
    pick_string(
      bg_is_star(x, y, tick_no),
      pick_string(
        bg_is_nebula(x, y, tick_no),
        pick_string(bg_is_lane(x, y, tick_no), "cell lane", "cell"),
        "cell nebula"
      ),
      "cell star"
    ),
    "cell wall"
  )

# Lists
# -----

def shot_cons(head: PlayerShot, tail: List(PlayerShot)) -> List(PlayerShot):
  head<>tail

def enemy_shot_cons(head: EnemyShot, tail: List(EnemyShot)) -> List(EnemyShot):
  head<>tail

def enemy_cons(head: Enemy, tail: List(Enemy)) -> List(Enemy):
  head<>tail

def ring_cons(head: Ring, tail: List(Ring)) -> List(Ring):
  head<>tail

def shots_len(xs: List(PlayerShot)) -> U32:
  match xs:
    case []:
      0
    case _<>rest:
      1 + shots_len(rest)

def enemies_len(xs: List(Enemy)) -> U32:
  match xs:
    case []:
      0
    case _<>rest:
      1 + enemies_len(rest)

def rings_len(xs: List(Ring)) -> U32:
  match xs:
    case []:
      0
    case _<>rest:
      1 + rings_len(rest)

def enemy_spawn_dir(seed: U32, id: U32) -> DirX:
  match rng_mod(seed + (id * 5), 2) === 0:
    case 0:
      dir_right()
    case _:
      dir_left()

# Spawning
# --------

def shot_from_spawn(x: U32, y: U32, dir: DirX, damage: U32) -> PlayerShot:
  pshot{x, y, dir, damage}

def mk_enemy(id: U32, x: U32, seed: U32) -> Enemy:
  fire = 10 + (rng_mod(seed + id, 10));
  span = 1 + (rng_mod(seed + (id * 3), 3));
  kind = rng_mod(seed + (id * 11), 2);
  dir = enemy_spawn_dir(seed, id);
  enemy{id, x, 1, 3, fire, dir, span, 0, kind}

def spawn_enemy(game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      seed1 = rng_next(seed);
      span = board_w - enemy_w - 2;
      ex = 1 + rng_mod(seed1, span);
      timer = u32_max(7, u32_sub_sat(15 + rng_mod(seed1 + 1, 7), sector / 4));
      enemy_ = mk_enemy(next_id, ex, seed1 + 3);
      mk_game(
        mode, reason, seed1 + 9, tick_no, next_id + 1, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemy_cons(enemy_, enemies), rings, gate, boss
      )

def spawn_ring(game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      seed1 = rng_next(seed);
      rx = 3 + rng_mod(seed1, board_w - 6);
      timer = 28 + rng_mod(seed1 + 1, 14);
      mk_game(
        mode, reason, seed1 + 5, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, ring_cons(ring{rx, 1, rng_mod(seed1 + 2, 8)}, rings), gate, boss
      )

def spawn_gate(game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      seed1 = rng_next(seed);
      gap = 10 + rng_mod(seed1, 3);
      gap_left = 2 + rng_mod(seed1 + 1, board_w - gap - 4);
      min_gap = 5 + rng_mod(seed1 + 2, 2);
      close = 1;
      timer = 108 + rng_mod(seed1 + 3, 40);
      mk_game(
        mode, reason, seed1 + 7, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_gate(), 0, 16,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, mk_gate_state(gap_left, 2, gap, min_gap, close, 0), boss
      )

def spawn_boss(game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      bx = (board_w - boss_w) / 2;
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_boss_in(), 0, 18,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_spawn_ticks,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, empty_rings(), gate_none(), mk_boss_state(bx, 0, 10, 10, 10, dir_right(), 0)
      )

# Firing
# ------

def pack_shots(shots: List(PlayerShot), seed: U32) -> ShotPack:
  shot_pack{shots, seed}

def spread_shots(player_x: U32, player_y: U32, damage: U32, spread: U32) -> List(PlayerShot):
  center = shot_from_spawn(player_x + 2, player_y, dir_stay(), damage);
  match spread === 0:
    case 0:
      spread_shots_one(center, player_x, player_y, damage, spread)
    case _:
      center<>empty_player_shots()

def spread_shots_one(center: PlayerShot, player_x: U32, player_y: U32, damage: U32, spread: U32) -> List(PlayerShot):
  left1 = shot_from_spawn(player_x + 1, player_y, dir_left(), damage);
  right1 = shot_from_spawn(player_x + 3, player_y, dir_right(), damage);
  match spread === 1:
    case 0:
      spread_shots_two(center, left1, right1, player_x, player_y, damage)
    case _:
      center<>left1<>right1<>empty_player_shots()

def spread_shots_two(center: PlayerShot, left1: PlayerShot, right1: PlayerShot, player_x: U32, player_y: U32, damage: U32) -> List(PlayerShot):
  left2 = shot_from_spawn(player_x + 0, player_y + 1, dir_left(), damage);
  right2 = shot_from_spawn(player_x + 4, player_y + 1, dir_right(), damage);
  center<>left1<>right1<>left2<>right2<>empty_player_shots()

def merge_shots(front: List(PlayerShot), back: List(PlayerShot)) -> List(PlayerShot):
  match front:
    case []:
      back
    case x<>rest:
      shot_cons(x, merge_shots(rest, back))

def fire_now(game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      match fire_cd === 0:
        case 0:
          got
        case _:
          volley = spread_shots(player_x, player_y, player_damage, spread);
          mk_game(
            mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
            pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
            player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
            move_h, move_v, move_h_ttl, move_v_ttl,
            fire_rate, fire_rate, bullet_step, spread, pierce, shield, invuln,
            enemy_timer, ring_timer, gate_timer, boss_timer,
            kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
            merge_shots(volley, shots), enemy_shots, enemies, rings, gate, boss
          )

def enemy_bullet(x: U32, y: U32, dir: DirX, boss: U32) -> EnemyShot:
  eshot{x, y, dir, boss}

def enemy_shots_merge(front: List(EnemyShot), back: List(EnemyShot)) -> List(EnemyShot):
  match front:
    case []:
      back
    case x<>rest:
      enemy_shot_cons(x, enemy_shots_merge(rest, back))

def enemy_target_dir(enemy_x: U32, player_x: U32) -> DirX:
  match (enemy_x + 1) < player_x:
    case 0:
      match player_x < enemy_x:
        case 0:
          dir_left()
        case _:
          dir_stay()
    case _:
      dir_right()

def enemy_fire_shots(enemy_: Enemy, player_x: U32) -> List(EnemyShot):
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      dir0 = enemy_target_dir(x + 1, player_center_x(player_x));
      enemy_bullet(x + 1, y + 1, dir0, 0)<>empty_enemy_shots()

def boss_fire_shots(boss_: Boss) -> List(EnemyShot):
  match boss_:
    case no_boss{}:
      empty_enemy_shots()
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      enemy_bullet(x + 1, y + 4, dir_left(), 1)
      <> enemy_bullet(x + 5, y + 4, dir_stay(), 1)
      <> enemy_bullet(x + 9, y + 4, dir_right(), 1)
      <> empty_enemy_shots()

# Collision counting
# ------------------

def shot_hits_enemy(shot_: PlayerShot, enemy_: Enemy) -> U32:
  match shot_:
    case pshot{x, y, dir, damage}:
      enemy_hitbox_has(enemy_, x, y)

def shot_hits_boss(shot_: PlayerShot, boss_: Boss) -> U32:
  match shot_:
    case pshot{x, y, dir, damage}:
      boss_hitbox_has(boss_, x, y)

def player_shot_damage(shot_: PlayerShot) -> U32:
  match shot_:
    case pshot{x, y, dir, damage}:
      damage

def count_damage_enemy(enemy_: Enemy, shots: List(PlayerShot)) -> U32:
  match shots:
    case []:
      0
    case shot_<>rest:
      match shot_hits_enemy(shot_, enemy_):
        case 0:
          count_damage_enemy(enemy_, rest)
        case _:
          player_shot_damage(shot_) + count_damage_enemy(enemy_, rest)

def count_damage_boss(boss_: Boss, shots: List(PlayerShot)) -> U32:
  match shots:
    case []:
      0
    case shot_<>rest:
      match shot_hits_boss(shot_, boss_):
        case 0:
          count_damage_boss(boss_, rest)
        case _:
          player_shot_damage(shot_) + count_damage_boss(boss_, rest)

def boss_apply_hits(boss_: Boss, damage: U32) -> Boss:
  match boss_:
    case no_boss{}:
      no_boss{}
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      boss{x, y, u32_sub_sat(hp, damage), max_hp, fire, dir, drift}

def enemy_dead_after(enemy_: Enemy, shots: List(PlayerShot)) -> U32:
  enemy_hp(enemy_) <= count_damage_enemy(enemy_, shots)

def enemy_any_hit(enemy_: Enemy, shots: List(PlayerShot)) -> U32:
  0 < count_damage_enemy(enemy_, shots)

def shot_hits_any_enemy(shot_: PlayerShot, enemies: List(Enemy)) -> U32:
  match enemies:
    case []:
      0
    case enemy_<>rest:
      match shot_hits_enemy(shot_, enemy_):
        case 0:
          shot_hits_any_enemy(shot_, rest)
        case _:
          1

def enemy_kill_count(enemies: List(Enemy), shots: List(PlayerShot)) -> U32:
  match enemies:
    case []:
      0
    case enemy_<>rest:
      match enemy_dead_after(enemy_, shots):
        case 0:
          enemy_kill_count(rest, shots)
        case _:
          1 + enemy_kill_count(rest, shots)

def enemy_survivors(enemies: List(Enemy), shots: List(PlayerShot)) -> List(Enemy):
  match enemies:
    case []:
      empty_enemies()
    case enemy_<>rest:
      match enemy_dead_after(enemy_, shots):
        case 0:
          enemy_keep(enemy_, shots, enemy_survivors(rest, shots))
        case _:
          enemy_survivors(rest, shots)

def enemy_keep(enemy_: Enemy, shots: List(PlayerShot), rest: List(Enemy)) -> List(Enemy):
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      damage = count_damage_enemy(enemy{id, x, y, hp, fire, dir, span, step, kind}, shots);
      enemy{id, x, y, u32_sub_sat(hp, damage), fire, dir, span, step, kind}<>rest

def consume_player_shots(shots: List(PlayerShot), enemies: List(Enemy), boss_: Boss, pierce: U32) -> List(PlayerShot):
  match shots:
    case []:
      empty_player_shots()
    case shot_<>rest:
      match shot_consumed(shot_, enemies, boss_, pierce):
        case 0:
          shot_cons(shot_, consume_player_shots(rest, enemies, boss_, pierce))
        case _:
          consume_player_shots(rest, enemies, boss_, pierce)

def shot_consumed(shot_: PlayerShot, enemies: List(Enemy), boss_: Boss, pierce: U32) -> U32:
  shot_hits_boss(shot_, boss_) | shot_hits_any_enemy(shot_, enemies)

def shot_hits_any(shot_: PlayerShot, enemies: List(Enemy), boss_: Boss) -> U32:
  shot_hits_boss(shot_, boss_) | shot_hits_any_enemy(shot_, enemies)

# Stepping projectiles
# -------------------

def move_player_shot_n(shot_: PlayerShot, step: U32) -> PlayerShot:
  match step === 0:
    case 0:
      move_player_shot_n(move_player_shot_once(shot_), step - 1)
    case _:
      shot_

def move_player_shot_once(shot_: PlayerShot) -> PlayerShot:
  match shot_:
    case pshot{x, y, dir, damage}:
      pshot{dir_dx(dir, x), u32_sub_sat(y, 1), dir, damage}

def shots_step(shots: List(PlayerShot), step: U32) -> List(PlayerShot):
  match shots:
    case []:
      empty_player_shots()
    case shot_<>rest:
      moved = move_player_shot_n(shot_, step);
      match player_shot_alive(moved):
        case 0:
          shot_cons(moved, shots_step(rest, step))
        case _:
          shots_step(rest, step)

def player_shot_alive(shot_: PlayerShot) -> U32:
  match shot_:
    case pshot{x, y, dir, damage}:
      (x === 0) | (x === (board_w - 1)) | (y === 0)

def enemy_shot_step(shots: List(EnemyShot)) -> List(EnemyShot):
  match shots:
    case []:
      empty_enemy_shots()
    case shot_<>rest:
      moved = move_enemy_shot_once(shot_);
      match enemy_shot_dead(moved):
        case 0:
          enemy_shot_cons(moved, enemy_shot_step(rest))
        case _:
          enemy_shot_step(rest)

def move_enemy_shot_once(shot_: EnemyShot) -> EnemyShot:
  match shot_:
    case eshot{x, y, dir, boss}:
      eshot{dir_dx(dir, x), y + 1, dir, boss}

def enemy_shot_dead(shot_: EnemyShot) -> U32:
  match shot_:
    case eshot{x, y, dir, boss}:
      ((board_w - 1) <= x) | (x === 0) | (y >= (board_h - 1))

# Enemy stepping
# --------------

def enemy_shift(enemy_: Enemy, descend: U32) -> Enemy:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      fire1 = u32_dec(fire);
      y1 = enemy_shift_y(y, descend);
      span_hit = span <= step;
      dir1 = enemy_span_dir(span_hit, dir);
      step1 = enemy_span_step(span_hit, step);
      x_try = dir_dx(dir1, x);
      x1 = clamp(x_try, 1, board_w - enemy_w - 1);
      enemy{id, x1, y1, hp, fire1, dir1, span, step1, kind}

def enemy_shift_y(y: U32, descend: U32) -> U32:
  match descend:
    case 0:
      y
    case _:
      y + 1

def enemy_span_dir(span_hit: U32, dir: DirX) -> DirX:
  match span_hit:
    case 0:
      dir
    case _:
      dir_flip(dir)

def enemy_span_step(span_hit: U32, step: U32) -> U32:
  match span_hit:
    case 0:
      step + 1
    case _:
      0

def enemies_step(enemies: List(Enemy), descend: U32) -> List(Enemy):
  match enemies:
    case []:
      empty_enemies()
    case enemy_<>rest:
      enemy_cons(enemy_shift(enemy_, descend), enemies_step(rest, descend))

def enemy_fires(enemy_: Enemy) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      fire === 0

def enemy_reset_fire(enemy_: Enemy) -> Enemy:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      enemy{id, x, y, hp, 10 + ((id + step + kind) % 10), dir, span, step, kind}

def collect_enemy_fires(enemies: List(Enemy), player_x: U32) -> List(EnemyShot):
  match enemies:
    case []:
      empty_enemy_shots()
    case enemy_<>rest:
      pack = collect_enemy_fires(rest, player_x);
      match enemy_fires(enemy_):
        case 0:
          pack
        case _:
          enemy_shots_merge(enemy_fire_shots(enemy_, player_x), pack)

def enemies_refresh_fire(enemies: List(Enemy)) -> List(Enemy):
  match enemies:
    case []:
      empty_enemies()
    case enemy_<>rest:
      match enemy_fires(enemy_):
        case 0:
          enemy_cons(enemy_, enemies_refresh_fire(rest))
        case _:
          enemy_cons(enemy_reset_fire(enemy_), enemies_refresh_fire(rest))

def enemies_remove_escaped(enemies: List(Enemy)) -> List(Enemy):
  match enemies:
    case []:
      empty_enemies()
    case enemy_<>rest:
      match enemy_escaped(enemy_):
        case 0:
          enemy_cons(enemy_, enemies_remove_escaped(rest))
        case _:
          enemies_remove_escaped(rest)

def enemy_escaped(enemy_: Enemy) -> U32:
  enemy_y(enemy_) >= (board_h - 1)

def enemies_escaped_count(enemies: List(Enemy)) -> U32:
  match enemies:
    case []:
      0
    case enemy_<>rest:
      match enemy_escaped(enemy_):
        case 0:
          enemies_escaped_count(rest)
        case _:
          1 + enemies_escaped_count(rest)

def enemy_hits_player(enemy_: Enemy, px: U32, py: U32) -> U32:
  match enemy_:
    case enemy{id, x, y, hp, fire, dir, span, step, kind}:
      ((x + 1) <= (px + 3)) & ((px + 1) <= (x + 3)) & (y <= (py + 2)) & (py <= (y + 2))

def enemies_hit_player(enemies: List(Enemy), px: U32, py: U32) -> U32:
  match enemies:
    case []:
      0
    case enemy_<>rest:
      match enemy_hits_player(enemy_, px, py):
        case 0:
          enemies_hit_player(rest, px, py)
        case _:
          1

def enemies_remove_colliders(enemies: List(Enemy), px: U32, py: U32) -> List(Enemy):
  match enemies:
    case []:
      empty_enemies()
    case enemy_<>rest:
      match enemy_hits_player(enemy_, px, py):
        case 0:
          enemy_cons(enemy_, enemies_remove_colliders(rest, px, py))
        case _:
          enemies_remove_colliders(rest, px, py)

# Rings and gates
# ---------------

def rings_step(rings: List(Ring)) -> List(Ring):
  match rings:
    case []:
      empty_rings()
    case ring_<>rest:
      match ring_:
        case ring{x, y, spin}:
          match y >= (board_h - 2):
            case 0:
              ring_cons(ring{x, y + 1, spin + 1}, rings_step(rest))
            case _:
              rings_step(rest)

def rings_collect_count(rings: List(Ring), px: U32, py: U32) -> U32:
  match rings:
    case []:
      0
    case ring_<>rest:
      match ring_collect(ring_, px, py):
        case 0:
          rings_collect_count(rest, px, py)
        case _:
          1 + rings_collect_count(rest, px, py)

def rings_keep_uncollected(rings: List(Ring), px: U32, py: U32) -> List(Ring):
  match rings:
    case []:
      empty_rings()
    case ring_<>rest:
      match ring_collect(ring_, px, py):
        case 0:
          ring_cons(ring_, rings_keep_uncollected(rest, px, py))
        case _:
          rings_keep_uncollected(rest, px, py)

def gate_step(gate_: Gate) -> Gate:
  match gate_:
    case no_gate{}:
      gate_none()
    case gate{x, y, gap, min_gap, close, hit}:
      gap1 = u32_max(min_gap, u32_sub_sat(gap, close));
      match y >= (board_h - 2):
        case 0:
          mk_gate_state(x, y + 1, gap1, min_gap, close, hit)
        case _:
          gate_none()

def gate_mark_hit(gate_: Gate) -> Gate:
  match gate_:
    case no_gate{}:
      gate_none()
    case gate{x, y, gap, min_gap, close, hit}:
      mk_gate_state(x, y, gap, min_gap, close, 1)

def gate_was_hit(gate_: Gate) -> U32:
  match gate_:
    case no_gate{}:
      0
    case gate{x, y, gap, min_gap, close, hit}:
      hit

# Boss
# ----

def boss_step(boss_: Boss) -> Boss:
  match boss_:
    case no_boss{}:
      boss_none()
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      fire1 = u32_dec(fire);
      match y < boss_target_y:
        case 0:
          boss_step_drift(x, y, hp, max_hp, fire1, dir, drift)
        case _:
          boss{x, y + 1, hp, max_hp, fire1, dir, drift}

def boss_step_drift(x: U32, y: U32, hp: U32, max_hp: U32, fire: U32, dir: DirX, drift: U32) -> Boss:
  hit_edge = (x <= 2) | ((board_w - boss_w - 2) <= x);
  dir1 = boss_dir_after_edge(hit_edge, dir);
  x1 = clamp(dir_dx(dir1, x), 1, board_w - boss_w - 1);
  mk_boss_state(x1, y, hp, max_hp, fire, dir1, drift + 1)

def boss_dir_after_edge(hit_edge: U32, dir: DirX) -> DirX:
  match hit_edge:
    case 0:
      dir
    case _:
      dir_flip(dir)

def boss_fires(boss_: Boss) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      (fire === 0) & (boss_target_y <= y)

def boss_reset_fire(boss_: Boss) -> Boss:
  match boss_:
    case no_boss{}:
      boss_none()
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      mk_boss_state(x, y, hp, max_hp, 11, dir, drift)

def boss_hits_player(boss_: Boss, px: U32, py: U32) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      ((x + 2) <= (px + 3)) & ((px + 1) <= (x + 8)) & (y <= (py + 2)) & (py <= (y + 4))

# Damage and progression
# ----------------------

def gain_xp(state: Game, amount: U32) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      gain_xp_loop(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp + amount, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def gain_xp_loop(
  mode: U32, reason: U32, seed: U32, tick_no: U32, next_id: U32, score: U32, best: U32, sector: U32,
  level: U32, xp: U32, xp_next: U32, pending_upgrades: U32, choice_a: U32, choice_b: U32, choice_c: U32,
  toast_kind: U32, toast_value: U32, toast_ttl: U32,
  player_x: U32, player_y: U32, player_hp: U32, player_max_hp: U32, player_damage: U32, player_speed: U32,
  move_h: U32,
  move_v: U32,
  move_h_ttl: U32,
  move_v_ttl: U32,
  fire_cd: U32, fire_rate: U32, bullet_step: U32, spread: U32, pierce: U32, shield: U32, invuln: U32,
  enemy_timer: U32, ring_timer: U32, gate_timer: U32, boss_timer: U32,
  kills: U32, bosses: U32, hull_up: U32, damage_up: U32, thruster_up: U32, loader_up: U32, wing_up: U32, pierce_up: U32, shield_up: U32, rail_up: U32, repair_up: U32,
  shots: List(PlayerShot), enemy_shots: List(EnemyShot), enemies: List(Enemy), rings: List(Ring), gate: Gate, boss: Boss
) -> Game:
  match xp < xp_next:
    case 0:
      gain_xp_loop(
        mode, reason, seed, tick_no, next_id, score, best, sector,
        level + 1, xp - xp_next, xp_need(level + 1), pending_upgrades + 1, choice_a, choice_b, choice_c,
        toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )
    case _:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def with_score(state: Game, score: U32) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, old_score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      best1 = u32_max(best, score);
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best1, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def set_toast(state: Game, toast_kind: U32, toast_value: U32, toast_ttl: U32) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, old_toast_kind, old_toast_value, old_toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def destroy_player(state: Game, reason: U32) -> Game:
  match state:
    case game{
      mode, old_reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        3, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        0, choice_a, choice_b, choice_c, reason, 0, 999,
        player_x, player_y, 0, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        0, fire_rate, bullet_step, spread, pierce, shield, 0,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        empty_player_shots(), empty_enemy_shots(), enemies, rings, gate, boss
      )

def take_hit(state: Game, damage: U32, penalty: U32, reason: U32) -> Game:
  match state:
    case game{
      mode, old_reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, old_reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      match invuln === 0:
        case 0:
          got
        case _:
          match player_immortal():
            case 0:
              match shield === 0:
                case 0:
                  state1 = mk_game(
                    mode, old_reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
                    pending_upgrades, choice_a, choice_b, choice_c, toast_shield(), 0, 12,
                    player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
                    move_h, move_v, move_h_ttl, move_v_ttl,
                    fire_cd, fire_rate, bullet_step, spread, pierce, shield - 1, 3,
                    enemy_timer, ring_timer, gate_timer, boss_timer,
                    kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
                    shots, enemy_shots, enemies, rings, gate, boss
                  );
                  state1
                case _:
                  hp1 = u32_sub_sat(player_hp, damage);
                  score1 = sub_score(score, penalty);
                  state1 = mk_game(
                    mode, old_reason, seed, tick_no, next_id, score1, best, sector, level, xp, xp_next,
                    pending_upgrades, choice_a, choice_b, choice_c, reason, 0, 14,
                    player_x, player_y, hp1, player_max_hp, player_damage, player_speed,
                    move_h, move_v, move_h_ttl, move_v_ttl,
                    fire_cd, fire_rate, bullet_step, spread, pierce, shield, 5,
                    enemy_timer, ring_timer, gate_timer, boss_timer,
                    kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
                    shots, enemy_shots, enemies, rings, gate, boss
                  );
                  match hp1 === 0:
                    case 0:
                      state1
                    case _:
                      destroy_player(state1, reason)
            case _:
              mk_game(
                mode, old_reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
                pending_upgrades, choice_a, choice_b, choice_c, reason, 0, 10,
                player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
                move_h, move_v, move_h_ttl, move_v_ttl,
                fire_cd, fire_rate, bullet_step, spread, pierce, shield, 4,
                enemy_timer, ring_timer, gate_timer, boss_timer,
                kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
                shots, enemy_shots, enemies, rings, gate, boss
              )

# Upgrades
# --------

def upgrade_name(id: U32) -> String:
  match id:
    case 0:
      "Reinforced Hull"
    case 1:
      "Plasma Cannons"
    case 2:
      "Ion Thrusters"
    case 3:
      "Rapid Loader"
    case 4:
      "Wing Cannons"
    case 5:
      "Piercing Rounds"
    case 6:
      "Shield Matrix"
    case 7:
      "Rail Slugs"
    case _:
      "Nano Repair"

def upgrade_desc(id: U32) -> String:
  match id:
    case 0:
      "+2 max hull and repair 2."
    case 1:
      "+1 damage per volley."
    case 2:
      "+1 movement per input."
    case 3:
      "Lower auto-fire delay."
    case 4:
      "More angled side shots."
    case 5:
      "Shots stop consuming on hit."
    case 6:
      "Gain 1 shield charge."
    case 7:
      "+1 bullet travel per tick."
    case _:
      "Repair 3 hull or add 1 max."

def upgrade_available_stats(
  id: U32,
  player_max_hp: U32,
  player_damage: U32,
  player_speed: U32,
  fire_rate: U32,
  spread: U32,
  pierce: U32,
  shield: U32,
  bullet_step: U32
) -> U32:
  match id:
    case 0:
      player_max_hp < player_hull_cap
    case 1:
      player_damage < 8
    case 2:
      player_speed < 3
    case 3:
      1 < fire_rate
    case 4:
      spread < 2
    case 5:
      pierce === 0
    case 6:
      shield < 4
    case 7:
      bullet_step < 3
    case _:
      1

def upgrade_available(id: U32, game_: Game) -> U32:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      upgrade_available_stats(
        id,
        player_max_hp,
        player_damage,
        player_speed,
        fire_rate,
        spread,
        pierce,
        shield,
        bullet_step
      )

def pick_upgrade_from(game_: Game, start: U32, avoid_a: U32, avoid_b: U32, fuel: U32) -> U32:
  match fuel === 0:
    case 0:
      id = start % 9;
      ok = upgrade_available(id, game_) & (id !== avoid_a) & (id !== avoid_b);
      match ok:
        case 0:
          pick_upgrade_from(game_, start + 1, avoid_a, avoid_b, fuel - 1)
        case _:
          id
    case _:
      8

def roll_choices(game_: Game) -> ChoicePack:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      seed1 = rng_next(seed);
      seed2 = rng_next(seed1);
      seed3 = rng_next(seed2);
      a = pick_upgrade_from(got, seed1, 99, 98, 9);
      b = pick_upgrade_from(got, seed2 + 1, a, 98, 9);
      c = pick_upgrade_from(got, seed3 + 2, a, b, 9);
      choice_pack{a, b, c, seed3}

def open_upgrade_if_needed(game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      match (mode === 1) & (0 < pending_upgrades):
        case 0:
          got
        case _:
          pack = roll_choices(got);
          a = choice_pack_a(pack);
          b = choice_pack_b(pack);
          c = choice_pack_c(pack);
          seed1 = choice_pack_seed(pack);
          mk_game(
            2, reason, seed1, tick_no, next_id, score, best, sector, level, xp, xp_next,
            pending_upgrades - 1, a, b, c, toast_upgrade_prompt(), level, 20,
            player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
            0, 0, 0, 0,
            fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
            enemy_timer, ring_timer, gate_timer, boss_timer,
            kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
            shots, enemy_shots, enemies, rings, gate, boss
          )

def apply_upgrade_id(
  id: U32,
  reason: U32,
  seed: U32,
  tick_no: U32,
  next_id: U32,
  score: U32,
  best: U32,
  sector: U32,
  level: U32,
  xp: U32,
  xp_next: U32,
  pending_upgrades: U32,
  choice_a: U32,
  choice_b: U32,
  choice_c: U32,
  player_x: U32,
  player_y: U32,
  player_hp: U32,
  player_max_hp: U32,
  player_damage: U32,
  player_speed: U32,
  move_h: U32,
  move_v: U32,
  move_h_ttl: U32,
  move_v_ttl: U32,
  fire_cd: U32,
  fire_rate: U32,
  bullet_step: U32,
  spread: U32,
  pierce: U32,
  shield: U32,
  invuln: U32,
  enemy_timer: U32,
  ring_timer: U32,
  gate_timer: U32,
  boss_timer: U32,
  kills: U32,
  bosses: U32,
  hull_up: U32,
  damage_up: U32,
  thruster_up: U32,
  loader_up: U32,
  wing_up: U32,
  pierce_up: U32,
  shield_up: U32,
  rail_up: U32,
  repair_up: U32,
  shots: List(PlayerShot),
  enemy_shots: List(EnemyShot),
  enemies: List(Enemy),
  rings: List(Ring),
  gate: Gate,
  boss: Boss
) -> Game:
  match id:
    case 0:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 0, 14,
        player_x, player_y, u32_min(player_max_hp + 2, player_hp + 2), player_max_hp + 2, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up + 1, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 1:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 1, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage + 1, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up + 1, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 2:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 2, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed + 1,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up + 1, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 3:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 3, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, u32_max(1, u32_sub_sat(fire_rate, 1)), bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up + 1, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 4:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 4, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread + 1, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up + 1, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 5:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 5, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, 1, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up + 1, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 6:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 6, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield + 1, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up + 1, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case 7:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 7, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step + 1, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up + 1, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      ))
    case _:
      open_upgrade_if_needed(mk_game(
        1, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_upgrade_online(), 8, 14,
        player_x, player_y, u32_min(player_max_hp + 1, player_hp + 3), u32_max(player_max_hp, player_hp + 1), player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up + 1,
        shots, enemy_shots, enemies, rings, gate, boss
      ))

def apply_upgrade(id: U32, game_: Game) -> Game:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      apply_upgrade_id(
        id,
        reason,
        seed,
        tick_no,
        next_id,
        score,
        best,
        sector,
        level,
        xp,
        xp_next,
        pending_upgrades,
        choice_a,
        choice_b,
        choice_c,
        player_x,
        player_y,
        player_hp,
        player_max_hp,
        player_damage,
        player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd,
        fire_rate,
        bullet_step,
        spread,
        pierce,
        shield,
        invuln,
        enemy_timer,
        ring_timer,
        gate_timer,
        boss_timer,
        kills,
        bosses,
        hull_up,
        damage_up,
        thruster_up,
        loader_up,
        wing_up,
        pierce_up,
        shield_up,
        rail_up,
        repair_up,
        shots,
        enemy_shots,
        enemies,
        rings,
        gate,
        boss
      )

# Tick
# ----

def tick_decay(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no + 1, next_id, score, best, (tick_no / 170) + 1, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, u32_dec(toast_ttl),
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        u32_dec(fire_cd), fire_rate, bullet_step, spread, pierce, shield, u32_dec(invuln),
        u32_dec(enemy_timer), u32_dec(ring_timer), u32_dec(gate_timer), u32_dec(boss_timer),
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def tick_spawn_phase(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      match boss_exists(boss):
        case 0:
          match boss_timer === 0:
            case 0:
              tick_spawn_misc(got)
            case _:
              spawn_boss(got)
        case _:
          got

def tick_spawn_misc(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      no_gate_now = gate_exists(gate) === 0;
      state1 = spawn_enemy_if((enemy_timer === 0) & no_gate_now, got);
      state2 = spawn_ring_if((ring_timer === 0) & no_gate_now, state1);
      spawn_gate_if((gate_timer === 0) & no_gate_now, state2)

def spawn_enemy_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      spawn_enemy(state)

def spawn_ring_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      spawn_ring(state)

def spawn_gate_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      spawn_gate(state)

def tick_move_phase(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      enemy_descend = (tick_no % 2) === 0;
      shots1 = shots_step(shots, bullet_step);
      enemy_shots1 = enemy_shot_step(enemy_shots);
      enemies1 = enemies_step(enemies, enemy_descend);
      enemy_fire_new = collect_enemy_fires(enemies1, player_x);
      enemies2 = enemies_refresh_fire(enemies1);
      gate1 = gate_step(gate);
      rings1 = rings_step(rings);
      boss1 = boss_step(boss);
      enemy_shots2 = enemy_shots_merge(enemy_fire_new, enemy_shots1);
      enemy_shots3 = enemy_shots_after_boss_fire(boss_fires(boss1), boss1, enemy_shots2);
      boss2 = boss_after_fire(boss_fires(boss1), boss1);
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots1, enemy_shots3, enemies2, rings1, gate1, boss2
      )

def enemy_shots_after_boss_fire(flag: U32, boss_: Boss, shots: List(EnemyShot)) -> List(EnemyShot):
  match flag:
    case 0:
      shots
    case _:
      enemy_shots_merge(boss_fire_shots(boss_), shots)

def boss_after_fire(flag: U32, boss_: Boss) -> Boss:
  match flag:
    case 0:
      boss_
    case _:
      boss_reset_fire(boss_)

def tick_combat_phase(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      kill_count = enemy_kill_count(enemies, shots);
      enemies1 = enemy_survivors(enemies, shots);
      boss_hits = count_damage_boss(boss, shots);
      boss1 = boss_apply_hits(boss, boss_hits);
      shots1 = consume_player_shots(shots, enemies, boss, pierce);
      state1 = mk_game(
        mode, reason, seed, tick_no, next_id, score + (kill_count * 140), best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills + kill_count, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots1, enemy_shots, enemies1, rings, gate, boss1
      );
      state2 = gain_xp(state1, (kill_count * 30) + boss_xp_gain(boss, boss1));
      state3 = with_score(state2, score_of(state2));
      state4 = boss_down_if(boss_dead_now(boss, boss1), state3);
      tick_collision_phase(state4)

def boss_down_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      boss_down_state(state)

def boss_dead_now(before: Boss, after: Boss) -> U32:
  match before:
    case no_boss{}:
      0
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      match after:
        case no_boss{}:
          0
        case boss{ax, ay, ahp, amax_hp, afire, adir, adrift}:
          (0 < hp) & (ahp === 0)

def boss_xp_gain(before: Boss, after: Boss) -> U32:
  match boss_dead_now(before, after):
    case 0:
      0
    case _:
      120

def boss_down_state(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score + 1000, u32_max(best, score + 1000), sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_boss_down(), 0, 18,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses + 1, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss_none()
      )

def score_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      score

def best_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      best

def enemy_shot_hits_player(shot_: EnemyShot, px: U32, py: U32) -> U32:
  match shot_:
    case eshot{x, y, dir, boss}:
      player_hitbox_has(px, py, x, y)

def enemy_shot_damage(shot_: EnemyShot) -> U32:
  match shot_:
    case eshot{x, y, dir, boss}:
      4

def enemy_shot_penalty(shot_: EnemyShot) -> U32:
  match shot_:
    case eshot{x, y, dir, boss}:
      match boss:
        case 0:
          18
        case _:
          45

def enemy_shots_keep(shots: List(EnemyShot), px: U32, py: U32) -> List(EnemyShot):
  match shots:
    case []:
      empty_enemy_shots()
    case shot_<>rest:
      match enemy_shot_hits_player(shot_, px, py):
        case 0:
          enemy_shot_cons(shot_, enemy_shots_keep(rest, px, py))
        case _:
          enemy_shots_keep(rest, px, py)

def first_hit_shot(shots: List(EnemyShot), px: U32, py: U32) -> EnemyShot:
  match shots:
    case []:
      eshot{0, 0, dir_stay(), 0}
    case shot_<>rest:
      match enemy_shot_hits_player(shot_, px, py):
        case 0:
          first_hit_shot(rest, px, py)
        case _:
          shot_

def any_enemy_shot_hit(shots: List(EnemyShot), px: U32, py: U32) -> U32:
  match shots:
    case []:
      0
    case shot_<>rest:
      match enemy_shot_hits_player(shot_, px, py):
        case 0:
          any_enemy_shot_hit(rest, px, py)
        case _:
          1

def tick_collision_phase(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      score1 = score + (rings_collect_count(rings, player_x, player_y) * 90);
      rings1 = rings_keep_uncollected(rings, player_x, player_y);
      state1 = with_score(mk_game(
        mode, reason, seed, tick_no, next_id, score1, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c,
        toast_kind_after_ring(rings, player_x, player_y, toast_kind), 0,
        toast_ttl_after_ring(rings, player_x, player_y, toast_ttl),
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings1, gate, boss
      ), score1);
      state2 = gate_hit_if(gate_hits_player(gate, player_x, player_y), state1);
      state3 = enemy_collision_if(enemies_hit_player(enemies_of(state2), player_x_of(state2), player_y_of(state2)), state2);
      state4 = boss_collision_if(boss_hits_player(boss_of(state3), player_x_of(state3), player_y_of(state3)), state3);
      state5 = enemy_shot_collision_if(any_enemy_shot_hit(enemy_shots_of(state4), player_x_of(state4), player_y_of(state4)), state4);
      escaped = enemies_escaped_count(enemies_of(state5));
      state6 = apply_escape_penalty(state5, escaped);
      open_upgrade_if_needed(state6)

def gate_hit_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      take_hit(with_gate_hit(state), 2, 120, toast_gate_crush())

def enemy_collision_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      take_hit(remove_enemy_colliders(state), 2, 30, toast_hull_breach())

def boss_collision_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      take_hit(state, 2, 45, toast_boss_impact())

def enemy_shot_collision_if(flag: U32, state: Game) -> Game:
  match flag:
    case 0:
      state
    case _:
      tick_collision_phase_shot(state)

def tick_collision_phase_shot(state: Game) -> Game:
  shot_ = first_hit_shot(enemy_shots_of(state), player_x_of(state), player_y_of(state));
  state1 = with_enemy_shots(state, enemy_shots_keep(enemy_shots_of(state), player_x_of(state), player_y_of(state)));
  take_hit(state1, enemy_shot_damage(shot_), enemy_shot_penalty(shot_), shot_reason(shot_))

def shot_reason(shot_: EnemyShot) -> U32:
  match shot_:
    case eshot{x, y, dir, boss}:
      match boss:
        case 0:
          toast_hull_breach()
        case _:
          toast_boss_barrage()

def toast_kind_after_ring(rings: List(Ring), px: U32, py: U32, old: U32) -> U32:
  match 0 < rings_collect_count(rings, px, py):
    case 0:
      old
    case _:
      toast_ring()

def toast_ttl_after_ring(rings: List(Ring), px: U32, py: U32, old: U32) -> U32:
  match 0 < rings_collect_count(rings, px, py):
    case 0:
      old
    case _:
      12

def enemies_of(state: Game) -> List(Enemy):
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      enemies

def enemy_shots_of(state: Game) -> List(EnemyShot):
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      enemy_shots

def boss_of(state: Game) -> Boss:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      boss

def player_x_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      player_x

def player_y_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      player_y

def shots_of(state: Game) -> List(PlayerShot):
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      shots

def rings_of(state: Game) -> List(Ring):
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      rings

def gate_of(state: Game) -> Gate:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      gate

def shield_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      shield

def invuln_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      invuln

def tick_no_of(state: Game) -> U32:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      tick_no

def with_enemy_shots(state: Game, enemy_shots: List(EnemyShot)) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, old_enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def with_gate_hit(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_gate_crush(), 0, 14,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate_mark_hit(gate), boss
      )

def remove_enemy_colliders(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies_remove_colliders(enemies, player_x, player_y), rings, gate, boss
      )

def apply_escape_penalty(state: Game, escaped: U32) -> Game:
  match escaped === 0:
    case 0:
      with_score(
        set_toast(
          with_enemies(state, enemies_remove_escaped(enemies_of(state))),
          toast_escape(),
          escaped,
          12
        ),
        sub_score(score_of(state), escaped * 70)
      )
    case _:
      state

def with_enemies(state: Game, enemies: List(Enemy)) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, old_enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def game_tick(game_: Game) -> Game:
  state0 = tick_decay(game_);
  state1 = tick_spawn_phase(state0);
  state2 = tick_move_phase(state1);
  tick_combat_phase(state2)

# Event updates
# -------------

def apply_movement(evt: StarfoxEvent, state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      x1 = movement_x(evt, player_x, player_speed);
      y1 = movement_y(evt, player_y, player_speed);
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        x1, y1, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def remember_move_h(evt: StarfoxEvent, move_h: U32) -> U32:
  match evt:
    case move_left{}:
      1
    case move_right{}:
      2
    case _:
      move_h

def remember_move_v(evt: StarfoxEvent, move_v: U32) -> U32:
  match evt:
    case move_up{}:
      1
    case move_down{}:
      2
    case _:
      move_v

def remember_move_h_ttl(evt: StarfoxEvent, move_h_ttl: U32) -> U32:
  match evt:
    case move_left{}:
      # Without key-up events, queuing held movement makes one tap drift.
      0
    case move_right{}:
      0
    case _:
      move_h_ttl

def remember_move_v_ttl(evt: StarfoxEvent, move_v_ttl: U32) -> U32:
  match evt:
    case move_up{}:
      0
    case move_down{}:
      0
    case _:
      move_v_ttl

def remember_move(evt: StarfoxEvent, state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        remember_move_h(evt, move_h), remember_move_v(evt, move_v),
        remember_move_h_ttl(evt, move_h_ttl), remember_move_v_ttl(evt, move_v_ttl),
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def held_move_speed(player_speed: U32) -> U32:
  u32_min(player_speed, 1)

def held_move_ready(ttl: U32) -> U32:
  (0 < ttl) & (ttl < move_hold_ticks)

def held_move_x_dir(move_h: U32, player_x: U32, player_speed: U32) -> U32:
  match move_h:
    case 1:
      move_player_left(player_x, held_move_speed(player_speed))
    case 2:
      move_player_right(player_x, held_move_speed(player_speed))
    case _:
      player_x

def held_move_x(move_h: U32, move_h_ttl: U32, player_x: U32, player_speed: U32) -> U32:
  match held_move_ready(move_h_ttl):
    case 0:
      player_x
    case _:
      held_move_x_dir(move_h, player_x, player_speed)

def held_move_y_dir(move_v: U32, player_y: U32, player_speed: U32) -> U32:
  match move_v:
    case 1:
      move_player_up(player_y, held_move_speed(player_speed))
    case 2:
      move_player_down(player_y, held_move_speed(player_speed))
    case _:
      player_y

def held_move_y(move_v: U32, move_v_ttl: U32, player_y: U32, player_speed: U32) -> U32:
  match held_move_ready(move_v_ttl):
    case 0:
      player_y
    case _:
      held_move_y_dir(move_v, player_y, player_speed)

def apply_held_movement(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      x1 = held_move_x(move_h, move_h_ttl, player_x, player_speed);
      y1 = held_move_y(move_v, move_v_ttl, player_y, player_speed);
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        x1, y1, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def decay_move(state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mk_game(
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, u32_dec(move_h_ttl), u32_dec(move_v_ttl),
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      )

def move_tick_game(game_: Game) -> Game:
  decay_move(apply_held_movement(game_))

def movement_x(evt: StarfoxEvent, player_x: U32, player_speed: U32) -> U32:
  match evt:
    case move_left{}:
      move_player_left(player_x, player_speed)
    case move_right{}:
      move_player_right(player_x, player_speed)
    case _:
      player_x

def movement_y(evt: StarfoxEvent, player_y: U32, player_speed: U32) -> U32:
  match evt:
    case move_up{}:
      move_player_up(player_y, player_speed)
    case move_down{}:
      move_player_down(player_y, player_speed)
    case _:
      player_y

def choose_upgrade_evt(evt: StarfoxEvent, choice_a: U32, choice_b: U32, choice_c: U32, game_: Game) -> Game:
  match evt:
    case choose_1{}:
      apply_upgrade(choice_a, game_)
    case choose_2{}:
      apply_upgrade(choice_b, game_)
    case choose_3{}:
      apply_upgrade(choice_c, game_)
    case _:
      game_

def choose_upgrade(evt: StarfoxEvent, state: Game) -> Game:
  match state:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      choose_upgrade_evt(evt, choice_a, choice_b, choice_c, got)

def game_mode(game_: Game) -> U32:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      mode

def event_code(evt: StarfoxEvent) -> U32:
  match evt:
    case tick{}:
      0
    case move_tick{}:
      1
    case move_left{}:
      2
    case move_right{}:
      3
    case move_up{}:
      4
    case move_down{}:
      5
    case fire{}:
      6
    case restart{}:
      7
    case choose_1{}:
      8
    case choose_2{}:
      9
    case choose_3{}:
      10
    case ignore{}:
      11

def starfox_on_event(evt: StarfoxEvent, game_: Game) -> Game:
  mode = game_mode(game_);
  code = event_code(evt);
  match code:
    case 0:
      match mode === 1:
        case 0:
          game_
        case _:
          game_tick(game_)
    case 1:
      match mode === 1:
        case 0:
          game_
        case _:
          move_tick_game(game_)
    case 2:
      starfox_move_evt(evt, game_)
    case 3:
      starfox_move_evt(evt, game_)
    case 4:
      starfox_move_evt(evt, game_)
    case 5:
      starfox_move_evt(evt, game_)
    case 6:
      match mode === 0:
        case 0:
          match mode === 3:
            case 0:
              match mode === 2:
                case 0:
                  fire_now(game_)
                case _:
                  game_
            case _:
              game_start_from(game_reset(best_of(game_)))
        case _:
          game_start_from(game_)
    case 7:
      game_reset(best_of(game_))
    case 8:
      match mode === 2:
        case 0:
          game_
        case _:
          choose_upgrade(evt_choice_1(), game_)
    case 9:
      match mode === 2:
        case 0:
          game_
        case _:
          choose_upgrade(evt_choice_2(), game_)
    case 10:
      match mode === 2:
        case 0:
          game_
        case _:
          choose_upgrade(evt_choice_3(), game_)
    case _:
      game_

def starfox_move_evt(evt: StarfoxEvent, game_: Game) -> Game:
  mode = game_mode(game_);
  match mode === 0:
    case 0:
      match mode === 3:
        case 0:
          match mode === 2:
            case 0:
              remember_move(evt, apply_movement(evt, game_))
            case _:
              game_
        case _:
          remember_move(evt, apply_movement(evt, game_start_from(game_reset(best_of(game_)))))
    case _:
      remember_move(evt, apply_movement(evt, game_start_from(game_)))

# Rendering strings
# -----------------

def phase_name(mode: U32, gate: Gate, boss: Boss, sector: U32) -> String:
  match mode === 0:
    case 0:
      match mode === 2:
        case 0:
          match mode === 3:
            case 0:
              match boss_exists(boss):
                case 0:
                  match gate_exists(gate):
                    case 0:
                      "Sector " ++ two_digits(sector)
                    case _:
                      "Gate Run"
                case _:
                  "Boss Assault"
            case _:
              "Debrief"
        case _:
          "Upgrade Bay"
    case _:
      "Stand By"

def shell_tone(mode: U32) -> String:
  match mode:
    case 0:
      "standby"
    case 1:
      "live"
    case 2:
      "upgrade"
    case _:
      "over"

def lead_copy(mode: U32) -> String:
  match mode:
    case 0:
      "Mission ready. Launch with movement, Space, F, Enter, or the on-screen action. This version stays inside the Bend App target, so the combat is grid-based but it keeps the original loop."
    case 1:
      "Arrow keys or WASD move. Press Space, F, Enter, or tap Fire to shoot. Pure Bend handles both UI and game state."
    case 2:
      "Level-up pause. Pick one upgrade with 1, 2, 3 or tap a card."
    case _:
      "The run is over. Press Space, F, Enter, any move button, use Relaunch, or hit Restart to return to standby."

def two_digits(value: U32) -> String:
  match value < 10:
    case 0:
      show_u32(value)
    case _:
      "0" ++ show_u32(value)

def score_text(score: U32) -> String:
  match score < 10:
    case 0:
      match score < 100:
        case 0:
          match score < 1000:
            case 0:
              match score < 10000:
                case 0:
                  match score < 100000:
                    case 0:
                      match score < 1000000:
                        case 0:
                          show_u32(score)
                        case _:
                          show_u32(score)
                    case _:
                      "0" ++ show_u32(score)
                case _:
                  "00" ++ show_u32(score)
            case _:
              "000" ++ show_u32(score)
        case _:
          "0000" ++ show_u32(score)
    case _:
      "00000" ++ show_u32(score)

def clock_text_ticks(ticks: U32) -> String:
  secs = ((ticks * tick_ms) + 999) / 1000;
  mins = secs / 60;
  rem = secs - (mins * 60);
  two_digits(mins) ++ ":" ++ two_digits(rem)

def boss_chip_text(boss_: Boss, boss_timer: U32, mode: U32, level: U32) -> String:
  match boss_:
    case no_boss{}:
      match mode === 2:
        case 0:
          match mode === 3:
            case 0:
              clock_text_ticks(boss_timer)
            case _:
              "Retry"
        case _:
          "Lv " ++ two_digits(level)
    case boss{x, y, hp, max_hp, fire, dir, drift}:
      show_u32(hp) ++ "/" ++ show_u32(max_hp) ++ " HP"

def hull_text(player_hp: U32, player_max_hp: U32, shield: U32) -> String:
  two_digits(player_hp) ++ "/" ++ two_digits(player_max_hp) ++ " +S" ++ show_u32(shield)

def hp_fill_pct(player_hp: U32, player_max_hp: U32) -> U32:
  match player_hp === 0:
    case 0:
      u32_max(6, (100 * player_hp) / player_max_hp)
    case _:
      0

def hp_fill_style(player_hp: U32, player_max_hp: U32) -> String:
  "width:" ++ show_u32(hp_fill_pct(player_hp, player_max_hp)) ++ "%"

def toast_msg_ready() -> String:
  "Mission ready"

def toast_msg_engage() -> String:
  "Engage"

def toast_msg_ring(value: U32) -> String:
  "Ring bonus +" ++ show_u32(90 * u32_max(1, value))

def toast_msg_gate() -> String:
  "Closing gate ahead"

def toast_msg_gate_clear() -> String:
  "Gate cleared"

def toast_msg_gate_crush() -> String:
  "Gate crush"

def toast_msg_shield() -> String:
  "Shield blocked impact"

def toast_msg_escape() -> String:
  "Enemy escaped"

def toast_msg_boss_in() -> String:
  "Boss incoming"

def toast_msg_boss_down() -> String:
  "Boss down +1000"

def toast_msg_level(value: U32) -> String:
  "Level " ++ show_u32(value) ++ " - choose upgrade"

def toast_msg_upgrade(value: U32) -> String:
  upgrade_name(value) ++ " online"

def toast_msg_hull() -> String:
  "Hull breached"

def toast_msg_barrage() -> String:
  "Boss barrage"

def toast_msg_impact() -> String:
  "Boss impact"

def toast_msg_enemy_down() -> String:
  "Enemy down"

def toast_text(kind: U32, value: U32) -> String:
  match kind:
    case 1:
      toast_msg_ready()
    case 2:
      toast_msg_engage()
    case 3:
      toast_msg_ring(value)
    case 4:
      toast_msg_gate()
    case 5:
      toast_msg_gate_clear()
    case 6:
      toast_msg_gate_crush()
    case 7:
      toast_msg_shield()
    case 8:
      toast_msg_escape()
    case 9:
      toast_msg_boss_in()
    case 10:
      toast_msg_boss_down()
    case 11:
      toast_msg_level(value)
    case 12:
      toast_msg_upgrade(value)
    case 13:
      toast_msg_hull()
    case 14:
      toast_msg_barrage()
    case 15:
      toast_msg_impact()
    case _:
      toast_msg_enemy_down()

def toast_view(kind: U32, value: U32, ttl: U32) -> String:
  match ttl === 0:
    case 0:
      toast_text(kind, value)
    case _:
      empty_string()

def build_stat(label: String, value: U32) -> HTML(StarfoxEvent):
  <div class="buildline">
    <span>{txt(label)}</span>
    <span>{txt(show_u32(value))}</span>
  </div>

# Cell render
# -----------

def player_class_if(game_: Game, x: U32, y: U32) -> String:
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      pick_string(player_has_cell(player_x, player_y, x, y), empty_string(), player_cell_cls(player_x, player_y, x, y))

def enemy_list_class(enemies: List(Enemy), x: U32, y: U32) -> String:
  match enemies:
    case []:
      empty_string()
    case enemy_<>rest:
      match enemy_has_cell(enemy_, x, y):
        case 0:
          enemy_list_class(rest, x, y)
        case _:
          enemy_cell_cls(enemy_)

def enemy_list_has(enemies: List(Enemy), x: U32, y: U32) -> U32:
  match enemies:
    case []:
      0
    case enemy_<>rest:
      match enemy_has_cell(enemy_, x, y):
        case 0:
          enemy_list_has(rest, x, y)
        case _:
          1

def ring_list_has(rings: List(Ring), x: U32, y: U32) -> U32:
  match rings:
    case []:
      0
    case ring_<>rest:
      match ring_has_cell(ring_, x, y):
        case 0:
          ring_list_has(rest, x, y)
        case _:
          1

def shot_list_has(shots: List(PlayerShot), x: U32, y: U32) -> U32:
  match shots:
    case []:
      0
    case pshot{sx, sy, dir, damage}<>rest:
      match (sx === x) & (sy === y):
        case 0:
          shot_list_has(rest, x, y)
        case _:
          1

def enemy_shot_list_class(shots: List(EnemyShot), x: U32, y: U32) -> String:
  match shots:
    case []:
      empty_string()
    case eshot{sx, sy, dir, boss}<>rest:
      match (sx === x) & (sy === y):
        case 0:
          enemy_shot_list_class(rest, x, y)
        case _:
          pick_string(boss, "cell enemy-shot", "cell enemy-shot boss")

def enemy_shot_list_has(shots: List(EnemyShot), x: U32, y: U32) -> U32:
  match shots:
    case []:
      0
    case eshot{sx, sy, dir, boss}<>rest:
      match (sx === x) & (sy === y):
        case 0:
          enemy_shot_list_has(rest, x, y)
        case _:
          1

def enemy_shot_list_boss(shots: List(EnemyShot), x: U32, y: U32) -> U32:
  match shots:
    case []:
      0
    case eshot{sx, sy, dir, boss}<>rest:
      match (sx === x) & (sy === y):
        case 0:
          enemy_shot_list_boss(rest, x, y)
        case _:
          boss

def boss_class_if(boss_: Boss, x: U32, y: U32) -> String:
  match boss_:
    case no_boss{}:
      empty_string()
    case boss{bx, by, hp, max_hp, fire, dir, drift}:
      got = (boss{bx, by, hp, max_hp, fire, dir, drift} :: Boss);
      match boss_has_cell(got, x, y):
        case 0:
          empty_string()
        case _:
          boss_cell_cls(u32_sub_sat(y, by), u32_sub_sat(x, bx))

def cell_bg_or_shield(
  player_x: U32,
  player_y: U32,
  shield: U32,
  invuln: U32,
  tick_no: U32,
  x: U32,
  y: U32
) -> String:
  match player_hitbox_has(player_x, player_y, x, y) & (0 < shield) & (invuln === 0):
    case 0:
      bg_cell_cls(x, y, tick_no)
    case _:
      "cell shield"

def cell_after_enemy_shot(
  enemy_shots: List(EnemyShot),
  rings: List(Ring),
  player_x: U32,
  player_y: U32,
  shield: U32,
  invuln: U32,
  tick_no: U32,
  x: U32,
  y: U32
) -> String:
  match enemy_shot_list_has(enemy_shots, x, y):
    case 0:
      match ring_list_has(rings, x, y):
        case 0:
          cell_bg_or_shield(player_x, player_y, shield, invuln, tick_no, x, y)
        case _:
          "cell ring"
    case _:
      pick_string(enemy_shot_list_boss(enemy_shots, x, y), "cell enemy-shot", "cell enemy-shot boss")

def cell_after_shot(
  shots: List(PlayerShot),
  enemy_shots: List(EnemyShot),
  rings: List(Ring),
  player_x: U32,
  player_y: U32,
  shield: U32,
  invuln: U32,
  tick_no: U32,
  x: U32,
  y: U32
) -> String:
  match shot_list_has(shots, x, y):
    case 0:
      cell_after_enemy_shot(enemy_shots, rings, player_x, player_y, shield, invuln, tick_no, x, y)
    case _:
      "cell shot"

def cell_after_player(
  player_here: U32,
  player_cls: String,
  shots: List(PlayerShot),
  enemy_shots: List(EnemyShot),
  rings: List(Ring),
  player_x: U32,
  player_y: U32,
  shield: U32,
  invuln: U32,
  tick_no: U32,
  x: U32,
  y: U32
) -> String:
  match player_here:
    case 0:
      cell_after_shot(shots, enemy_shots, rings, player_x, player_y, shield, invuln, tick_no, x, y)
    case _:
      player_cls

def cell_after_enemy(
  enemy_here: U32,
  enemies: List(Enemy),
  player_here: U32,
  player_cls: String,
  shots: List(PlayerShot),
  enemy_shots: List(EnemyShot),
  rings: List(Ring),
  player_x: U32,
  player_y: U32,
  shield: U32,
  invuln: U32,
  tick_no: U32,
  x: U32,
  y: U32
) -> String:
  match enemy_here:
    case 0:
      cell_after_player(player_here, player_cls, shots, enemy_shots, rings, player_x, player_y, shield, invuln, tick_no, x, y)
    case _:
      enemy_list_class(enemies, x, y)

def cell_after_boss(
  boss_here: U32,
  boss: Boss,
  enemy_here: U32,
  enemies: List(Enemy),
  player_here: U32,
  player_cls: String,
  shots: List(PlayerShot),
  enemy_shots: List(EnemyShot),
  rings: List(Ring),
  player_x: U32,
  player_y: U32,
  shield: U32,
  invuln: U32,
  tick_no: U32,
  x: U32,
  y: U32
) -> String:
  match boss_here:
    case 0:
      cell_after_enemy(enemy_here, enemies, player_here, player_cls, shots, enemy_shots, rings, player_x, player_y, shield, invuln, tick_no, x, y)
    case _:
      boss_class_if(boss, x, y)

def player_cell_shape_code(row: U32, col: U32) -> U32:
  match row:
    case 0:
      8
    case 3:
      9
    case _:
      match col:
        case 2:
          7
        case _:
          6

def player_cell_code(player_x: U32, player_y: U32, x: U32, y: U32) -> U32:
  row = u32_sub_sat(y, player_y);
  col = u32_sub_sat(x, player_x);
  match player_has_cell(player_x, player_y, x, y):
    case 0:
      0
    case _:
      player_cell_shape_code(row, col)

def enemy_kind_code(enemy_: Enemy) -> U32:
  match enemy_kind(enemy_) === 0:
    case 0:
      10
    case _:
      11

def enemy_list_code(enemies: List(Enemy), x: U32, y: U32) -> U32:
  match enemies:
    case []:
      0
    case enemy_<>rest:
      match enemy_has_cell(enemy_, x, y):
        case 0:
          enemy_list_code(rest, x, y)
        case _:
          enemy_kind_code(enemy_)

def boss_cell_code(boss_: Boss, x: U32, y: U32) -> U32:
  match boss_:
    case no_boss{}:
      0
    case boss{bx, by, hp, max_hp, fire, dir, drift}:
      match boss_has_cell((boss{bx, by, hp, max_hp, fire, dir, drift} :: Boss), x, y):
        case 0:
          0
        case _:
          row = u32_sub_sat(y, by);
          col = u32_sub_sat(x, bx);
          match (row === 2) & (3 <= col) & (col <= 7):
            case 0:
              12
            case _:
              13

def enemy_shot_kind_code(boss: U32) -> U32:
  match boss:
    case 0:
      3
    case _:
      4

def enemy_shot_code(shots: List(EnemyShot), x: U32, y: U32) -> U32:
  match shots:
    case []:
      0
    case eshot{sx, sy, dir, boss}<>rest:
      match (sx === x) & (sy === y):
        case 0:
          enemy_shot_code(rest, x, y)
        case _:
          enemy_shot_kind_code(boss)

def cls_shield() -> String:
  "cell shield"

def cls_ring() -> String:
  "cell ring"

def cls_enemy_shot() -> String:
  "cell enemy-shot"

def cls_enemy_shot_boss() -> String:
  "cell enemy-shot boss"

def cls_player_shot() -> String:
  "cell shot"

def cls_player_wing() -> String:
  "cell player-wing"

def cls_player_core() -> String:
  "cell player-core"

def cls_player_cockpit() -> String:
  "cell player-cockpit"

def cls_player_thruster() -> String:
  "cell player-thruster"

def cls_enemy_a() -> String:
  "cell enemy-a"

def cls_enemy_b() -> String:
  "cell enemy-b"

def cls_boss_wing() -> String:
  "cell boss-wing"

def cls_boss_core() -> String:
  "cell boss-core"

def cls_gate() -> String:
  "cell gate"

def cls_gate_edge() -> String:
  "cell gate-edge"

def cell_code_cls(code: U32, bg: String) -> String:
  match code:
    case 1:
      cls_shield()
    case 2:
      cls_ring()
    case 3:
      cls_enemy_shot()
    case 4:
      cls_enemy_shot_boss()
    case 5:
      cls_player_shot()
    case 6:
      cls_player_wing()
    case 7:
      cls_player_core()
    case 8:
      cls_player_cockpit()
    case 9:
      cls_player_thruster()
    case 10:
      cls_enemy_a()
    case 11:
      cls_enemy_b()
    case 12:
      cls_boss_wing()
    case 13:
      cls_boss_core()
    case 14:
      cls_gate()
    case 15:
      cls_gate_edge()
    case _:
      bg

def cell_code(game_: Game, x: U32, y: U32) -> U32:
  gate = gate_of(game_);
  boss = boss_of(game_);
  enemies = enemies_of(game_);
  shots = shots_of(game_);
  enemy_shots = enemy_shots_of(game_);
  rings = rings_of(game_);
  player_x = player_x_of(game_);
  player_y = player_y_of(game_);
  shield = shield_of(game_);
  invuln = invuln_of(game_);
  match gate_edge_cell(gate, x, y):
    case 0:
      match gate_has_cell(gate, x, y):
        case 0:
          code_boss = boss_cell_code(boss, x, y);
          match code_boss === 0:
            case 0:
              code_boss
            case _:
              code_enemy = enemy_list_code(enemies, x, y);
              match code_enemy === 0:
                case 0:
                  code_enemy
                case _:
                  code_player = player_cell_code(player_x, player_y, x, y);
                  match code_player === 0:
                    case 0:
                      code_player
                    case _:
                      match shot_list_has(shots, x, y):
                        case 0:
                          code_enemy_shot = enemy_shot_code(enemy_shots, x, y);
                          match code_enemy_shot === 0:
                            case 0:
                              code_enemy_shot
                            case _:
                              match ring_list_has(rings, x, y):
                                case 0:
                                  match player_hitbox_has(player_x, player_y, x, y) & (0 < shield) & (invuln === 0):
                                    case 0:
                                      0
                                    case _:
                                      1
                                case _:
                                  2
                        case _:
                          5
        case _:
          14
    case _:
      15

def cell_cls(game_: Game, x: U32, y: U32) -> String:
  cell_code_cls(cell_code(game_, x, y), bg_cell_cls(x, y, tick_no_of(game_)))

def board_cell(game_: Game, x: U32, y: U32) -> HTML(StarfoxEvent):
  <div class={cell_cls(game_, x, y)} />

def row_cells(game_: Game, y: U32, x: U32) -> List(HTML(StarfoxEvent)):
  match x === board_w:
    case 0:
      cons_html(board_cell(game_, x, y), row_cells(game_, y, x + 1))
    case _:
      empty_htmls()

def board_row(game_: Game, y: U32) -> HTML(StarfoxEvent):
  <div class="row">{...row_cells(game_, y, 0)}</div>

def board_rows(game_: Game, y: U32) -> List(HTML(StarfoxEvent)):
  match y === board_h:
    case 0:
      cons_html(board_row(game_, y), board_rows(game_, y + 1))
    case _:
      empty_htmls()

# View
# ----

def shell_attrs_idle(mode: U32) -> List(Attr(StarfoxEvent)):
  [attr{"class", "layout shell " ++ shell_tone(mode)}, on_key_down{starfox_key_evt}]

def shell_attrs_live(mode: U32) -> List(Attr(StarfoxEvent)):
  [attr{"class", "layout shell " ++ shell_tone(mode)}, on_key_down{starfox_key_evt}, every_ms{move_tick_ms, evt_move_tick()}, every_ms{tick_ms, evt_tick()}]

def shell_attrs(mode: U32) -> List(Attr(StarfoxEvent)):
  match mode === 1:
    case 0:
      shell_attrs_idle(mode)
    case _:
      shell_attrs_live(mode)

def chip(label: String, value: String, tone: String) -> HTML(StarfoxEvent):
  <div class="hud-chip">
    <span>{txt(label)}</span>
    <strong class={"hud-value " ++ tone}>{txt(value)}</strong>
  </div>

def leaderboard_item(label: String, value: String) -> HTML(StarfoxEvent):
  <li class="leaderboard-item">
    <span class="leaderboard-rank">{txt(label)}</span>
    <span class="leaderboard-score">{txt(value)}</span>
  </li>

def health_bar(player_hp: U32, player_max_hp: U32) -> HTML(StarfoxEvent):
  <div class="health-panel">
    <div class="health-meta">
      <span class="health-tag">Health</span>
      <span class="health-readout">{txt(two_digits(player_hp) ++ "/" ++ two_digits(player_max_hp) ++ " HP")}</span>
    </div>
    <div class="health-track">
      <div class="health-fill" style={hp_fill_style(player_hp, player_max_hp)} />
    </div>
  </div>

def starfox_btn(label: String, tone: String, evt: StarfoxEvent) -> HTML(StarfoxEvent):
  <button type="button" class={"btn " ++ tone} on_click={evt}>
    {txt(label)}
  </button>

def card_text(title: String, body: String) -> HTML(StarfoxEvent):
  <article class="card">
    <div class="card_title">{txt(title)}</div>
    <div class="card_body">{txt(body)}</div>
  </article>

def card_frame(player_max_hp: U32, shield: U32, player_speed: U32, level: U32) -> HTML(StarfoxEvent):
  <article class="card">
    <div class="card_title">Ship Frame</div>
    {build_stat("Hull", player_max_hp)}
    {build_stat("Shield", shield)}
    {build_stat("Speed", player_speed)}
    {build_stat("Level", level)}
  </article>

def card_weapon(player_damage: U32, fire_rate: U32, spread: U32, bullet_step: U32) -> HTML(StarfoxEvent):
  <article class="card">
    <div class="card_title">Weapons</div>
    {build_stat("Damage", player_damage)}
    {build_stat("Delay", fire_rate)}
    {build_stat("Spread", spread)}
    {build_stat("Rail", bullet_step)}
  </article>

def card_build_log(
  hull_up: U32,
  damage_up: U32,
  thruster_up: U32,
  loader_up: U32,
  wing_up: U32,
  pierce_up: U32,
  shield_up: U32,
  rail_up: U32
) -> HTML(StarfoxEvent):
  <article class="card">
    <div class="card_title">Build Log</div>
    {build_stat("Hull Up", hull_up)}
    {build_stat("Cannons", damage_up)}
    {build_stat("Thrusters", thruster_up)}
    {build_stat("Loader", loader_up)}
    {build_stat("Wings", wing_up)}
    {build_stat("Pierce", pierce_up)}
    {build_stat("Shield", shield_up)}
    {build_stat("Rail", rail_up)}
  </article>

def sidebar_cards(game_: Game) -> List(HTML(StarfoxEvent)):
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      cons_html(card_build_log(hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up), empty_htmls())

def upgrade_choice_btn(index: String, id: U32, evt: StarfoxEvent) -> HTML(StarfoxEvent):
  <button type="button" class="choice" on_click={evt}>
    <div class="choice_num">{txt(index)}</div>
    <div class="choice_title">{txt(upgrade_name(id))}</div>
    <div class="choice_copy">{txt(upgrade_desc(id))}</div>
  </button>

def overlay_action_btn(index: String, title: String, body: String, evt: StarfoxEvent) -> HTML(StarfoxEvent):
  <button type="button" class="choice" on_click={evt}>
    <div class="choice_num">{txt(index)}</div>
    <div class="choice_title">{txt(title)}</div>
    <div class="choice_copy">{txt(body)}</div>
  </button>

def overlay_sub(body: String) -> HTML(StarfoxEvent):
  <div class="overlay_sub">{txt(body)}</div>

def overlay_upgrade_choices(choice_a: U32, choice_b: U32, choice_c: U32) -> HTML(StarfoxEvent):
  <div class="choices">
    {upgrade_choice_btn("Choice 1", choice_a, evt_choice_1())}
    {upgrade_choice_btn("Choice 2", choice_b, evt_choice_2())}
    {upgrade_choice_btn("Choice 3", choice_c, evt_choice_3())}
  </div>

def overlay_upgrade(level: U32, choice_a: U32, choice_b: U32, choice_c: U32) -> HTML(StarfoxEvent):
  <div class="overlay">
    <div class="overlay_title">{txt("LEVEL " ++ show_u32(level))}</div>
    {overlay_sub("Pick one ship upgrade. Combat pauses while the frame is in the bay.")}
    {overlay_upgrade_choices(choice_a, choice_b, choice_c)}
  </div>

def overlay_brief() -> HTML(StarfoxEvent):
  <div class="overlay">
    <div class="overlay_title">MISSION BRIEF</div>
    {overlay_sub("Destroy enemies for score and XP. Rings award bonus points. Closing gates crush the ship if you miss the gap. Every full XP bar opens a three-card upgrade pick. The boss lane opens every sixty seconds.")}
    {overlay_sub("Move with arrows or WASD. Space, F, or Enter launches the run and fires once you are in sector. Buttons still work on mobile.")}
    <div class="choices">
      {overlay_action_btn("Launch", "Start Run", "Kick off the sortie and enter Sector 01 immediately.", evt_fire())}
    </div>
  </div>

def overlay_run_over(reason: U32, score: U32, best: U32, kills: U32, bosses: U32) -> HTML(StarfoxEvent):
  <div class="overlay">
    <div class="overlay_title">RUN OVER</div>
    {overlay_sub(reason_text(reason))}
    {overlay_sub(
      "Score "
      ++ show_u32(score)
      ++ " | Best "
      ++ show_u32(best)
      ++ " | Kills "
      ++ show_u32(kills)
      ++ " | Bosses "
      ++ show_u32(bosses)
    )}
    {overlay_sub("Press Space, F, Enter, move, or use the buttons below.")}
    <div class="choices">
      {overlay_action_btn("Fire", "Relaunch", "Start a fresh run immediately.", evt_fire())}
      {overlay_action_btn("Reset", "Stand By", "Return to the mission briefing screen.", evt_restart())}
    </div>
  </div>

def overlay_if(game_: Game) -> HTML(StarfoxEvent):
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      match mode === 1:
        case 0:
          match mode === 2:
            case 0:
              match mode === 0:
                case 0:
                  overlay_run_over(reason, score, best, kills, bosses)
                case _:
                  overlay_brief()
            case _:
              overlay_upgrade(level, choice_a, choice_b, choice_c)
        case _:
          <div class="overlay_empty" />

def reason_text(reason: U32) -> String:
  match reason:
    case 6:
      "Ship crushed"
    case 13:
      "Hull breached"
    case 14:
      "Boss barrage"
    case 15:
      "Boss impact"
    case _:
      "Hull breached"

def starfox_render(game_: Game) -> HTML(StarfoxEvent):
  match game_:
    case game{
      mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
      pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
      player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
      move_h, move_v, move_h_ttl, move_v_ttl,
      fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
      enemy_timer, ring_timer, gate_timer, boss_timer,
      kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
      shots, enemy_shots, enemies, rings, gate, boss
    }:
      got = (game{
        mode, reason, seed, tick_no, next_id, score, best, sector, level, xp, xp_next,
        pending_upgrades, choice_a, choice_b, choice_c, toast_kind, toast_value, toast_ttl,
        player_x, player_y, player_hp, player_max_hp, player_damage, player_speed,
        move_h, move_v, move_h_ttl, move_v_ttl,
        fire_cd, fire_rate, bullet_step, spread, pierce, shield, invuln,
        enemy_timer, ring_timer, gate_timer, boss_timer,
        kills, bosses, hull_up, damage_up, thruster_up, loader_up, wing_up, pierce_up, shield_up, rail_up, repair_up,
        shots, enemy_shots, enemies, rings, gate, boss
      } :: Game);
      <div class="page">
        <style>{txt(starfox_css())}</style>
        <main {...shell_attrs(mode)}>
          <aside class="leaderboard">
            <p class="panel-label">Mission Ledger</p>
            <ol class="leaderboard-list">
              {leaderboard_item("Top Run", score_text(best))}
              {leaderboard_item("Current", score_text(score))}
              {leaderboard_item("Phase", phase_name(mode, gate, boss, sector))}
              {leaderboard_item("Boss", boss_chip_text(boss, boss_timer, mode, level))}
              {leaderboard_item("XP", show_u32(xp) ++ "/" ++ show_u32(xp_next))}
            </ol>
            <div class="sidebar_cards">
              {...sidebar_cards(got)}
            </div>
          </aside>
          <section class="cabinet">
            <div class="screen-frame">
              <div class="frame-top">
                <div class="mission-strip">
                  {chip("Score", score_text(score), "")}
                  {chip("Phase", phase_name(mode, gate, boss, sector), "accent")}
                  {chip("Boss", boss_chip_text(boss, boss_timer, mode, level), "warn")}
                </div>
                <div class="system-pill">BEND</div>
              </div>
              {health_bar(player_hp, player_max_hp)}
              <div class="screen-surface">
                <div class="board_wrap">
                  <div class="board">{...board_rows(got, 0)}</div>
                </div>
                <div class="scanlines" aria-hidden="true" />
                <div class="screen_overlay">{overlay_if(got)}</div>
              </div>
              <div class="cabinet-footer">
                <div class="toast">{txt(toast_view(toast_kind, toast_value, toast_ttl))}</div>
                <div class="legend">{txt("Sector " ++ two_digits(sector) ++ " | Rings " ++ show_u32(rings_len(rings)) ++ " | Targets " ++ show_u32(enemies_len(enemies)) ++ " | Shots " ++ show_u32(shots_len(shots)))}</div>
              </div>
            </div>
            <div class="control-deck">
              <div class="controls">
                {starfox_btn("Left", "left", evt_move_left())}
                {starfox_btn("Up", "up", evt_move_up())}
                {starfox_btn("Fire", "fire", evt_fire())}
                {starfox_btn("Down", "down", evt_move_down())}
                {starfox_btn("Right", "right", evt_move_right())}
                {starfox_btn("Restart", "reset", evt_restart())}
              </div>
              <div class="hint">{txt(lead_copy(mode))}</div>
            </div>
          </section>
        </main>
      </div>

# Main
# ----

main : App =
  app{Game, StarfoxEvent, game_init(), starfox_render, starfox_on_event}
