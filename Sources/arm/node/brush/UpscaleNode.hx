package arm.node.brush;

@:keep
class UpscaleNode extends LogicNode {

	static var temp: kha.Image = null;
	static var image: kha.Image = null;

	public function new(tree: LogicTree) {
		super(tree);
	}

	override function get(from: Int): Dynamic {
		image = inputs[0].get();

		if (image.width < Config.getTextureResX()) {
			image = esrgan(image);
			while (image.width < Config.getTextureResX()) {
				var lastImage = image;
				image = esrgan(image);
				lastImage.unload();
			}
		}

		return image;
	}

	override public function getImage(): kha.Image {
		return image;
	}

	public static function esrgan(source: kha.Image): kha.Image {
		var result: kha.Image = null;
		var size1w = source.width;
		var size1h = source.height;
		var size2w = Std.int(source.width * 2);
		var size2h = Std.int(source.height * 2);

		if (temp != null) {
			temp.unload();
		}
		temp = kha.Image.createRenderTarget(size1w, size1h);
		temp.g2.begin(false);
		temp.g2.drawScaledImage(source, 0, 0, size1w, size1h);
		temp.g2.end();

		var bytes_img = untyped temp.getPixels().b.buffer;
		var u8 = new js.lib.Uint8Array(untyped bytes_img);
		var f32 = new js.lib.Float32Array(3 * size1w * size1h);
		for (i in 0...(size1w * size1h)) {
			f32[i                      ] = (u8[i * 4    ] / 255);
			f32[i + size1w * size1w    ] = (u8[i * 4 + 1] / 255);
			f32[i + size1w * size1w * 2] = (u8[i * 4 + 2] / 255);
		}

		kha.Assets.loadBlobFromPath("data/models/esrgan.quant.onnx", function(esrgan_blob: kha.Blob) {
			var esrgan2x_buf = Krom.mlInference(untyped esrgan_blob.toBytes().b.buffer, [f32.buffer], [[1, 3, size1w, size1h]], [1, 3, size2w, size2h], Config.raw.gpu_inference, true);
			var esrgan2x = new js.lib.Float32Array(esrgan2x_buf);
			for (i in 0...esrgan2x.length) {
				if (esrgan2x[i] < 0) esrgan2x[i] = 0;
				else if (esrgan2x[i] > 1) esrgan2x[i] = 1;
			}

			var bytes = haxe.io.Bytes.alloc(4 * size2w * size2h);
			for (i in 0...(size2w * size2h)) {
				bytes.set(i * 4    , Std.int(esrgan2x[i                      ] * 255));
				bytes.set(i * 4 + 1, Std.int(esrgan2x[i + size2w * size2w    ] * 255));
				bytes.set(i * 4 + 2, Std.int(esrgan2x[i + size2w * size2w * 2] * 255));
				bytes.set(i * 4 + 3, 255);
			}

			result = kha.Image.fromBytes(bytes, size2w, size2h);
		});

		return result;
	}
}
