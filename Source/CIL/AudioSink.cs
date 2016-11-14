using System;
using NAudio.Wave;

namespace Fuse.AudioSink
{
    public sealed class AudioSink : IDisposable
    {
        WaveProvider _waveProvider;
        WaveOut _waveOut;

        public AudioSink(int frequency, Action<float[], int, int> fillFunction)
        {
            _waveProvider = new WaveProvider(frequency, fillFunction);
            _waveOut = new WaveOut();
            _waveOut.Init(_waveProvider);
        }

        public void Play()
        {
            _waveOut.Play();
        }

        public void Stop()
        {
            _waveOut.Stop();
        }

        public void Dispose()
        {
            _waveOut.Dispose();
        }
    }
}
