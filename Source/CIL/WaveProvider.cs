using System;
using NAudio.Wave;

namespace Fuse.AudioSink
{
    sealed class WaveProvider : IWaveProvider
    {
        float[] _waveTable = new float[4096];
        Action<float[], int, int> _fillFunction;

        public WaveProvider(int frequency, Action<float[], int, int> fillFunction)
        {
            _waveFormat = WaveFormat.CreateIeeeFloatWaveFormat(frequency, 1);
            _fillFunction = fillFunction;
        }

        public int Read(byte[] buffer, int offset, int count)
        {
            WaveBuffer waveBuffer = new WaveBuffer(buffer);
            int sampleRate = WaveFormat.SampleRate;

            float[] sampleBuffer = waveBuffer.FloatBuffer;
            int sampleOffset = offset;
            int sampleCount = count / 4;

            _fillFunction(sampleBuffer, sampleOffset, sampleCount);

            return sampleCount * 4;
        }

        private readonly WaveFormat _waveFormat;
        public WaveFormat WaveFormat
        {
            get { return _waveFormat; }
        }
    }
}
