package arm;

@:enum abstract WorkspaceTool(Int) from Int to Int {
	var ToolEraser = 0;
	var ToolClone = 1;
	var ToolBlur = 2;
	var ToolPicker = 3;
}

@:enum abstract SpaceType(Int) from Int to Int {
	var Space3D = 0;
	var Space2D = 1;
}

@:enum abstract ViewportMode(Int) from Int to Int {
	var ViewLit = 0;
	var ViewBaseColor = 1;
	var ViewNormalMap = 2;
	var ViewOcclusion = 3;
	var ViewRoughness = 4;
	var ViewMetallic = 5;
	var ViewOpacity = 6;
	var ViewHeight = 7;
	var ViewPathTrace = 8;
}

@:enum abstract RenderMode(Int) from Int to Int {
	var RenderDeferred = 0;
	var RenderForward = 1;
	var RenderPathTrace = 2;
}

#if (kha_direct3d12 || kha_vulkan)
@:enum abstract PathTraceMode(Int) from Int to Int {
	var TraceCore = 0;
	var TraceFull = 1;
}
#end

@:enum abstract CameraControls(Int) from Int to Int {
	var ControlsOrbit = 0;
	var ControlsRotate = 1;
	var ControlsFly = 2;
}

@:enum abstract CameraType(Int) from Int to Int {
	var CameraPerspective = 0;
	var CameraOrthographic = 1;
}

@:enum abstract TextureRes(Int) from Int to Int {
	var Res128 = 0;
	var Res256 = 1;
	var Res512 = 2;
	var Res1024 = 3;
	var Res2048 = 4;
	var Res4096 = 5;
	var Res8192 = 6;
	var Res16384 = 7;
}

@:enum abstract TextureFormatLdr(Int) from Int to Int {
	var FormatPng = 0;
	var FormatJpg = 1;
}

@:enum abstract MenuCategory(Int) from Int to Int {
	var MenuFile = 0;
	var MenuEdit = 1;
	var MenuViewport = 2;
	var MenuMode = 3;
	var MenuCamera = 4;
	var MenuHelp = 5;
}

@:enum abstract BorderSide(Int) from Int to Int {
	var SideLeft = 0;
	var SideRight = 1;
	var SideTop = 2;
	var SideBottom = 3;
}

@:enum abstract ProjectModel(Int) from Int to Int {
	var ModelRoundedCube = 0;
	var ModelSphere = 1;
	var ModelTessellatedPlane = 2;
	var ModelCustom = 3;
}

@:enum abstract LayoutSize(Int) from Int to Int {
	var LayoutNodesW = 0;
	var LayoutStatusH = 1;
}

@:enum abstract ZoomDirection(Int) from Int to Int {
	var ZoomVertical = 0;
	var ZoomVerticalInverted = 1;
	var ZoomHorizontal = 2;
	var ZoomHorizontalInverted = 3;
	var ZoomVerticalAndHorizontal = 4;
	var ZoomVerticalAndHorizontalInverted = 5;
}
