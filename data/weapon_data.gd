extends Resource
class_name WeaponData

@export var name: String
@export var icon: Texture2D
@export var bullet_scene: PackedScene
@export var cooldown: float
@export var damage: float
@export var projectile_count: int = 1
@export var spread_degrees: float = 0.0
@export var weapon_texture: Texture2D
@export var visual_scale: float = 1.0
@export var max_distance: float = 500
@export var pierce: int = 0
@export var mag_size := 8
@export var reload_time := 1.5
