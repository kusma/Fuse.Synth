#include "AndroidAudioSink.h"
#include <@{Uno.Float:Include}>
#include <stddef.h>
#include <assert.h>

void AndroidAudioSink::playerCallback(SLAndroidSimpleBufferQueueItf bq, void *context)
{
	AndroidAudioSink *audioSink = (AndroidAudioSink *)context;
	assert(bq == audioSink->playerBufferQueue);
	audioSink->enqueueNextBuffer();
}

void AndroidAudioSink::enqueueNextBuffer()
{
	static short buffer[2][512];
	static int curBuffer = 0;

	short *nextBuffer = buffer[curBuffer];
	int nextSize = sizeof(buffer[0]);

	@{Uno.Action<float[], int, int>:Of(fillFunction).Call(tempBuffer, 0, tempBuffer->Length())};

	float *data = (float *)tempBuffer->Ptr();
	for (int i = 0; i < tempBuffer->Length(); ++i) {
		float sample = data[i];

		// clip sample
		if (sample < -1.0f)
			sample = -1.0f;
		else if (sample > 1.0f)
			sample = 1.0f;

		// convert to 16-bit
		nextBuffer[i] = short(sample * SHRT_MAX);
	}

	SLresult result = (*playerBufferQueue)->Enqueue(playerBufferQueue, nextBuffer, nextSize);
	assert(SL_RESULT_SUCCESS == result);

	curBuffer ^= 1;
}

AndroidAudioSink::AndroidAudioSink(@{Uno.Action<float[], int, int>} fillFunction) :
	fillFunction(fillFunction),
	engineObject(NULL),
	engineEngine(NULL),
	outputMixObject(NULL),
	playerObject(NULL),
	playerPlay(NULL),
	playerBufferQueue(NULL),
	playerVolume(NULL),
	currentBuffer(0)
{
	uRetain(fillFunction);

	SLresult result = slCreateEngine(&engineObject, 0, NULL, 0, NULL, NULL);
	assert(result == SL_RESULT_SUCCESS);

	result = (*engineObject)->Realize(engineObject, SL_BOOLEAN_FALSE);
	assert(result == SL_RESULT_SUCCESS);

	result = (*engineObject)->GetInterface(engineObject, SL_IID_ENGINE, &engineEngine);
	assert(result == SL_RESULT_SUCCESS);

	result = (*engineEngine)->CreateOutputMix(engineEngine, &outputMixObject, 0, NULL, NULL);
	assert(result == SL_RESULT_SUCCESS);

	result = (*outputMixObject)->Realize(outputMixObject, SL_BOOLEAN_FALSE);
	assert(result == SL_RESULT_SUCCESS);

	SLDataLocator_AndroidSimpleBufferQueue bufferQueueLocator = {SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2};

	SLDataFormat_PCM pcmFormat = {
		SL_DATAFORMAT_PCM,
		1,
		SL_SAMPLINGRATE_44_1,
		SL_PCMSAMPLEFORMAT_FIXED_16,
		SL_PCMSAMPLEFORMAT_FIXED_16,
		SL_SPEAKER_FRONT_CENTER,
		SL_BYTEORDER_LITTLEENDIAN
	};

	SLDataSource audioSrc = {&bufferQueueLocator, &pcmFormat};

	SLDataLocator_OutputMix loc_outmix = {SL_DATALOCATOR_OUTPUTMIX, outputMixObject};
	SLDataSink audioSnk = {&loc_outmix, NULL};

	const SLInterfaceID ids[2] = {SL_IID_BUFFERQUEUE, SL_IID_VOLUME};
	const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
	result = (*engineEngine)->CreateAudioPlayer(engineEngine, &playerObject, &audioSrc, &audioSnk, 2, ids, req);
	assert(result == SL_RESULT_SUCCESS);

	result = (*playerObject)->Realize(playerObject, SL_BOOLEAN_FALSE);
	assert(result == SL_RESULT_SUCCESS);

	result = (*playerObject)->GetInterface(playerObject, SL_IID_PLAY, &playerPlay);
	assert(result == SL_RESULT_SUCCESS);

	result = (*playerObject)->GetInterface(playerObject, SL_IID_BUFFERQUEUE, &playerBufferQueue);
	assert(result == SL_RESULT_SUCCESS);

	result = (*playerBufferQueue)->RegisterCallback(playerBufferQueue, playerCallback, this);
	assert(result == SL_RESULT_SUCCESS);

	result = (*playerObject)->GetInterface(playerObject, SL_IID_VOLUME, &playerVolume);
	assert(result == SL_RESULT_SUCCESS);

	tempBuffer = uArray::New(@{float[]:TypeOf}, 512);
	uRetain(tempBuffer);
}

void AndroidAudioSink::Play()
{
	SLresult result = (*playerPlay)->SetPlayState(playerPlay, SL_PLAYSTATE_PLAYING);
	assert(result == SL_RESULT_SUCCESS);

	enqueueNextBuffer();
	enqueueNextBuffer();
}

void AndroidAudioSink::Stop()
{
	SLresult result = (*playerPlay)->SetPlayState(playerPlay, SL_PLAYSTATE_STOPPED);
	assert(result == SL_RESULT_SUCCESS);
}
