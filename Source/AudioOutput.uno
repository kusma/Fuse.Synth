using Uno;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Synth
{
	[Require("Header.Include", "AndroidAudioSink.h")]
	public class AudioOutput : Node
	{
		extern(CIL) Fuse.AudioSink.AudioSink _audioSink;

		[TargetSpecificType]
		[Require("Header.Include", "AndroidAudioSink.h")]
		[Require("LinkLibrary", "OpenSLES")]
		[Set("TypeName", "AndroidAudioSink *")]
		[Set("DefaultValue", "NULL")]
		extern(ANDROID) public struct AudioSink
		{
		}

		extern(ANDROID) AudioSink _audioSink;

		Oscillator temp = new Oscillator()
		{
			Amplitude = 0.25f
		};

		void fillFunction(float[] buffer, int offset, int count)
		{
			for (int i = 0; i < count; ++i)
			{
				buffer[i + offset] = 0;
			}
			temp.Render(buffer, offset, count);
		}

		protected override void OnRooted()
		{
			if defined(CIL)
			{
				_audioSink = new Fuse.AudioSink.AudioSink(44100, fillFunction);
				_audioSink.Play();
			}
			else if defined(ANDROID)
			{
				var myFillFunction = new Uno.Action<float[], int, int>(fillFunction);
				extern(myFillFunction) @{
					AndroidAudioSink *audioSink = new AndroidAudioSink($0);
					@{AudioOutput:Of($$)._audioSink} = audioSink;
					audioSink->Play();
				@}
			}

			debug_log "rooted!";
			base.OnRooted();
		}

		protected override void OnUnrooted()
		{
			if defined(CIL)
			{
				_audioSink.Stop();
				_audioSink.Dispose();
				_audioSink = null;
			}
			else if defined(ANDROID)
			@{
				@{AudioOutput:Of($$)._audioSink}->Stop();
				delete @{AudioOutput:Of($$)._audioSink};
				@{AudioOutput:Of($$)._audioSink} = NULL;
			@}

			base.OnUnrooted();
			debug_log "unrooted!";
		}
	}
}
