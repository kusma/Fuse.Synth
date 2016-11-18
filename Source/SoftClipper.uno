using Uno;
using Uno.Collections;
using Uno.UX;

namespace Fuse.Synth
{
	public class SoftClipper : AudioNode
	{
		[UXContent]
		public AudioNode Source { get; set; }

		float _softness = 0.25f;
		public float Softness { get { return _softness; } set { _softness = value; } }

		// polynomial smooth min (k = 0.1);
		float SmoothMin( float a, float b, float k )
		{
			float h = Math.Clamp( 0.5f + 0.5f * (b - a) / k, 0.0f, 1.0f);
			return Math.Lerp( b, a, h ) - k * h * (1.0f - h);
		}
	
		public override void Render(float[] buffer, int offset, int count)
		{
			Source.Render(buffer, offset, count);
			for (int i = 0; i < count; ++i)
			{
				var v = buffer[offset + i];

				v = SmoothMin(v, 1.0f, 0.25f);
				v = -SmoothMin(-v, 1.0f, 0.25f);

				buffer[offset + i] = v;
			}
		}
	}
}
