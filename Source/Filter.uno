using Uno;
namespace Fuse.Synth
{
	public class Filter
	{
		public enum FilterType {
			LowPass,
			HighPass,
			BandPass,
			Notch
		}

		public FilterType Type { get; set; }
		public float Frequency { get; set; }
		public float Resonance { get; set; }

		float lastInput, low, band;
		float f, q;

		public float Next(float input)
		{
			Update();
//			float ret = (Run((lastInput + input) / 2.0f) + Run(input)) / 2.0f;
			float ret = Run(input);
			lastInput = input;
			return ret;
		}

		public void Process(float[] data, int count)
		{
			Update();
			for (int i = 0; i < count; ++i)
			{
				float input = data[i];
				// data[i] = (Run((lastInput + input) / 2.0f) + Run(input)) / 2.0f;
				data[i] = Run(input);
				lastInput = input;
			}
		}

		public void Update()
		{
			f = (float)(1.5 * Math.Sin(3.141592 * (double)Frequency / 2.0 / 44100));
			q = Resonance;
		}

		float Run(float input)
		{
			low = low + f * band;
			float high = q * (input - band) - low;
			band = band + f * high;

			switch (Type)
			{
				case FilterType.LowPass: return low;
				case FilterType.HighPass: return high;
				case FilterType.BandPass: return band;
				case FilterType.Notch: return low + high;
				default: return 0;
			}
		}
	}
}
