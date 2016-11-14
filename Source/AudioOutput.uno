using Uno.Math;
namespace Fuse.Synth
{
	public class AudioOutput : Node
	{
		extern(CIL) Fuse.AudioSink.AudioSink _audioSink;

		double th = 0;
		extern(CIL) void fillFunction(float[] buffer, int offset, int samples)
		{
			for (int i = 0; i < samples; ++i)
			{
				buffer[i + offset] = (float)(Uno.Math.Sin(th) * 0.25);
				th += 1.0 / 100;
			}
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
