## This is the configuration resource for the IndieLoop SDK.
##
## It holds the configuration settings for the IndieLoop system, such as
## the API key, environment, and other settings that control the behavior
## of the SDK. 
class_name IndieLoopConfig
extends Resource

## The Project Token is a unique identifier for your game project.
##
## It is used to associate requests to the IndieLoop backend.
## You can create and manage your project tokens in the Project Settings
## section of the IndieLoop dashboard.
@export var project_token: String = ""
@export var game_version: String = "1.0.0"

@export var collect_system_info: bool = true
@export var collect_performance_metrics: bool = true
@export var collect_logs: bool = true
@export var collect_crash_report: bool = true