class_name RiftRules
extends RefCounted

# All numbers are first-pass balance, independent of the V1 prototype.
const HEROES := {
	"warrior": {"name":"GUERREIRO", "hp":270.0, "speed":5.6, "basic":16.0, "interval":0.85, "windup":0.22, "range":2.9,
		"skills":["Investida", "Guarda", "Golpe sísmico"], "cooldowns":[7.0,9.0,20.0]},
	"mage": {"name":"MAGO", "hp":200.0, "speed":5.3, "basic":12.0, "interval":0.9, "windup":0.14, "range":17.0,
		"skills":["Orbe explosivo", "Passo arcano", "Campo glacial"], "cooldowns":[6.0,9.0,22.0]}
}
const PASSIVES := ["Ímpeto", "Fúria", "Égide"]
const ACTIVES := ["Cura", "Onda de choque"]
const RUNE_DURATION := 12.0
const RUNE_HOLD := 25.0
const RUNE_FIRST := 10.0
const RUNE_INTERVAL := 24.0
const RUNE_WARNING := 4.0
const ZONE_START := 90.0
const ZONE_END := 135.0
const ROUND_LIMIT := 165.0
const MAP_HALF := Vector2(24,20)

static func team_color(team: int) -> Color:
	return Color("56d7d7") if team == 0 else Color("ef8975")
