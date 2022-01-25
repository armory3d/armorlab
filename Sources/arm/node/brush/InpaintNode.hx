package arm.node.brush;

@:keep
class InpaintNode extends LogicNode {

	static var image: kha.Image = null;
	var result: kha.Image = null;
	var mask: kha.Image = null;

	public function new(tree: LogicTree) {
		super(tree);

		if (image == null) {
			image = kha.Image.createRenderTarget(2048, 2048);
		}
		mask = kha.Image.createRenderTarget(2048, 2048, kha.graphics4.TextureFormat.L8);
	}

	override function get(from: Int): Dynamic {
		var source = inputs[0].get();
		if (!Std.isOfType(source, kha.Image)) return null;

		image.g2.begin(false);
		image.g2.drawScaledImage(source, 0, 0, 2048, 2048);
		image.g2.end();

		result = texsynthInpaint(image, false);
		return result;
	}

	override public function getImage(): kha.Image {
		return image;
	}

	public static function texsynthInpaint(image: kha.Image, tiling: Bool): kha.Image {
		var w = arm.Config.getTextureResX();
		var h = arm.Config.getTextureResY();

		var bytes_img = untyped image.getPixels().b.buffer;
		// var bytes_mask = l.texpaint_mask != null ? untyped l.texpaint_mask.getPixels().b.buffer : new js.lib.ArrayBuffer(w * h);
		var bytes_mask = new js.lib.ArrayBuffer(w * h);
		var bytes_out = haxe.io.Bytes.ofData(new js.lib.ArrayBuffer(w * h * 4));
		Krom.texsynthInpaint(w, h, untyped bytes_out.b.buffer, bytes_img, bytes_mask, tiling);

		return kha.Image.fromBytes(bytes_out, w, h);
	}
}
