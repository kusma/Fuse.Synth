namespace Fuse.Synth
{
	public class Voice : AudioNode
	{
		Oscillator temp = new Oscillator()
		{
			Amplitude = 0.25f
		};

		public override void Render(float[] buffer, int offset, int count)
		{
			for (int i = 0; i < count; ++i)
			{
				buffer[i + offset] = 0;
			}
			temp.Render(buffer, offset, count);
		}
	}
}
