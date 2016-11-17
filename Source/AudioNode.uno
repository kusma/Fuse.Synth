namespace Fuse.Synth
{
	public abstract class AudioNode : Node
	{
		public abstract void Render(float[] buffer, int offset, int count);
	}
}
