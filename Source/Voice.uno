using Uno;
namespace Fuse.Synth
{
	public class Voice : Node
	{
		public int Note { get; set; }
		Oscillator temp = new Oscillator()
		{
			Amplitude = 0.25f
		};

		int rendered;
		bool finished;

		public void Render(float[] buffer, int offset, int count)
		{
			if (!finished)
			{
				var freq = 440 * Math.Pow(2, (Note - 69) / 12.0f);
				temp.Render(buffer, offset, count, freq);
				rendered += count;
			}

			if (rendered > 44100)
				Finish();
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
