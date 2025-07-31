## This is the configuration resource for the IndieLoop SDK.
##
## It holds the configuration settings for the IndieLoop system, such as
## the API key, environment, and other settings that control the behavior
## of the SDK. 
class_name IndieLoopConfig
extends RefCounted

## The Project Token is a unique identifier for your game project.
##
## It is used to associate requests to the IndieLoop backend.
## You can create and manage your project tokens in the Project Settings
## section of the IndieLoop dashboard.
var project_token: String = ""
var game_version: String = "1.0.0"

var collect_system_info: bool = true
var collect_performance_metrics: bool = true
var collect_logs: bool = true
var collect_crash_report: bool = true

var http_client: IndieLoopHTTP


func to_dict() -> Dictionary:
    return {
        "project_token": project_token,
        "game_version": game_version,
        "collect_system_info": collect_system_info,
        "collect_performance_metrics": collect_performance_metrics,
        "collect_logs": collect_logs,
        "collect_crash_report": collect_crash_report
    }

func _to_string() -> String:
    return str(self.to_dict())