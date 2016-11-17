namespace Fuse.Synth
{
	public class Envelope
	{
		public float Attack { get; set; }
		public float Decay { get; set; }
		public float Sustain { get; set; }
		public float Release { get; set; }

		public float EvaluateAttackDecay(float time)
		{
			if (time < Attack)
				return time / Attack;
			time -= Attack;

			if (time < Decay)
				return 1.0f - (time / Decay) * (1.0f - Sustain);
			time -= Decay;

			return Sustain;
		}

		public float EvaluateRelease(float time, float releaseTime)
		{
			float releaseValue = EvaluateAttackDecay(releaseTime);
			time -= releaseTime;
			return releaseValue * (1.0f - time / Release);
		}
	}
}
