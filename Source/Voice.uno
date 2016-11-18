using Uno;
using Uno.Collections;
using Uno.UX;

namespace Fuse.Synth
{
	public class Voice : Node
	{
		public int Note { get; set; }
/*
		Oscillator _oscillator = new Oscillator()
		{
			Amplitude = 0.25f
		};
		public Oscillator PrimaryOscillator { get { return _oscillator; } set { _oscillator = value; } }
*/

		public IList<Oscillator> _oscillators;
		[UXContent]
		public IList<Oscillator> Oscillators
		{
			get
			{
				return _oscillators ?? (_oscillators = new List<Oscillator>());
			}
		}

		Envelope _volumeEnvelope = new Envelope()
		{
			Attack = 0.1f,
			Decay = 0.2f,
			Sustain = 0.5f,
			Release = 0.5f
		};

		public Envelope VolumeEnvelope { get { return _volumeEnvelope; } set { _volumeEnvelope = value; } }

		public IList<Filter> _filters;
		[UXContent]
		public IList<Filter> Filters
		{
			get
			{
				return _filters ?? (_filters = new List<Filter>());
			}
		}

		int rendered;
		bool released;
		float releaseTime = 0.0f;
		bool finished;

		float[] _voiceBuffer = new float[32];
		public void Render(float[] buffer, int offset, int count)
		{
			bool shouldFinish = false;
			if (!finished)
			{
				var freq = 440 * Math.Pow(2, (Note - 69) / 12.0f);
				int written = 0;
				while (written < count)
				{
					int samples = Math.Min(count - written, 32);

					float time = rendered / 44100.0f;
					float vol = released ? VolumeEnvelope.EvaluateRelease(time, releaseTime) : VolumeEnvelope.EvaluateAttackDecay(time);

					if (time > VolumeEnvelope.Attack && vol < 1e-10)
					{
						shouldFinish = true;
						break;
					}


					// _oscillator.Render(buffer, offset + written, samples, freq);

					for (int i = 0; i < samples; ++i)
						_voiceBuffer[i] = 0;

					foreach (var oscillator in _oscillators)
					{
						oscillator.Amplitude = vol * vol * 0.25f;
						oscillator.Render(_voiceBuffer, 0, samples, freq);
					}

					if (_filters != null && _filters.Count > 0)
						foreach (var filter in _filters)
							filter.Process(_voiceBuffer, samples);

					for (int i = 0; i < samples; ++i)
						buffer[offset + written + i] += _voiceBuffer[i];

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
			debug_log "finishing voice";
			finished = true;

			if (Finished != null)
				Finished(this, EventArgs.Empty);
		}

		public event EventHandler Finished;
	}
}
