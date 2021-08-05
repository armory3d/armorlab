package arm.io;

import haxe.Json;
import haxe.io.Bytes;
import zui.Nodes;
import iron.data.SceneFormat;
import iron.system.ArmPack;
import iron.system.Lz4;
import arm.ui.UISidebar;
import arm.ui.UINodes;
import arm.sys.Path;
import arm.ProjectFormat;
import arm.Enums;

class ExportArm {

	public static function runProject() {

		var c: TNodeCanvas = Json.parse(Json.stringify(Project.canvas));
		for (n in c.nodes) exportNode(n);

		var mgroups: Array<TNodeCanvas> = null;
		if (Project.materialGroups.length > 0) {
			mgroups = [];
			for (g in Project.materialGroups) {
				var c: TNodeCanvas = Json.parse(Json.stringify(g.canvas));
				for (n in c.nodes) exportNode(n);
				mgroups.push(c);
			}
		}

		var texture_files = assetsToFiles(Project.filepath, Project.assets);
		var packed_assets = Project.raw.packed_assets == null || Project.raw.packed_assets.length == 0 ? null : Project.raw.packed_assets;
		var sameDrive = Project.raw.envmap != null ? Project.filepath.charAt(0) == Project.raw.envmap.charAt(0) : true;

		Project.raw = {
			version: Main.version,
			material: c,
			material_groups: mgroups,
			mesh_data: Project.paintObjects[0].data.raw,
			assets: texture_files,
			packed_assets: packed_assets,
			envmap: Project.raw.envmap != null ? (sameDrive ? Path.toRelative(Project.filepath, Project.raw.envmap) : Project.raw.envmap) : null,
			envmap_strength: iron.Scene.active.world.probe.raw.strength,
			camera_world: iron.Scene.active.camera.transform.local.toFloat32Array(),
			camera_origin: vec3f32(arm.Camera.inst.origins[0]),
			camera_fov: iron.Scene.active.camera.data.raw.fov,
			#if (kha_metal || kha_vulkan)
			is_bgra: true
			#else
			is_bgra: false
			#end
		};

		var bytes = ArmPack.encode(Project.raw);
		Krom.fileSaveBytes(Project.filepath, bytes.getData(), bytes.length + 1);

		// Save to recent
		var recent = Config.raw.recent_projects;
		recent.remove(Project.filepath);
		recent.unshift(Project.filepath);
		Config.save();

		Console.info("Project saved.");
	}

	static function exportNode(n: TNode, assets: Array<TAsset> = null) {
		if (n.type == "ImageTextureNode") {
			var index = n.buttons[0].default_value;
			n.buttons[0].data = App.enumTexts(n.type)[index];

			if (assets != null) {
				var asset = Project.assets[index];
				if (assets.indexOf(asset) == -1) {
					assets.push(asset);
				}
			}
		}
		// Pack colors
		if (n.color > 0) n.color -= untyped 4294967296;
		for (inp in n.inputs) if (inp.color > 0) inp.color -= untyped 4294967296;
		for (out in n.outputs) if (out.color > 0) out.color -= untyped 4294967296;
	}

	#if (kha_metal || kha_vulkan)
	static function bgraSwap(bytes: haxe.io.Bytes) {
		for (i in 0...Std.int(bytes.length / 4)) {
			var r = bytes.get(i * 4);
			bytes.set(i * 4, bytes.get(i * 4 + 2));
			bytes.set(i * 4 + 2, r);
		}
		return bytes;
	}
	#end

	static function assetsToFiles(projectPath: String, assets: Array<TAsset>): Array<String> {
		var texture_files: Array<String> = [];
		for (a in assets) {
			// Convert image path from absolute to relative
			var sameDrive = projectPath.charAt(0) == a.file.charAt(0);
			if (sameDrive) {
				texture_files.push(Path.toRelative(projectPath, a.file));
			}
			else {
				texture_files.push(a.file);
			}
		}
		return texture_files;
	}

	static function getPackedAssets(projectPath: String, texture_files: Array<String>): Array<TPackedAsset> {
		var packed_assets: Array<TPackedAsset> = null;
		if (Project.raw.packed_assets != null) {
			for (pa in Project.raw.packed_assets) {
				// Convert path from absolute to relative
				var sameDrive = projectPath.charAt(0) == pa.name.charAt(0);
				pa.name = sameDrive ? Path.toRelative(projectPath, pa.name) : pa.name;
				for (tf in texture_files) {
					if (pa.name == tf) {
						if (packed_assets == null) {
							packed_assets = [];
						}
						packed_assets.push(pa);
						break;
					}
				}
			}
		}
		return packed_assets;
	}

	static function packAssets(raw: TProjectFormat, assets: Array<TAsset>) {
		if (raw.packed_assets == null) {
			raw.packed_assets = [];
		}
		var tempImages: Array<kha.Image> = [];
		for (i in 0...assets.length) {
			if (!Project.packedAssetExists(raw.packed_assets, raw.assets[i])) {
				var image = Project.getImage(assets[i]);
				var temp = kha.Image.createRenderTarget(image.width, image.height);
				temp.g2.begin(false);
				temp.g2.drawImage(image, 0, 0);
				temp.g2.end();
				tempImages.push(temp);
				raw.packed_assets.push({
					name: raw.assets[i],
					bytes: Bytes.ofData(assets[i].name.endsWith(".jpg") ?
						Krom.encodeJpg(temp.getPixels().getData(), temp.width, temp.height, 0, 80) :
						Krom.encodePng(temp.getPixels().getData(), temp.width, temp.height, 0)
					)
				});
			}
		}
		App.notifyOnNextFrame(function() {
			for (image in tempImages) image.unload();
		});
	}

	static function vec3f32(v: iron.math.Vec4): kha.arrays.Float32Array {
		var res = new kha.arrays.Float32Array(3);
		res[0] = v.x;
		res[1] = v.y;
		res[2] = v.z;
		return res;
	}
}