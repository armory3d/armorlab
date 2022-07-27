package arm.node.brush;

@:keep
class InpaintNode extends LogicNode {

	static var image: kha.Image = null;
	static var mask: kha.Image = null;
	var result: kha.Image = null;

	public function new(tree: LogicTree) {
		super(tree);

		init();
	}

	public static function init() {
		if (image == null) {
			image = kha.Image.createRenderTarget(Config.getTextureResX(), Config.getTextureResY());
		}

		if (mask == null) {
			mask = kha.Image.createRenderTarget(Config.getTextureResX(), Config.getTextureResY(), kha.graphics4.TextureFormat.L8);
			App.notifyOnNextFrame(function() {
				mask.g4.begin();
				mask.g4.clear(kha.Color.fromFloats(1.0, 1.0, 1.0, 1.0));
				mask.g4.end();
			});
		}
	}

	override function get(from: Int): Dynamic {
		var source = inputs[0].get();
		if (!Std.isOfType(source, kha.Image)) return null;

		image.g2.begin(false);
		image.g2.drawScaledImage(source, 0, 0, Config.getTextureResX(), Config.getTextureResY());
		image.g2.end();

		result = texsynthInpaint(image, false, mask);
		return result;
	}

	override public function getImage(): kha.Image {
		App.notifyOnNextFrame(function() {
			var source = inputs[0].get();
			if (Layers.pipeCopy == null) Layers.makePipe();
			if (iron.data.ConstData.screenAlignedVB == null) iron.data.ConstData.createScreenAlignedData();
			image.g4.begin();
			image.g4.setPipeline(Layers.pipeApplyMask);
			image.g4.setTexture(Layers.tex0Mask, source);
			image.g4.setTexture(Layers.texaMask, mask);
			image.g4.setVertexBuffer(iron.data.ConstData.screenAlignedVB);
			image.g4.setIndexBuffer(iron.data.ConstData.screenAlignedIB);
			image.g4.drawIndexedVertices();
			image.g4.end();
		});
		return image;
	}

	public function getTarget(): kha.Image {
		return mask;
	}

	public static function texsynthInpaint(image: kha.Image, tiling: Bool, mask: kha.Image = null): kha.Image {
		var w = arm.Config.getTextureResX();
		var h = arm.Config.getTextureResY();

		var bytes_img = untyped image.getPixels().b.buffer;
		var bytes_mask = mask != null ? untyped mask.getPixels().b.buffer : new js.lib.ArrayBuffer(w * h);
		var bytes_out = haxe.io.Bytes.ofData(new js.lib.ArrayBuffer(w * h * 4));
		Krom.texsynthInpaint(w, h, untyped bytes_out.b.buffer, bytes_img, bytes_mask, tiling);

		return kha.Image.fromBytes(bytes_out, w, h);
	}
}
