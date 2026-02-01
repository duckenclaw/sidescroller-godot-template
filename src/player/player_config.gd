extends Resource
class_name PlayerConfig

# Movement settings
@export var movement_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0

# Jump settings
@export var jump_velocity: float = -400.0
@export var jump_hold_multiplier: float = 0.5
@export var coyote_time: float = 0.1

# Dash settings
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.2

# Camera settings
@export var camera_smoothing: float = 5.0
@export var camera_look_ahead: float = 100.0

# Physics
@export var gravity_multiplier: float = 1.0
