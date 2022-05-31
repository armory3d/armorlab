package arm.node.brush;

import arm.Enums;

@:keep
class PhotoToPBRNode extends LogicNode {

	static var temp: kha.Image = null;
	static var images: Array<kha.Image> = null;
	static var modelNames = ["base", "occlusion", "roughness", "metallic", "normal", "height"];

	public static var cachedSource: Dynamic = null;

	public function new(tree: LogicTree) {
		super(tree);

		if (temp == null) {
			temp = kha.Image.createRenderTarget(2048, 2048);
		}
		if (images == null) {
			images = [];
			for (i in 0...modelNames.length) {
				images.push(kha.Image.create(2048, 2048));
			}
		}
	}

	override function get(from: Int): Dynamic {
		var source = cachedSource != null ? cachedSource : inputs[0].get();
		cachedSource = source;
		if (!Std.isOfType(source, kha.Image)) return null;

		temp.g2.begin(false);
		temp.g2.drawScaledImage(source, 0, 0, 2048, 2048);
		temp.g2.end();

		var bytes_img = untyped temp.getPixels().b.buffer;
		var u8 = new js.lib.Uint8Array(untyped bytes_img);
		var f32 = new js.lib.Float32Array(3 * 2176 * 2176);
		for (i in 0...(2176 * 2176)) {
			var x = (i % 2176) - 64;
			if (x < 0) x = x + 2048;
			else if (x > 2047) x = x - 2048;
			var y = Std.int(i / 2176) - 64;
			if (y < 0) y = y + 2048;
			else if (y > 2047) y = y - 2048;
			f32[i                  ] = (u8[(y * 2048 + x) * 4    ] / 255 - 0.5) / 0.5;
			f32[i + 2176 * 2176    ] = (u8[(y * 2048 + x) * 4 + 1] / 255 - 0.5) / 0.5;
			f32[i + 2176 * 2176 * 2] = (u8[(y * 2048 + x) * 4 + 2] / 255 - 0.5) / 0.5;
		}

		kha.Assets.loadBlobFromPath("data/models/photo_to_" + modelNames[from] + ".quant.onnx", function(model_blob: kha.Blob) {
			var buf = Krom.mlInference(untyped model_blob.toBytes().b.buffer, f32.buffer);
			var ar = new js.lib.Float32Array(buf);
			var bytes = haxe.io.Bytes.alloc(4 * 2048 * 2048);
			var offsetG = (from == ChannelBaseColor || from == ChannelNormalMap) ? 2176 * 2176 : 0;
			var offsetB = (from == ChannelBaseColor || from == ChannelNormalMap) ? 2176 * 2176 * 2 : 0;
			for (i in 0...(2048 * 2048)) {
				var x = 64 + i % 2048;
				var y = 64 + Std.int(i / 2048);
				bytes.set(i * 4    , Std.int((ar[y * 2176 + x          ] * 0.5 + 0.5) * 255));
				bytes.set(i * 4 + 1, Std.int((ar[y * 2176 + x + offsetG] * 0.5 + 0.5) * 255));
				bytes.set(i * 4 + 2, Std.int((ar[y * 2176 + x + offsetB] * 0.5 + 0.5) * 255));
				bytes.set(i * 4 + 3, 255);
			}

			var old = images[from];
			App.notifyOnNextFrame(function() {
				old.unload();
			});
			images[from] = kha.Image.fromBytes(bytes, 2048, 2048);
		});

		return images[from];
	}
}
