class_name IndieLoopClient
extends RefCounted
## The main entry point and public API for the IndieLoop SDK.
##
## This class acts as the central hub (Facade) for the entire IndieLoop system. It is designed
## to be used as an AutoLoad singleton in your Godot project, providing a simple and unified
## interface for all SDK functionalities. Although it is intended to be used as a singleton,
## it can also be instantiated directly if needed. [br]
##
## It manages the internal components responsible for: [br]
##  - Capturing and sending bug reports. [br]
##  - Gathering console logs and performance metrics (FPS, RAM, CPU etc.). [br]
##  - Tracking custom gameplay events for analytics. [br]
##  - Handling all communication with the IndieLoop backend. [br]

var config: IndieLoopConfig
var system_info: IndieLoopSystemInfo = IndieLoopSystemInfo.new()
var performance_metrics: IndieLoopPerformanceMetrics = IndieLoopPerformanceMetrics.new()

func _init(config: IndieLoopConfig):
    self.config = config