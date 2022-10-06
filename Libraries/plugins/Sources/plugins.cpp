
#include <v8.h>
#include <kinc/log.h>

using namespace v8;

static Isolate *isolate;

extern "C" {
	void texsynth_inpaint(int w, int h, void *output_ptr, void *image_ptr, void *mask_ptr, bool tiling);
}

namespace {
	void krom_texsynth_inpaint(const FunctionCallbackInfo<Value> &args) {
		HandleScope scope(args.GetIsolate());
		int32_t w = args[0]->ToInt32(isolate->GetCurrentContext()).ToLocalChecked()->Value();
		int32_t h = args[1]->ToInt32(isolate->GetCurrentContext()).ToLocalChecked()->Value();
		Local<ArrayBuffer> bufferOut = Local<ArrayBuffer>::Cast(args[2]);
		ArrayBuffer::Contents contentOut = bufferOut->GetContents();
		Local<ArrayBuffer> bufferImage = Local<ArrayBuffer>::Cast(args[3]);
		ArrayBuffer::Contents contentImage = bufferImage->GetContents();
		Local<ArrayBuffer> bufferMask = Local<ArrayBuffer>::Cast(args[4]);
		ArrayBuffer::Contents contentMask = bufferMask->GetContents();
		bool tiling = args[5]->ToBoolean(isolate)->Value();
		texsynth_inpaint(w, h, contentOut.Data(), contentImage.Data(), contentMask.Data(), tiling);
	}
}

void plugin_embed(Isolate *_isolate, Local<ObjectTemplate> global) {
	isolate = _isolate;
	Isolate::Scope isolate_scope(isolate);
	HandleScope handle_scope(isolate);

	Local<ObjectTemplate> krom_texsynth = ObjectTemplate::New(isolate);
	krom_texsynth->Set(String::NewFromUtf8(isolate, "inpaint").ToLocalChecked(), FunctionTemplate::New(isolate, krom_texsynth_inpaint));
	global->Set(String::NewFromUtf8(isolate, "Krom_texsynth").ToLocalChecked(), krom_texsynth);
}
