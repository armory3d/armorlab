package arm;

@:enum abstract WorkspaceTool(Int) from Int to Int {
	var ToolEraser = 0;
	var ToolPicker = 1;
	var ToolGizmo = 2;
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
	var ViewTexCoord = 8;
	var ViewObjectNormal = 9;
	var ViewMaterialID = 10;
	var ViewObjectID = 11;
	var ViewMask = 12;
	var ViewPathTrace = 13;
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

@:enum abstract TextureBits(Int) from Int to Int {
	var Bits8 = 0;
	var Bits16 = 1;
	var Bits32 = 2;
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

@:enum abstract TextureLdrFormat(Int) from Int to Int {
	var FormatPng = 0;
	var FormatJpg = 1;
}

@:enum abstract TextureHdrFormat(Int) from Int to Int {
	var FormatExr = 0;
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
	var LayoutSidebarW = 0;
	var LayoutSidebarH0 = 1;
	var LayoutSidebarH1 = 2;
	var LayoutSidebarH2 = 3;
	var LayoutNodesW = 4;
	var LayoutNodesH = 5;
	var LayoutStatusH = 6;
}

@:enum abstract ZoomDirection(Int) from Int to Int {
	var ZoomVertical = 0;
	var ZoomVerticalInverted = 1;
	var ZoomHorizontal = 2;
	var ZoomHorizontalInverted = 3;
	var ZoomVerticalAndHorizontal = 4;
	var ZoomVerticalAndHorizontalInverted = 5;
}
