package arm;

import kha.System;
import kha.Window;
import kha.Image;
import kha.Blob;
import zui.Zui;
import zui.Id;
import zui.Nodes;
import iron.data.SceneFormat;
import iron.data.MeshData;
import iron.data.Data;
import iron.object.MeshObject;
import iron.Scene;
import arm.Viewport;
import arm.sys.File;
import arm.sys.Path;
import arm.ui.UISidebar;
import arm.ui.UIFiles;
import arm.ui.UIBox;
import arm.ui.UINodes;
import arm.ui.UIHeader;
import arm.node.MakeMaterial;
import arm.io.ImportAsset;
import arm.io.ImportArm;
import arm.io.ImportTexture;
import arm.io.ExportArm;
import arm.node.NodesBrush;
import arm.ProjectFormat;
import arm.Enums;

class Project {

	public static var raw: TProjectFormat = {};
	public static var filepath = "";
	public static var assets: Array<TAsset> = [];
	public static var assetNames: Array<String> = [];
	public static var assetId = 0;
	public static var materialData: iron.data.MaterialData = null; ////
	public static var materials: Array<Dynamic> = null; ////
	public static var materialGroups: Array<TNodeGroup> = [];
	public static var paintObjects: Array<MeshObject> = null;
	public static var assetMap = new Map<Int, kha.Image>();
	static var meshList: Array<String> = null;

	public static var nodes = new Nodes();
	public static var canvas: TNodeCanvas;
	public static var defaultCanvas: Blob = null;

	public static function projectOpen() {
		UIFiles.show("arm", false, false, function(path: String) {
			if (!path.endsWith(".arm")) {
				Console.error(Strings.error0());
				return;
			}

			var current = @:privateAccess kha.graphics2.Graphics.current;
			if (current != null) current.end();

			ImportArm.runProject(path);

			if (current != null) current.begin(false);
		});
	}

	public static function projectOpenRecentBox() {
		UIBox.showCustom(function(ui: Zui) {
			if (ui.tab(Id.handle(), tr("Recent Projects"))) {
				for (path in Config.raw.recent_projects) {
					var file = path;
					#if krom_windows
					file = path.replace("/", "\\");
					#else
					file = path.replace("\\", "/");
					#end
					file = file.substr(file.lastIndexOf(Path.sep) + 1);
					if (ui.button(file, Left)) {
						var current = @:privateAccess kha.graphics2.Graphics.current;
						if (current != null) current.end();

						ImportArm.runProject(path);

						if (current != null) current.begin(false);
						UIBox.show = false;
					}
					if (ui.isHovered) ui.tooltip(path);
				}
				if (ui.button("Clear", Left)) {
					Config.raw.recent_projects = [];
					Config.save();
				}
			}
		}, 400, 320);
	}

	public static function projectSave(saveAndQuit = false) {
		if (filepath == "") {
			projectSaveAs();
			return;
		}
		var filename = Project.filepath.substring(Project.filepath.lastIndexOf(Path.sep) + 1, Project.filepath.length - 4);
		Window.get(0).title = filename + " - " + Main.title;

		function _init() {
			ExportArm.runProject();
			if (saveAndQuit) System.stop();
		}
		iron.App.notifyOnInit(_init);
	}

	public static function projectSaveAs() {
		UIFiles.show("arm", true, false, function(path: String) {
			var f = UIFiles.filename;
			if (f == "") f = tr("untitled");
			filepath = path + Path.sep + f;
			if (!filepath.endsWith(".arm")) filepath += ".arm";
			projectSave();
		});
	}

	public static function projectNewBox() {
		UIBox.showCustom(function(ui: Zui) {
			if (ui.tab(Id.handle(), tr("New Project"))) {
				if (meshList == null) {
					meshList = File.readDirectory(Path.data() + Path.sep + "meshes");
					for (i in 0...meshList.length) meshList[i] = meshList[i].substr(0, meshList[i].length - 4); // Trim .arm
					meshList.unshift("plane");
					meshList.unshift("sphere");
					meshList.unshift("rounded_cube");
				}

				ui.row([0.5, 0.5]);
				Context.projectType = ui.combo(Id.handle({position: Context.projectType}), meshList, tr("Template"), true);
				Context.projectAspectRatio = ui.combo(Id.handle({position: Context.projectAspectRatio}), ["1:1", "2:1", "1:2"], tr("Aspect Ratio"), true);

				@:privateAccess ui.endElement();
				ui.row([0.5, 0.5]);
				if (ui.button(tr("Cancel"))) {
					UIBox.show = false;
				}
				if (ui.button(tr("OK")) || ui.isReturnDown) {
					Project.projectNew();
					Viewport.scaleToBounds();
					UIBox.show = false;
					App.redrawUI();
				}
			}
		});
	}

	public static function projectNew(resetLayers = true) {
		Window.get(0).title = Main.title;
		filepath = "";

		Viewport.reset();
		Context.paintObject = Context.mainObject();

		Context.selectPaintObject(Context.mainObject());
		for (i in 1...paintObjects.length) {
			var p = paintObjects[i];
			if (p == Context.paintObject) continue;
			Data.deleteMesh(p.data.handle);
			p.remove();
		}
		var meshes = Scene.active.meshes;
		var len = meshes.length;
		for (i in 0...len) {
			var m = meshes[len - i - 1];
			if (Context.projectObjects.indexOf(m) == -1) {
				Data.deleteMesh(m.data.handle);
				m.remove();
			}
		}
		var handle = Context.paintObject.data.handle;
		if (handle != "SceneSphere" && handle != "ScenePlane") {
			Data.deleteMesh(handle);
		}

		if (Context.projectType != ModelRoundedCube) {
			var raw: TMeshData = null;
			if (Context.projectType == ModelSphere || Context.projectType == ModelTessellatedPlane) {
				var mesh: Dynamic = Context.projectType == ModelSphere ?
					new arm.geom.Sphere(1, 512, 256) :
					new arm.geom.Plane(1, 1, 512, 512);
				raw = {
					name: "Tessellated",
					vertex_arrays: [
						{ values: mesh.posa, attrib: "pos", data: "short4norm" },
						{ values: mesh.nora, attrib: "nor", data: "short2norm" },
						{ values: mesh.texa, attrib: "tex", data: "short2norm" }
					],
					index_arrays: [
						{ values: mesh.inda, material: 0 }
					],
					scale_pos: mesh.scalePos,
					scale_tex: mesh.scaleTex
				};
			}
			else {
				Data.getBlob("meshes/" + meshList[Context.projectType] + ".arm", function(b: kha.Blob) {
					raw = iron.system.ArmPack.decode(b.toBytes()).mesh_datas[0];
				});
			}

			var md = new MeshData(raw, function(md: MeshData) {});
			Data.cachedMeshes.set("SceneTessellated", md);

			if (Context.projectType == ModelTessellatedPlane) {
				Viewport.setView(0, 0, 0.75, 0, 0, 0); // Top
			}
		}

		var n = Context.projectType == ModelRoundedCube ? ".Cube" : "Tessellated";
		Data.getMesh("Scene", n, function(md: MeshData) {

			var current = @:privateAccess kha.graphics2.Graphics.current;
			if (current != null) current.end();

			Context.paintObject.setData(md);
			Context.paintObject.transform.scale.set(1, 1, 1);
			Context.paintObject.transform.buildMatrix();
			Context.paintObject.name = n;
			paintObjects = [Context.paintObject];
			Data.getMaterial("Scene", "Material", function(m: iron.data.MaterialData) {
				materialData = m;
			});
			arm.ui.UINodes.inst.hwnd.redraws = 2;
			arm.ui.UINodes.inst.groupStack = [];
			materialGroups = [];

			Project.nodes = new Nodes();
			Project.canvas = iron.system.ArmPack.decode(Project.defaultCanvas.toBytes());
			Project.canvas.name = "Brush 1";

			History.reset();

			MakeMaterial.parsePaintMaterial();
			for (a in assets) Data.deleteImage(a.file);
			assets = [];
			assetNames = [];
			assetMap = [];
			assetId = 0;
			Project.raw.packed_assets = [];
			Context.ddirty = 4;

			if (resetLayers) {
				iron.App.notifyOnInit(Layers.initLayers);
			}

			if (current != null) current.begin(false);

			Context.savedEnvmap = null;
			Context.envmapLoaded = false;
			Scene.active.world.envmap = Context.emptyEnvmap;
			Scene.active.world.raw.envmap = "World_radiance.k";
			Context.showEnvmapHandle.selected = Context.showEnvmap = false;
			Scene.active.world.probe.radiance = Context.defaultRadiance;
			Scene.active.world.probe.radianceMipmaps = Context.defaultRadianceMipmaps;
			Scene.active.world.probe.irradiance = Context.defaultIrradiance;
			Scene.active.world.probe.raw.strength = 4.0;
		});
	}

	public static function importAsset(filters: String = null, hdrAsEnvmap = true) {
		if (filters == null) filters = Path.textureFormats.join(",") + "," + Path.meshFormats.join(",");
		UIFiles.show(filters, false, true, function(path: String) {
			ImportAsset.run(path, -1.0, -1.0, true, hdrAsEnvmap);
		});
	}

	public static function reimportTextures() {
		for (asset in Project.assets) {
			reimportTexture(asset);
		}
	}

	public static function reimportTexture(asset: TAsset) {
		function load(path: String) {
			asset.file = path;
			var i = Project.assets.indexOf(asset);
			Data.deleteImage(asset.file);
			Project.assetMap.remove(asset.id);
			Project.assets.splice(i, 1);
			Project.assetNames.splice(i, 1);
			ImportTexture.run(asset.file);
			Project.assets.insert(i, Project.assets.pop());
			Project.assetNames.insert(i, Project.assetNames.pop());
			function _next() {
				arm.node.MakeMaterial.parsePaintMaterial();
			}
			App.notifyOnNextFrame(_next);
		}
		if (!File.exists(asset.file)) {
			var filters = Path.textureFormats.join(",");
			UIFiles.show(filters, false, false, function(path: String) {
				load(path);
			});
		}
		else load(asset.file);
	}

	public static function getImage(asset: TAsset): Image {
		return asset != null ? Project.assetMap.get(asset.id) : null;
	}

	public static function packedAssetExists(packed_assets: Array<TPackedAsset>, name: String): Bool {
		for (pa in packed_assets) if (pa.name == name) return true;
		return false;
	}

	public static function getMaterialGroupByName(groupName: String): TNodeGroup {
		for (g in materialGroups) if (g.canvas.name == groupName) return g;
		return null;
	}
}

typedef TNodeGroup = {
	public var nodes: Nodes;
	public var canvas: TNodeCanvas;
}
