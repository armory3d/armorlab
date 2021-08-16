package arm;

@:expose("arm")
class ArmBridge {
	public static var App = arm.App;
	public static var Config = arm.Config;
	public static var Context = arm.Context;
	public static var History = arm.History;
	public static var Layers = arm.Layers;
	public static var Operator = arm.Operator;
	public static var Plugin = arm.Plugin;
	public static var Project = arm.Project;
	public static var Res = arm.Res;
	public static var Path = arm.sys.Path;
	public static var File = arm.sys.File;
	public static var NodesBrush = arm.node.NodesBrush;
	public static var Brush = arm.node.Brush;
	public static var BrushOutputNode = arm.node.brush.BrushOutputNode;
}

@:keep
class KeepLab {
	public static function keep() {
		var a = App.uiBox.panel;
		return [a];
	}
}
