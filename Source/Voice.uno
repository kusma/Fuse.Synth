using Uno;
namespace Fuse.Synth
{
	public class Voice : Node
	{
		public int Note { get; set; }
		Oscillator _oscillator = new Oscillator()
		{
			Amplitude = 0.25f
		};

		Envelope _volumeEnvelope = new Envelope()
		{
			Attack = 0.1f,
			Decay = 0.2f,
			Sustain = 0.5f,
			Release = 0.5f
		};

		public Envelope VolumeEnvelope { get { return _volumeEnvelope; } set { _volumeEnvelope = value; } }

		int rendered;
		bool released;
		float releaseTime = 0.0f;
		bool finished;

		public void Render(float[] buffer, int offset, int count)
		{
			bool shouldFinish = false;
			if (!finished)
			{
				var freq = 440 * Math.Pow(2, (Note - 69) / 12.0f);
				int written = 0;
				while (written < count) {
					int samples = Math.Min(count - written, 32);

					float time = rendered / 44100.0f;
					float vol = released ? VolumeEnvelope.EvaluateRelease(time, releaseTime) : VolumeEnvelope.EvaluateAttackDecay(time);

					if (released && vol < 1e-10)
					{
						shouldFinish = true;
						break;
					}
					
					_oscillator.Amplitude = vol * vol * 0.25f;
					_oscillator.Render(buffer, offset + written, samples, freq);
					written += samples;
					rendered += samples;
				}
			}

			if (shouldFinish)
				Finish();
		}

		public void NoteOff()
		{
			releaseTime = rendered / 44100.0f;
			released = true;
		}

		void Finish()
		{
			finished = true;

			if (Finished != null)
				Finished(this, EventArgs.Empty);
		}

		public event EventHandler Finished;
	}
}
