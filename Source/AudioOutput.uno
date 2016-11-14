namespace Fuse.Synth
{
	public class AudioOutput : Node
	{
		extern(CIL) Fuse.AudioSink.AudioSink _audioSink;

		Oscillator temp = new Oscillator()
		{
			Amplitude = 0.25f
		};

		void fillFunction(float[] buffer, int offset, int count)
		{
			for (int i = 0; i < count; ++i)
			{
				buffer[i + offset] = 0;
			}
			temp.Render(buffer, offset, count);
		}

		protected override void OnRooted()
		{
			if defined(CIL)
			{
				_audioSink = new Fuse.AudioSink.AudioSink(44100, fillFunction);
				_audioSink.Play();
			}

			debug_log "rooted!";
			base.OnRooted();
		}

		protected override void OnUnrooted()
		{
			if defined(CIL)
			{
				_audioSink.Stop();
				_audioSink.Dispose();
				_audioSink = null;
			}

			base.OnUnrooted();
			debug_log "unrooted!";
		}
	}
}
