package arm.node.brush;

@:keep
class PhotoToBaseNode extends LogicNode {

	var image: kha.Image;

	public function new(tree: LogicTree) {
		super(tree);
		image = kha.Image.createRenderTarget(2048, 2048);
	}

	override function get(from: Int): Dynamic {

		var source = inputs[0].get();
		image.g2.begin(false);
		image.g2.drawImage(source, 0, 0);
		image.g2.end();

		kha.Assets.loadBlobFromPath("data/models/photo_to_base.quant.onnx", function(blob_base: kha.Blob) {
			var bytes_img = untyped image.getPixels().b.buffer;
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

			var buf = Krom.mlInference(untyped blob_base.toBytes().b.buffer, f32.buffer);
			var ar = new js.lib.Float32Array(buf);
			var bytes = haxe.io.Bytes.alloc(4 * 2048 * 2048);
			for (i in 0...(2048 * 2048)) {
				var x = 64 + i % 2048;
				var y = 64 + Std.int(i / 2048);
				bytes.set(i * 4    , Std.int((ar[y * 2176 + x                  ] * 0.5 + 0.5) * 255));
				bytes.set(i * 4 + 1, Std.int((ar[y * 2176 + x + 2176 * 2176    ] * 0.5 + 0.5) * 255));
				bytes.set(i * 4 + 2, Std.int((ar[y * 2176 + x + 2176 * 2176 * 2] * 0.5 + 0.5) * 255));
				bytes.set(i * 4 + 3, 255);
			}

			image = kha.Image.fromBytes(bytes, 2048, 2048);
		});

		return image;
	}
}
