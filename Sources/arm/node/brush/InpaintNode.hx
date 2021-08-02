package arm.node.brush;

@:keep
class InpaintNode extends LogicNode {

	public function new(tree: LogicTree) {
		super(tree);
	}

	override function get(from: Int): Dynamic {
		// texsynthInpaint(false);

		return null;
	}

	// public static function texsynthInpaint(tiling: Bool) {
	// 	var w = arm.Config.getTextureResX();
	// 	var h = arm.Config.getTextureResY();
	// 	var l = arm.Context.layer;

	// 	var bytes_img = untyped l.texpaint.getPixels().b.buffer;
	// 	var bytes_mask = l.texpaint_mask != null ? untyped l.texpaint_mask.getPixels().b.buffer : new js.lib.ArrayBuffer(w * h);
	// 	var bytes_out = haxe.io.Bytes.ofData(new js.lib.ArrayBuffer(w * h * 4));
	// 	Krom.texsynthInpaint(w, h, untyped bytes_out.b.buffer, bytes_img, bytes_mask, tiling);
	// 	var image = kha.Image.fromBytes(bytes_out, w, h);

	// 	function _next() {
	// 		arm.Context.layerIsMask = false;
	// 		arm.History.applyFilter();

	// 		l.deleteMask();
	// 		l.texpaint.unload();

	// 		l.texpaint = kha.Image.createRenderTarget(w, h);
	// 		var g2 = l.texpaint.g2;
	// 		g2.begin(false);
	// 		g2.drawImage(image, 0, 0);
	// 		g2.end();

	// 		var rts = iron.RenderPath.active.renderTargets;
	// 		rts["texpaint" + l.ext].image = l.texpaint;
	// 		arm.node.MakeMaterial.parseMeshMaterial();
	// 		arm.App.redrawUI();
	// 	}
	// 	arm.App.notifyOnNextFrame(_next);
	// }
}
