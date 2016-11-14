using Uno;

namespace Fuse.Synth
{
	public class Oscillator
	{
		static float[] _triangleWaveTable = new float[4096];
		static float[] _squareWaveTable = new float[4096];

		static Oscillator()
		{
			double th0 = 0.0f;
			double delta = (Math.PI * 2) / 4096;
			for (int i = 0; i < 4096; ++i)
			{
				double tri = 0.0f;
				double sqr = 0.0f;
				double fl = 1.0f;
				for (int harmony = 1; harmony < 12; harmony += 2)
				{
					double s = Math.Sin(th0 * harmony);

					// Kinda cheesy, doesn't deal with the Gibbs phenomenon at all. Maybe filtering afterwards is OK enough?
					tri += s * -fl / (harmony * harmony);
					sqr += s * 1.0 / harmony;

					fl = -fl;
				}

				_triangleWaveTable[i] = (float)tri;
				_squareWaveTable[i] = (float)sqr;

				th0 += delta;
			}
		}

		uint sample;
		public void Render(float[] buffer, int offset, int count)
		{
			uint pitch = 10u << (32 - 12);
			for (int i = 0; i < count; ++i)
			{
				uint index = (sample >> (32 - 12)) & 4095;
				buffer[offset + i] += _triangleWaveTable[(int)index] * Amplitude;
				sample += pitch;
			}
		}

		public double Frequency { get; set; }
		public float Amplitude { get; set; }
	}
}
