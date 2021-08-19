package arm.ui;

import zui.Zui;
import zui.Nodes;
import iron.data.Data;
import iron.system.Time;
import iron.system.Input;
import arm.io.ImportAsset;
import arm.io.ImportTexture;
import arm.sys.Path;
import arm.sys.File;
import arm.Enums;

class TabTextures {

	@:access(zui.Zui)
	public static function draw() {
		var ui = UISidebar.inst.ui;
		if (ui.tab(UIStatus.inst.statustab, tr("Textures"))) {

			ui.beginSticky();
			ui.row([1 / 14]);

			if (ui.button(tr("Import"))) {
				UIFiles.show(Path.textureFormats.join(","), false, true, function(path: String) {
					ImportAsset.run(path, -1.0, -1.0, true, false);
				});
			}
			if (ui.isHovered) ui.tooltip(tr("Import texture file") + ' (${Config.keymap.file_import_assets})');

			ui.endSticky();

			if (Project.assets.length > 0) {

				var statusw = kha.System.windowWidth();
				var slotw = Std.int(52 * ui.SCALE());
				var num = Std.int(statusw / slotw);

				for (row in 0...Std.int(Math.ceil(Project.assets.length / num))) {
					var mult = 1;
					ui.row([for (i in 0...num * mult) 1 / num]);

					ui._x += 2;
					var off = 6;
					if (row > 0) ui._y += off;

					for (j in 0...num) {
						var imgw = Std.int(50 * ui.SCALE());
						var i = j + row * num;
						if (i >= Project.assets.length) {
							@:privateAccess ui.endElement(imgw);
							continue;
						}

						var asset = Project.assets[i];
						var img = Project.getImage(asset);
						var uix = ui._x;
						var uiy = ui._y;
						var sw = img.height < img.width ? img.height : 0;
						if (ui.image(img, 0xffffffff, slotw, 0, 0, sw, sw) == State.Started && ui.inputY > ui._windowY) {
							var mouse = Input.getMouse();
							App.dragOffX = -(mouse.x - uix - ui._windowX - 3);
							App.dragOffY = -(mouse.y - uiy - ui._windowY + 1);
							// App.dragAsset = asset;
							// Context.texture = asset;

							Context.selectTime = Time.time();
						}

						if (ui.isHovered) {
							ui.tooltipImage(img, 256);
							ui.tooltip(asset.name);
						}

						if (ui.isHovered && ui.inputReleasedR) {
							var isPacked = Project.raw.packed_assets != null && Project.packedAssetExists(Project.raw.packed_assets, asset.file);
							UIMenu.draw(function(ui: Zui) {
								ui.text(asset.name + (isPacked ? " " + tr("(packed)") : ""), Right, ui.t.HIGHLIGHT_COL);
								if (ui.button(tr("Export"), Left)) {
									UIFiles.show("png", true, false, function(path: String) {
										App.notifyOnNextFrame(function () {
											if (Layers.pipeCopy == null) Layers.makePipe();
											var target = kha.Image.createRenderTarget(to_pow2(img.width), to_pow2(img.height));
											target.g2.begin(false);
											target.g2.pipeline = Layers.pipeCopy;
											target.g2.drawScaledImage(img, 0, 0, target.width, target.height);
											target.g2.pipeline = null;
											target.g2.end();
											App.notifyOnNextFrame(function () {
												var f = UIFiles.filename;
												if (f == "") f = tr("untitled");
												if (!f.endsWith(".png")) f += ".png";
												Krom.writePng(path + Path.sep + f, target.getPixels().getData(), target.width, target.height, 0);
												target.unload();
											});
										});
									});
								}
								if (ui.button(tr("Reimport"), Left)) {
									Project.reimportTexture(asset);
								}
								if (ui.button(tr("Delete"), Left)) {
									UIStatus.inst.statusHandle.redraws = 2;
									Data.deleteImage(asset.file);
									Project.assetMap.remove(asset.id);
									Project.assets.splice(i, 1);
									Project.assetNames.splice(i, 1);
									function _next() {
										arm.node.MakeMaterial.parsePaintMaterial();
									}
									App.notifyOnNextFrame(_next);

									for (m in Project.materials) updateTexturePointers(m.canvas.nodes, i);
								}
								if (!isPacked && ui.button(tr("Open Containing Directory..."), Left)) {
									File.start(asset.file.substr(0, asset.file.lastIndexOf(Path.sep)));
								}
							}, isPacked ? 4 : 5);
						}
					}
				}
			}
			else {
				var img = Res.get("icons.k");
				var r = Res.tile50(img, 0, 1);
				ui.image(img, ui.t.BUTTON_COL, r.h, r.x, r.y, r.w, r.h);
				if (ui.isHovered) ui.tooltip(tr("Drag and drop files here"));
			}
		}
	}

	static function to_pow2(i: Int): Int {
		i--;
		i |= i >> 1;
		i |= i >> 2;
		i |= i >> 4;
		i |= i >> 8;
		i |= i >> 16;
		i++;
		return i;
	}

	static function updateTexturePointers(nodes: Array<TNode>, i: Int) {
		for (n in nodes) {
			if (n.type == "TEX_IMAGE") {
				if (n.buttons[0].default_value == i) {
					n.buttons[0].default_value = 9999; // Texture deleted, use pink now
				}
				else if (n.buttons[0].default_value > i) {
					n.buttons[0].default_value--; // Offset by deleted texture
				}
			}
		}
	}
}