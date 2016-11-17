using Fuse.Triggers.Actions;

namespace Fuse.Synth
{
	public class NoteOff : TriggerAction
	{
		public Synth Target { get; set; }
		public int Note { get; set; }
		
		protected override void Perform(Node target)
		{
			debug_log "NoteOff: " + Note;
			if (Target != null)
				Target.NoteOff(Note);
		}
	}
}
