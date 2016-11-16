#ifndef ANDROIDAUDIOSINK_H
#define ANDROIDAUDIOSINK_H

#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <Uno/ObjectModel.h>

class AndroidAudioSink
{
public:
	AndroidAudioSink(@{Uno.Action<float[], int, int>} fillFunction);
	void Play();
	void Stop();

private:
	@{Uno.Action<float[], int, int>} fillFunction;

	SLObjectItf engineObject;
	SLEngineItf engineEngine;
	SLObjectItf outputMixObject;

	SLObjectItf playerObject;
	SLPlayItf playerPlay;
	SLAndroidSimpleBufferQueueItf playerBufferQueue;
	SLVolumeItf playerVolume;

	@{float[]} tempBuffer;
	short buffers[2][512];
	int currentBuffer;

	static void playerCallback(SLAndroidSimpleBufferQueueItf bq, void *context);
	void enqueueNextBuffer();
};

#endif // ANDROIDAUDIOSINK_H
