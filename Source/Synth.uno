using Uno;
using Uno.Collections;
using Uno.UX;

namespace Fuse.Synth
{
	public class Synth : AudioNode
	{
/*
		[UXContent]
		Template VoiceTemplate;
*/
		IList<Template> _templates;
		[UXContent]
		public IList<Template> Templates
		{
			get
			{
				return _templates ?? (_templates = new List<Template>());
			}
		}

		List<Voice> _voices = new List<Voice>();
		List<Voice> _pendingRemoves = new List<Voice>();

		public void NoteOn(int note)
		{
			if (Templates.Count > 0)
			{
				var voice = (Voice)Templates[0].New();
				voice.Note = note;
				voice.Finished += OnVoiceFinished;

				_voices.Add(voice);
			}
		}

		public void NoteOff(int note)
		{
			List<Voice> pendingRemoves = new List<Voice>();
			foreach (var item in _voices)
			{
				if (item.Note == note)
					item.NoteOff();
			}
		}

		void OnVoiceFinished(object sender, EventArgs e)
		{
			_pendingRemoves.Add((Voice)sender);
		}

		public override void Render(float[] buffer, int offset, int count)
		{
			foreach (var item in _voices)
				item.Render(buffer, offset, count);

			foreach (var item in _pendingRemoves)
				_voices.Remove(item);
			_pendingRemoves.Clear();
		}
	}

	class VoiceTemplate: Uno.UX.Template
	{
		public VoiceTemplate(): base(null, false) {}

		public override object New()
		{
			return new Voice();
		}
	}
}
