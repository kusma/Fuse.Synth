using Uno;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.AudioSink
{
	[DotNetType]
	public sealed class AudioSink : IDisposable
	{
		extern public AudioSink(int frequency, Action<float[], int, int> fillFunction);
		extern public void Play();
		extern public void Stop();
		extern public void Dispose();
	}
}
